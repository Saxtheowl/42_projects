#include "parser.h"
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stddef.h>

typedef enum e_value
{
	VAL_FALSE,
	VAL_TRUE,
	VAL_UNKNOWN,
	VAL_INPROGRESS
}	t_value;

typedef struct s_rule
{
	t_ast			*premise;
	t_ast			*conclusion;
	int				id;
	char			*raw;
	struct s_rule	*next;
}	t_rule;

static int	g_trace = 0;

typedef enum e_apply_res
{
	APPLY_NONE = 0,
	APPLY_PROGRESS = 1,
	APPLY_CONFLICT = -1,
	APPLY_SATISFIED = 2
}	t_apply_res;

static int	trim(char *line)
{
	size_t len = strlen(line);
	while (len && (line[len - 1] == '\n' || line[len - 1] == '\r'))
		line[--len] = '\0';
	return (int)len;
}

static void	strip_comment(char *line)
{
	char *hash = strchr(line, '#');
	if (hash)
		*hash = '\0';
	trim(line);
}

static t_rule	*rule_new(t_ast *premise, t_ast *conclusion, int id, const char *raw)
{
	t_rule *r = malloc(sizeof(t_rule));
	if (!r)
		return NULL;
	r->premise = premise;
	r->conclusion = conclusion;
	r->id = id;
	if (raw)
	{
		size_t len = strlen(raw);
		r->raw = malloc(len + 1);
		if (!r->raw)
			return NULL;
		memcpy(r->raw, raw, len + 1);
	}
	else
		r->raw = NULL;
	r->next = NULL;
	return r;
}

static void	rules_free(t_rule *r)
{
	while (r)
	{
		t_rule *n = r->next;
		ast_free(r->premise);
		ast_free(r->conclusion);
		free(r->raw);
		free(r);
		r = n;
	}
}

static int	idx(char c)
{
	return c - 'A';
}

static t_value	eval_symbol(char symbol, t_rule *rules, t_value values[], int conflicts[], char origins[][128]);
static t_apply_res	apply_conclusion(t_ast *node, t_value values[], int conflicts[], char origins[][128], const char *src);
static int		propagate_all(t_rule *rules, t_value values[], int conflicts[], char origins[][128]);
static void		collect_ast(const t_ast *node, int seen[]);
static void		collect_rules(t_rule *rules, int seen[]);
static void		print_known(const int seen[], const t_value values[]);
static void		trace_rule(int id, t_apply_res res, const char *raw);
static void		trace_conflict(const char *src, t_ast *node);
static int		values_changed(const t_value a[], const t_value b[]);
static void		print_conflicts(const int conflicts[], char origins[][128]);
static void		mark_conflict_symbols(t_ast *node, int conflicts[], char origins[][128], const char *src);
static void		apply_conflicts_to_values(int conflicts[], t_value values[]);
static void		print_summary(const int seen[], const t_value values[], const int conflicts[]);
static void		print_result(char sym, t_value v, const int conflicts[], char origins[][128], int show_origin);
static void		print_json_results(const char *queries, const t_value values[], const int conflicts[], char origins[][128], int show_origin);

static int	is_literal(const t_ast *node)
{
	return node && (node->type == NODE_SYMBOL ||
		(node->type == NODE_NOT && node->left && node->left->type == NODE_SYMBOL));
}

static t_value	literal_value(const t_ast *node, t_value values[], int *is_det)
{
	*is_det = 0;
	if (!node)
		return VAL_UNKNOWN;
	if (node->type == NODE_SYMBOL)
	{
		t_value v = values[idx(node->symbol)];
		if (v == VAL_TRUE || v == VAL_FALSE)
			*is_det = 1;
		return v;
	}
	if (node->type == NODE_NOT && node->left && node->left->type == NODE_SYMBOL)
	{
		t_value v = values[idx(node->left->symbol)];
		if (v == VAL_TRUE)
		{
			*is_det = 1;
			return VAL_FALSE;
		}
		if (v == VAL_FALSE)
		{
			*is_det = 1;
			return VAL_TRUE;
		}
		return VAL_UNKNOWN;
	}
	return VAL_UNKNOWN;
}

