#include "parser.h"
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

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

static t_rule	*rule_new(t_ast *premise, t_ast *conclusion, int id)
{
	t_rule *r = malloc(sizeof(t_rule));
	if (!r)
		return NULL;
	r->premise = premise;
	r->conclusion = conclusion;
	r->id = id;
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
		free(r);
		r = n;
	}
}

static int	idx(char c)
{
	return c - 'A';
}

static t_value	eval_symbol(char symbol, t_rule *rules, t_value values[], int conflicts[]);
static t_apply_res	apply_conclusion(t_ast *node, t_value values[], int conflicts[]);
static int		propagate_all(t_rule *rules, t_value values[], int conflicts[]);
static void		collect_ast(const t_ast *node, int seen[]);
static void		collect_rules(t_rule *rules, int seen[]);
static void		print_known(const int seen[], const t_value values[]);
static void		trace_rule(int id, t_apply_res res);
static int		values_changed(const t_value a[], const t_value b[]);
static void		print_conflicts(const int conflicts[]);
static void		mark_conflict_symbols(t_ast *node, int conflicts[]);
static void		apply_conflicts_to_values(int conflicts[], t_value values[]);

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

static t_value	eval_ast(t_ast *node, t_rule *rules, t_value values[], int conflicts[])
{
	if (!node)
		return VAL_UNKNOWN;
	if (node->type == NODE_SYMBOL)
		return eval_symbol(node->symbol, rules, values, conflicts);
	if (node->type == NODE_NOT)
	{
		t_value v = eval_ast(node->left, rules, values, conflicts);
		if (v == VAL_UNKNOWN)
			return VAL_UNKNOWN;
		return v == VAL_TRUE ? VAL_FALSE : VAL_TRUE;
	}
	t_value l = eval_ast(node->left, rules, values, conflicts);
	t_value r = eval_ast(node->right, rules, values, conflicts);
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
static t_apply_res	apply_conclusion(t_ast *node, t_value values[], int conflicts[])
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
			return APPLY_CONFLICT;
		}
		if (values[id] == VAL_FALSE)
			return APPLY_SATISFIED;
		values[id] = VAL_FALSE;
		return APPLY_PROGRESS;
	}
	if (node->type == NODE_AND)
	{
		t_apply_res a = apply_conclusion(node->left, values, conflicts);
		t_apply_res b = apply_conclusion(node->right, values, conflicts);
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
			mark_conflict_symbols(node, conflicts);
			return APPLY_CONFLICT;
		}
		if ((det_left && lv == VAL_TRUE) || (det_right && rv == VAL_TRUE))
			return APPLY_SATISFIED;
		if (det_left && lv == VAL_FALSE)
			return apply_conclusion(node->right, values, conflicts);
		if (det_right && rv == VAL_FALSE)
			return apply_conclusion(node->left, values, conflicts);
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
				mark_conflict_symbols(node, conflicts);
				return APPLY_CONFLICT;
			}
			return APPLY_SATISFIED;
		}
		if (det_left && lv == VAL_TRUE && is_literal(node->right))
		{
			t_ast neg = {.type = NODE_NOT, .symbol = 0, .left = node->right, .right = NULL};
			return apply_conclusion(&neg, values, conflicts);
		}
		if (det_left && lv == VAL_FALSE)
			return apply_conclusion(node->right, values, conflicts);
		if (det_right && rv == VAL_TRUE && is_literal(node->left))
		{
			t_ast neg = {.type = NODE_NOT, .symbol = 0, .left = node->left, .right = NULL};
			return apply_conclusion(&neg, values, conflicts);
		}
		if (det_right && rv == VAL_FALSE)
			return apply_conclusion(node->left, values, conflicts);
		return APPLY_NONE;
	}
	return APPLY_NONE;
}

