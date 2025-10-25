#include "executor_internal.h"

static int	prepare_command_heredocs(t_ms *ms, t_command *cmd)
{
	t_redirect	*redir;
	int			status;

	redir = cmd->redirects;
	while (redir)
	{
		if (redir->type == REDIR_HEREDOC)
		{
			status = ms_collect_heredoc_input(ms, redir);
			if (status != 0)
				return (status);
		}
		redir = redir->next;
	}
	return (0);
}

static int	prepare_ast_heredocs(t_ms *ms, t_ast *node)
{
	int	status;

	if (!node)
		return (0);
	if (node->type == AST_COMMAND)
		return (prepare_command_heredocs(ms, &node->as.command));
	status = prepare_ast_heredocs(ms, node->as.pipeline.left);
	if (status != 0)
		return (status);
	return (prepare_ast_heredocs(ms, node->as.pipeline.right));
}

int	ms_execute(t_ms *ms, t_ast *ast)
{
	int	status;

	status = prepare_ast_heredocs(ms, ast);
	if (status != 0)
	{
		if (status == 130)
			ms->last_status = 130;
		else
			ms->last_status = 1;
		return (status);
	}
	status = ms_execute_ast_node(ms, ast, 0);
	if (status < 0)
		status = 1;
	ms->last_status = status;
	return (status);
}
