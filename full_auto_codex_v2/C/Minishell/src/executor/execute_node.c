#include "executor_internal.h"

int	ms_execute_ast_node(t_ms *ms, t_ast *node, int in_child)
{
	int	status;

	if (!node)
		return (-1);
	if (node->type == AST_PIPELINE)
		status = ms_execute_pipeline(ms, node->as.pipeline.left,
				node->as.pipeline.right);
	else
		status = ms_execute_command(ms, &node->as.command, in_child);
	if (status >= 0)
		ms->last_status = status;
	return (status);
}