static t_value	eval_ast(t_ast *node, t_rule *rules, t_value values[], int conflicts[], char origins[][128])
{
	if (!node)
		return VAL_UNKNOWN;
	if (node->type == NODE_SYMBOL)
		return eval_symbol(node->symbol, rules, values, conflicts, origins);
	if (node->type == NODE_NOT)
	{
		t_value v = eval_ast(node->left, rules, values, conflicts, origins);
		if (v == VAL_UNKNOWN)
			return VAL_UNKNOWN;
		return v == VAL_TRUE ? VAL_FALSE : VAL_TRUE;
	}
	t_value l = eval_ast(node->left, rules, values, conflicts, origins);
	t_value r = eval_ast(node->right, rules, values, conflicts, origins);
	if (node->type == NODE_AND)
	{
		if (l == VAL_FALSE || r == VAL_FALSE)
			return VAL_FALSE;
		if (l == VAL_UNKNOWN || r == VAL_UNKNOWN)
			return VAL_UNKNOWN;
		return VAL_TRUE;
	}
	if (node->type == NODE_OR)
	{
		if (l == VAL_TRUE || r == VAL_TRUE)
			return VAL_TRUE;
		if (l == VAL_UNKNOWN || r == VAL_UNKNOWN)
			return VAL_UNKNOWN;
		return VAL_FALSE;
	}
	/* NODE_XOR */
	if (l == VAL_UNKNOWN || r == VAL_UNKNOWN)
		return VAL_UNKNOWN;
	return (l != r) ? VAL_TRUE : VAL_FALSE;
}

/* Assign deterministic values from a conclusion:
 * - SYMBOL -> true
 * - NOT SYMBOL -> false
 * - AND propagates both sides
 * - OR tries to conclude the remaining branch if the other is false
 * - XOR tries to conclude the opposite of a true literal, or the truth of the other if one is false
 * Returns APPLY_* to signal progress/conflict/satisfied/none.
 */
static t_apply_res	apply_conclusion(t_ast *node, t_value values[], int conflicts[], char origins[][128], const char *src)
{
	if (!node)
		return APPLY_NONE;
	if (node->type == NODE_SYMBOL)
	{
		int id = idx(node->symbol);
		if (values[id] == VAL_FALSE)
		{
			values[id] = VAL_UNKNOWN;
			conflicts[id] = 1;
			if (origins[id][0] == '\0')
				snprintf(origins[id], 128, "%s", src ? src : "rule");
			trace_conflict(src, node);
			return APPLY_CONFLICT;
		}
		if (values[id] == VAL_TRUE)
			return APPLY_SATISFIED;
		values[id] = VAL_TRUE;
		return APPLY_PROGRESS;
	}
	if (node->type == NODE_NOT && node->left && node->left->type == NODE_SYMBOL)
	{
		int id = idx(node->left->symbol);
		if (values[id] == VAL_TRUE)
		{
			values[id] = VAL_UNKNOWN;
			conflicts[id] = 1;
			if (origins[id][0] == '\0')
				snprintf(origins[id], 128, "%s", src ? src : "rule");
			trace_conflict(src, node);
			return APPLY_CONFLICT;
		}
		if (values[id] == VAL_FALSE)
			return APPLY_SATISFIED;
		values[id] = VAL_FALSE;
		return APPLY_PROGRESS;
	}
	if (node->type == NODE_AND)
	{
		t_apply_res a = apply_conclusion(node->left, values, conflicts, origins, src);
		t_apply_res b = apply_conclusion(node->right, values, conflicts, origins, src);
		if (a == APPLY_CONFLICT || b == APPLY_CONFLICT)
			return APPLY_CONFLICT;
		if (a == APPLY_PROGRESS || b == APPLY_PROGRESS)
			return APPLY_PROGRESS;
		if (a == APPLY_SATISFIED || b == APPLY_SATISFIED)
			return APPLY_SATISFIED;
		return APPLY_NONE;
	}
	if (node->type == NODE_OR)
	{
		int det_left = 0, det_right = 0;
		t_value lv = literal_value(node->left, values, &det_left);
		t_value rv = literal_value(node->right, values, &det_right);
		if (det_left && det_right && lv == VAL_FALSE && rv == VAL_FALSE)
		{
			mark_conflict_symbols(node, conflicts, origins, src ? src : "OR_conflict");
			trace_conflict(src, node);
			return APPLY_CONFLICT;
		}
		if ((det_left && lv == VAL_TRUE) || (det_right && rv == VAL_TRUE))
			return APPLY_SATISFIED;
		if (det_left && lv == VAL_FALSE)
			return apply_conclusion(node->right, values, conflicts, origins, src);
		if (det_right && rv == VAL_FALSE)
			return apply_conclusion(node->left, values, conflicts, origins, src);
		return APPLY_NONE;
	}
	if (node->type == NODE_XOR)
	{
		int det_left = 0, det_right = 0;
		t_value lv = literal_value(node->left, values, &det_left);
		t_value rv = literal_value(node->right, values, &det_right);
		if (det_left && det_right)
		{
			if (lv == rv)
			{
				mark_conflict_symbols(node, conflicts, origins, src ? src : "XOR_conflict");
				trace_conflict(src, node);
				return APPLY_CONFLICT;
			}
			return APPLY_SATISFIED;
		}
		if (det_left && lv == VAL_TRUE && is_literal(node->right))
		{
			t_ast neg = {.type = NODE_NOT, .symbol = 0, .left = node->right, .right = NULL};
			return apply_conclusion(&neg, values, conflicts, origins, src);
		}
		if (det_left && lv == VAL_FALSE)
			return apply_conclusion(node->right, values, conflicts, origins, src);
		if (det_right && rv == VAL_TRUE && is_literal(node->left))
		{
			t_ast neg = {.type = NODE_NOT, .symbol = 0, .left = node->left, .right = NULL};
			return apply_conclusion(&neg, values, conflicts, origins, src);
		}
		if (det_right && rv == VAL_FALSE)
			return apply_conclusion(node->left, values, conflicts, origins, src);
		return APPLY_NONE;
	}
	return APPLY_NONE;
}

