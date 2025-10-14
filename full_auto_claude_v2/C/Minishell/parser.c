/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parser.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static t_cmd	*create_cmd(void)
{
	t_cmd	*cmd;

	cmd = malloc(sizeof(t_cmd));
	if (!cmd)
		return (NULL);
	cmd->args = NULL;
	cmd->redirs = NULL;
	cmd->next = NULL;
	return (cmd);
}

static void	add_redir(t_redir **redirs, t_token_type type, char *file)
{
	t_redir	*redir;
	t_redir	*current;

	redir = malloc(sizeof(t_redir));
	if (!redir)
		return ;
	redir->type = type;
	redir->file = ft_strdup(file);
	redir->next = NULL;
	if (!*redirs)
	{
		*redirs = redir;
		return ;
	}
	current = *redirs;
	while (current->next)
		current = current->next;
	current->next = redir;
}

static void	add_arg(char ***args, char *value)
{
	int		count;
	char	**new_args;
	int		i;

	count = 0;
	if (*args)
	{
		while ((*args)[count])
			count++;
	}
	new_args = malloc(sizeof(char *) * (count + 2));
	if (!new_args)
		return ;
	i = 0;
	while (i < count)
	{
		new_args[i] = (*args)[i];
		i++;
	}
	new_args[count] = ft_strdup(value);
	new_args[count + 1] = NULL;
	if (*args)
		free(*args);
	*args = new_args;
}

static t_cmd	*parse_single_cmd(t_token **tokens)
{
	t_cmd			*cmd;
	t_token_type	redir_type;

	cmd = create_cmd();
	if (!cmd)
		return (NULL);
	while (*tokens && (*tokens)->type != TOKEN_PIPE)
	{
		if ((*tokens)->type == TOKEN_WORD)
			add_arg(&cmd->args, (*tokens)->value);
		else if ((*tokens)->type >= TOKEN_REDIR_IN
			&& (*tokens)->type <= TOKEN_REDIR_HEREDOC)
		{
			redir_type = (*tokens)->type;
			*tokens = (*tokens)->next;
			if (!*tokens || (*tokens)->type != TOKEN_WORD)
			{
				error_msg("syntax error near redirection");
				return (cmd);
			}
			add_redir(&cmd->redirs, redir_type, (*tokens)->value);
		}
		*tokens = (*tokens)->next;
	}
	return (cmd);
}

t_cmd	*parser(t_token *tokens)
{
	t_cmd	*cmds;
	t_cmd	*current;
	t_cmd	*new_cmd;

	if (!tokens)
		return (NULL);
	cmds = parse_single_cmd(&tokens);
	current = cmds;
	while (tokens && tokens->type == TOKEN_PIPE)
	{
		tokens = tokens->next;
		if (!tokens)
		{
			error_msg("syntax error near pipe");
			return (cmds);
		}
		new_cmd = parse_single_cmd(&tokens);
		current->next = new_cmd;
		current = new_cmd;
	}
	return (cmds);
}

void	free_cmds(t_cmd *cmds)
{
	t_cmd	*tmp_cmd;
	t_redir	*tmp_redir;

	while (cmds)
	{
		tmp_cmd = cmds;
		cmds = cmds->next;
		if (tmp_cmd->args)
			ft_free_split(tmp_cmd->args);
		while (tmp_cmd->redirs)
		{
			tmp_redir = tmp_cmd->redirs;
			tmp_cmd->redirs = tmp_cmd->redirs->next;
			free(tmp_redir->file);
			free(tmp_redir);
		}
		free(tmp_cmd);
	}
}
