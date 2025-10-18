#include "ast.h"
#include <stdlib.h>

static void	redirect_free(t_redirect *redir)
{
	t_redirect	*next;

	while (redir)
	{
		next = redir->next;
		free(redir->target);
		free(redir);
		redir = next;
	}
}

static void	command_free(t_command *cmd)
{
	size_t	i;

	if (!cmd)
		return ;
	if (cmd->argv)
	{
		i = 0;
		while (cmd->argv[i])
		{
			free(cmd->argv[i]);
			i++;
		}
		free(cmd->argv);
	}
	redirect_free(cmd->redirects);
}

void	ast_free(t_ast *node)
{
	if (!node)
		return ;
	if (node->type == AST_PIPELINE)
	{
		ast_free(node->as.pipeline.left);
		ast_free(node->as.pipeline.right);
	}
	else if (node->type == AST_COMMAND)
		command_free(&node->as.command);
	free(node);
}