/* Forward propagation pass: apply all rules whose premise is true until fixpoint */
static int	propagate_all(t_rule *rules, t_value values[], int conflicts[], char origins[][128])
{
	int changed = 0;
	int loop = 0;
	while (1)
	{
		int loop_changed = 0;
		int conflict = 0;
		for (t_rule *r = rules; r; r = r->next)
		{
			t_value prem = eval_ast(r->premise, rules, values, conflicts, origins);
			if (prem == VAL_TRUE)
			{
				const char *src = (r->raw && r->raw[0]) ? r->raw : "rule";
				t_apply_res res = apply_conclusion(r->conclusion, values, conflicts, origins, src);
				if (res == APPLY_PROGRESS)
				{
					loop_changed = 1;
					if (g_trace)
						trace_rule(r->id, res, r->raw);
				}
				else if (res == APPLY_CONFLICT)
				{
					conflict = 1;
					loop_changed = 1;
				}
			}
		}
		if (!loop_changed || conflict)
			break;
		changed = 1;
		if (++loop > 10000)
			break;
	}
	return changed;
}

static void	collect_ast(const t_ast *node, int seen[])
{
	if (!node)
		return;
	if (node->type == NODE_SYMBOL)
	{
		int id = idx(node->symbol);
		if (id >= 0 && id < 26)
			seen[id] = 1;
		return;
	}
	collect_ast(node->left, seen);
	collect_ast(node->right, seen);
}

static void	collect_rules(t_rule *rules, int seen[])
{
	for (t_rule *r = rules; r; r = r->next)
	{
		collect_ast(r->premise, seen);
		collect_ast(r->conclusion, seen);
	}
}

static void	print_known(const int seen[], const t_value values[])
{
	printf("Known facts after fixpoint:\n");
	for (int i = 0; i < 26; ++i)
	{
		if (!seen[i])
			continue;
		if (values[i] == VAL_TRUE)
			printf("%c: true\n", 'A' + i);
		else if (values[i] == VAL_FALSE)
			printf("%c: false\n", 'A' + i);
	}
}

static void	print_conflicts(const int conflicts[], char origins[][128])
{
	printf("Conflicts detected:\n");
	int any = 0;
	int first = 1;
	for (int i = 0; i < 26; ++i)
	{
		if (conflicts[i])
		{
			if (!first)
				printf(" ");
			printf("%c", 'A' + i);
			if (origins[i][0])
				printf(" (from %s)", origins[i]);
			any = 1;
			first = 0;
		}
	}
	if (!any)
		printf("none");
	printf("\n");
}