/* Forward propagation pass: apply all rules whose premise is true until fixpoint */
static int	propagate_all(t_rule *rules, t_value values[], int conflicts[])
{
	int changed = 0;
	int loop = 0;
	while (1)
	{
		int loop_changed = 0;
		int conflict = 0;
		for (t_rule *r = rules; r; r = r->next)
		{
			t_value prem = eval_ast(r->premise, rules, values, conflicts);
			if (prem == VAL_TRUE)
			{
				t_apply_res res = apply_conclusion(r->conclusion, values, conflicts);
				if (res == APPLY_PROGRESS)
				{
					loop_changed = 1;
					if (g_trace)
						trace_rule(r->id, res);
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

static void	print_conflicts(const int conflicts[])
{
	printf("Conflicts detected:\n");
	int any = 0;
	for (int i = 0; i < 26; ++i)
	{
		if (conflicts[i])
		{
			printf("%c ", 'A' + i);
			any = 1;
		}
	}
	if (!any)
		printf("none");
	printf("\n");
}

static void	mark_conflict_symbols(t_ast *node, int conflicts[])
{
	if (!node)
		return;
	if (node->type == NODE_SYMBOL)
	{
		conflicts[idx(node->symbol)] = 1;
		return;
	}
	if (node->type == NODE_NOT && node->left && node->left->type == NODE_SYMBOL)
	{
		conflicts[idx(node->left->symbol)] = 1;
		return;
	}
	mark_conflict_symbols(node->left, conflicts);
	mark_conflict_symbols(node->right, conflicts);
}

static void	apply_conflicts_to_values(int conflicts[], t_value values[])
{
	for (int i = 0; i < 26; ++i)
	{
		if (conflicts[i])
			values[i] = VAL_UNKNOWN;
	}
}

static int	values_changed(const t_value a[], const t_value b[])
{
	for (int i = 0; i < 26; ++i)
		if (a[i] != b[i])
			return 1;
	return 0;
}

static void	trace_rule(int id, t_apply_res res)
{
	const char *label = (res == APPLY_PROGRESS) ? "progress" : "satisfied";
	printf("Rule #%d fired (%s)\n", id, label);
}

static t_value	eval_symbol(char symbol, t_rule *rules, t_value values[], int conflicts[])
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
			t_value prem = eval_ast(r->premise, rules, values, conflicts);
			if (prem == VAL_TRUE)
			{
				t_apply_res applied = apply_conclusion(r->conclusion, values, conflicts);
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
							trace_rule(r->id, applied);
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

static void	print_result(char sym, t_value v)
{
	const char *txt = (v == VAL_TRUE) ? "true" : (v == VAL_FALSE) ? "false" : "undetermined";
	printf("%c: %s\n", sym, txt);
}

int	main(int argc, char **argv)
{
	int verbose = 0;
	int show_conflicts = 0;
	const char *path = NULL;
	int conflicts[26] = {0};
	if (argc >= 2 && strcmp(argv[1], "-v") == 0)
	{
		verbose = 1;
		g_trace = 1;
		if (argc >= 3 && strcmp(argv[2], "-c") == 0)
		{
			show_conflicts = 1;
			path = argv[3];
		}
		else
			path = argv[2];
	}
	else if (argc >= 2 && strcmp(argv[1], "-c") == 0)
	{
		show_conflicts = 1;
		if (argc >= 3 && strcmp(argv[2], "-v") == 0)
		{
			verbose = 1;
			g_trace = 1;
			path = argv[3];
		}
		else
			path = argv[2];
	}
	else
	{
		path = (argc == 2) ? argv[1] : NULL;
	}
	if (!path)
	{
		fprintf(stderr, "Usage: %s [-v] [-c] <input_file>\n", argv[0]);
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
				if (isupper((unsigned char)*p))
					values[idx(*p)] = VAL_TRUE;
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
		t_rule *r = rule_new(prem, conc, rule_id++);
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
			t_rule *rev = rule_new(rev_p, rev_c, rule_id++);
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
				eval_symbol('A' + s, rules, values, conflicts);
		propagate_all(rules, values, conflicts);
		apply_conflicts_to_values(conflicts, values);
		if (!values_changed(before, values))
			break;
	}
	if (verbose)
		print_known(seen, values);
	if (show_conflicts)
		print_conflicts(conflicts);
	for (int i = 0; queries[i]; ++i)
	{
		char q = queries[i];
		if (!isupper((unsigned char)q))
			continue;
		t_value v = eval_symbol(q, rules, values, conflicts);
		if (conflicts[idx(q)])
			v = VAL_UNKNOWN;
		print_result(q, v);
	}
	rules_free(rules);
	return 0;
}