static void	mark_conflict_symbols(t_ast *node, int conflicts[], char origins[][128], const char *src)
{
	if (!node)
		return;
	if (node->type == NODE_SYMBOL)
	{
		conflicts[idx(node->symbol)] = 1;
		if (src && origins[idx(node->symbol)][0] == '\0')
			snprintf(origins[idx(node->symbol)], 128, "%s", src);
		return;
	}
	if (node->type == NODE_NOT && node->left && node->left->type == NODE_SYMBOL)
	{
		conflicts[idx(node->left->symbol)] = 1;
		if (src && origins[idx(node->left->symbol)][0] == '\0')
			snprintf(origins[idx(node->left->symbol)], 128, "%s", src);
		return;
	}
	mark_conflict_symbols(node->left, conflicts, origins, src);
	mark_conflict_symbols(node->right, conflicts, origins, src);
}

static void	apply_conflicts_to_values(int conflicts[], t_value values[])
{
	for (int i = 0; i < 26; ++i)
	{
		if (conflicts[i])
			values[i] = VAL_UNKNOWN;
	}
}

static void	print_summary(const int seen[], const t_value values[], const int conflicts[])
{
	printf("Summary after evaluation:\n");
	for (int i = 0; i < 26; ++i)
	{
		if (!seen[i])
			continue;
		const char *txt = (values[i] == VAL_TRUE) ? "true" :
			(values[i] == VAL_FALSE) ? "false" : "undetermined";
		printf("%c: %s%s\n", 'A' + i, txt, conflicts[i] ? " (conflict)" : "");
	}
}

static int	values_changed(const t_value a[], const t_value b[])
{
	for (int i = 0; i < 26; ++i)
		if (a[i] != b[i])
			return 1;
	return 0;
}

static void	trace_rule(int id, t_apply_res res, const char *raw)
{
	const char *label = (res == APPLY_PROGRESS) ? "progress" : "satisfied";
	if (raw)
		printf("Rule #%d fired (%s): %s\n", id, label, raw);
	else
		printf("Rule #%d fired (%s)\n", id, label);
}

static void	trace_conflict(const char *src, t_ast *node)
{
	if (!g_trace)
		return;
	int seen[26] = {0};
	collect_ast(node, seen);
	printf("Conflict triggered by %s on", src ? src : "rule");
	for (int i = 0; i < 26; ++i)
		if (seen[i])
			printf(" %c", 'A' + i);
	printf("\n");
}

static t_value	eval_symbol(char symbol, t_rule *rules, t_value values[], int conflicts[], char origins[][128])
{
	int i = idx(symbol);
	if (values[i] == VAL_TRUE || values[i] == VAL_FALSE)
		return values[i];
	if (values[i] == VAL_INPROGRESS)
		return VAL_UNKNOWN;
	values[i] = VAL_INPROGRESS;
	int has_rule = 0;
	int seen_unknown = 0;
	int conflict = 0;
	int assigned_true = 0;
	int assigned_false = 0;
	int changed = 1;
	while (changed)
	{
		changed = 0;
		for (t_rule *r = rules; r; r = r->next)
		{
			if (!ast_contains_symbol(r->conclusion, symbol))
				continue;
			has_rule = 1;
			t_value prem = eval_ast(r->premise, rules, values, conflicts, origins);
			if (prem == VAL_TRUE)
			{
				const char *src = (r->raw && r->raw[0]) ? r->raw : "rule";
				t_apply_res applied = apply_conclusion(r->conclusion, values, conflicts, origins, src);
				if (applied == APPLY_CONFLICT)
					conflict = 1;
				else if (applied == APPLY_PROGRESS || applied == APPLY_SATISFIED)
				{
					if (values[i] == VAL_TRUE)
						assigned_true = 1;
					else if (values[i] == VAL_FALSE)
						assigned_false = 1;
					else
						seen_unknown = 1;
					if (applied == APPLY_PROGRESS)
					{
						changed = 1;
						if (g_trace)
							trace_rule(r->id, applied, r->raw);
					}
				}
				else
				{
					/* Unsupported conclusion shape for assignment */
					seen_unknown = 1;
				}
			}
			else if (prem == VAL_UNKNOWN)
				seen_unknown = 1;
		}
		if (conflict)
			break;
	}
	t_value result;
	if (conflict)
		result = VAL_UNKNOWN;
	else if (assigned_true && assigned_false)
		result = VAL_UNKNOWN;
	else if (assigned_true)
		result = VAL_TRUE;
	else if (assigned_false)
		result = VAL_FALSE;
	else if (!has_rule && values[i] == VAL_INPROGRESS)
		result = VAL_UNKNOWN;
	else if (seen_unknown)
		result = VAL_UNKNOWN;
	else
		result = VAL_FALSE;
	values[i] = result;
	return result;
}

static void	print_result(char sym, t_value v, const int conflicts[], char origins[][128], int show_origin)
{
	const char *txt = (v == VAL_TRUE) ? "true" : (v == VAL_FALSE) ? "false" : "undetermined";
	if (conflicts && conflicts[idx(sym)])
	{
		printf("%c: %s (conflict", sym, txt);
		if (show_origin && origins && origins[idx(sym)][0])
			printf(" from %s", origins[idx(sym)]);
		printf(")\n");
	}
	else
		printf("%c: %s\n", sym, txt);
}

static void	print_json_results(const char *queries, const t_value values[], const int conflicts[], char origins[][128], int show_origin)
{
	printf("{\"results\":[");
	int first = 1;
	for (int i = 0; queries[i]; ++i)
	{
		char q = queries[i];
		if (!isupper((unsigned char)q))
			continue;
		if (!first)
			printf(",");
		first = 0;
		const char *val = (values[idx(q)] == VAL_TRUE) ? "true" :
			(values[idx(q)] == VAL_FALSE) ? "false" : "undetermined";
		int conf = conflicts && conflicts[idx(q)];
		printf("{\"symbol\":\"%c\",\"value\":\"%s\",\"conflict\":%s", q, val, conf ? "true" : "false");
		if (conf && show_origin && origins && origins[idx(q)][0])
			printf(",\"origin\":\"%s\"", origins[idx(q)]);
		printf("}");
	}
	printf("]}\n");
}

int	main(int argc, char **argv)
{
	int verbose = 0;
	int show_conflicts = 0;
	int show_summary = 0;
	int show_origin = 0;
	int json_output = 0;
	const char *path = NULL;
	int conflicts[26] = {0};
	char conflict_origins[26][128] = {{0}};
	int i = 1;
	while (i < argc && argv[i][0] == '-' && argv[i][1])
	{
		for (int j = 1; argv[i][j]; ++j)
		{
			if (argv[i][j] == 'v')
			{
				verbose = 1;
				g_trace = 1;
			}
			else if (argv[i][j] == 'c')
				show_conflicts = 1;
			else if (argv[i][j] == 's')
				show_summary = 1;
			else if (argv[i][j] == 'o')
				show_origin = 1;
			else if (argv[i][j] == 'j')
				json_output = 1;
			else
			{
				fprintf(stderr, "Unknown option: -%c\n", argv[i][j]);
				fprintf(stderr, "Usage: %s [-v] [-c] [-s] [-o] [-j] <input_file>\n", argv[0]);
				return 1;
			}
		}
		++i;
	}
	if (i == argc)
	{
		fprintf(stderr, "Usage: %s [-v] [-c] [-s] [-o] [-j] <input_file>\n", argv[0]);
		return 1;
	}
	path = argv[i];
	if (!path)
	{
		fprintf(stderr, "Usage: %s [-v] [-c] [-s] [-o] [-j] <input_file>\n", argv[0]);
		return 1;
	}
	char queries[256] = {0};
	t_value values[26];
	for (int i = 0; i < 26; ++i)
		values[i] = VAL_UNKNOWN;
	t_rule *rules = NULL;
	t_rule **tail = &rules;
	int rule_id = 1;
	FILE *f = fopen(path, "r");
	if (!f)
	{
		perror("fopen");
		return 1;
	}
	char buf[1024];
	int line_no = 0;
	while (fgets(buf, sizeof(buf), f))
	{
		++line_no;
		trim(buf);
		strip_comment(buf);
		if (buf[0] == '\0')
			continue;
		if (buf[0] == '=')
		{
			for (char *p = buf + 1; *p; ++p)
			{
				if (isspace((unsigned char)*p))
					continue;
				if (*p == '!' && isupper((unsigned char)*(p + 1)))
				{
					int id = idx(*(p + 1));
					if (values[id] == VAL_TRUE)
					{
						conflicts[id] = 1;
						if (!conflict_origins[id][0])
							snprintf(conflict_origins[id], sizeof(conflict_origins[id]), "facts");
						values[id] = VAL_UNKNOWN;
					}
					else
						values[id] = VAL_FALSE;
					++p;
				}
				else if (isupper((unsigned char)*p))
				{
					int id = idx(*p);
					if (values[id] == VAL_FALSE)
					{
						conflicts[id] = 1;
						if (!conflict_origins[id][0])
							snprintf(conflict_origins[id], sizeof(conflict_origins[id]), "facts");
						values[id] = VAL_UNKNOWN;
					}
					else
						values[id] = VAL_TRUE;
				}
			}
			continue;
		}
		if (buf[0] == '?')
		{
			int qi = 0;
			memset(queries, 0, sizeof(queries));
			for (char *p = buf + 1; *p && qi < (int)sizeof(queries) - 1; ++p)
			{
				if (isupper((unsigned char)*p))
					queries[qi++] = *p;
			}
			queries[qi] = '\0';
			continue;
		}
		t_ast *prem = NULL;
		t_ast *conc = NULL;
		int is_bicond = 0;
		if (!parse_rule(buf, &prem, &conc, &is_bicond))
		{
			fprintf(stderr, "Parse error line %d\n", line_no);
			rules_free(rules);
			fclose(f);
			return 1;
		}
		t_rule *r = rule_new(prem, conc, rule_id++, buf);
		if (!r)
		{
			perror("malloc");
			ast_free(prem);
			ast_free(conc);
			rules_free(rules);
			fclose(f);
			return 1;
		}
		*tail = r;
		tail = &r->next;
		if (is_bicond)
		{
			t_ast *rev_p = ast_clone(conc);
			t_ast *rev_c = ast_clone(prem);
			char rev_label[128];
			snprintf(rev_label, sizeof(rev_label), "rev of #%d", r->id);
			t_rule *rev = rule_new(rev_p, rev_c, rule_id++, rev_label);
			if (!rev)
			{
				perror("malloc");
				rules_free(rules);
				fclose(f);
				return 1;
			}
			*tail = rev;
			tail = &rev->next;
		}
	}
	fclose(f);
	if (queries[0] == '\0')
	{
		fprintf(stderr, "No queries found in %s\n", argv[1]);
		rules_free(rules);
		return 1;
	}
	/* Optional forward pass to expose trivial deductions before answering */
	int seen[26] = {0};
	collect_rules(rules, seen);
	for (int qi = 0; queries[qi]; ++qi)
		if (isupper((unsigned char)queries[qi]))
			seen[idx(queries[qi])] = 1;
	for (int iter = 0; iter < 50; ++iter)
	{
		t_value before[26];
		memcpy(before, values, sizeof(values));
		for (int s = 0; s < 26; ++s)
			if (seen[s])
				eval_symbol('A' + s, rules, values, conflicts, conflict_origins);
		propagate_all(rules, values, conflicts, conflict_origins);
		apply_conflicts_to_values(conflicts, values);
		if (!values_changed(before, values))
			break;
	}
	if (!json_output)
	{
		if (verbose)
			print_known(seen, values);
		if (show_conflicts)
			print_conflicts(conflicts, conflict_origins);
		if (show_summary)
			print_summary(seen, values, conflicts);
		for (int i = 0; queries[i]; ++i)
		{
			char q = queries[i];
			if (!isupper((unsigned char)q))
				continue;
			t_value v = eval_symbol(q, rules, values, conflicts, conflict_origins);
			if (conflicts[idx(q)])
				v = VAL_UNKNOWN;
			print_result(q, v, conflicts, conflict_origins, show_origin);
		}
	}
	else
	{
		for (int i = 0; queries[i]; ++i)
		{
			char q = queries[i];
			if (!isupper((unsigned char)q))
				continue;
			t_value v = eval_symbol(q, rules, values, conflicts, conflict_origins);
			if (conflicts[idx(q)])
				v = VAL_UNKNOWN;
			values[idx(q)] = v;
		}
		print_json_results(queries, values, conflicts, conflict_origins, show_origin);
	}
	rules_free(rules);
	return 0;
}
