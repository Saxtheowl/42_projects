/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parser.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
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
	cmd->argc = 0;
	cmd->redir = NULL;
	cmd->next = NULL;
	return (cmd);
}

static void	add_arg(t_cmd *cmd, char *arg)
{
	char	**new_args;
	int		i;

	new_args = malloc((cmd->argc + 2) * sizeof(char *));
	if (!new_args)
		return ;
	i = 0;
	while (i < cmd->argc)
	{
		new_args[i] = cmd->args[i];
		i++;
	}
	new_args[i++] = ft_strdup(arg);
	new_args[i] = NULL;
	free(cmd->args);
	cmd->args = new_args;
	cmd->argc++;
}

static void	add_redir(t_cmd *cmd, t_token_type type, char *file)
{
	t_redir	*redir;
	t_redir	*curr;

	redir = malloc(sizeof(t_redir));
	if (!redir)
		return ;
	redir->type = type;
	redir->file = ft_strdup(file);
	redir->next = NULL;
	if (!cmd->redir)
	{
		cmd->redir = redir;
		return ;
	}
	curr = cmd->redir;
	while (curr->next)
		curr = curr->next;
	curr->next = redir;
}

void	free_redir(t_redir *redir)
{
	t_redir	*next;

	while (redir)
	{
		next = redir->next;
		free(redir->file);
		free(redir);
		redir = next;
	}
}

void	free_cmds(t_cmd *cmds)
{
	t_cmd	*next;
	int		i;

	while (cmds)
	{
		next = cmds->next;
		if (cmds->args)
		{
			i = 0;
			while (cmds->args[i])
				free(cmds->args[i++]);
			free(cmds->args);
		}
		free_redir(cmds->redir);
		free(cmds);
		cmds = next;
	}
}

static int	is_redir(t_token_type type)
{
	return (type == TOKEN_REDIR_IN || type == TOKEN_REDIR_OUT
		|| type == TOKEN_APPEND || type == TOKEN_HEREDOC);
}

static t_token	*parse_cmd(t_token *token, t_cmd **cmd)
{
	*cmd = create_cmd();
	if (!*cmd)
		return (NULL);
	while (token && token->type != TOKEN_PIPE)
	{
		if (is_redir(token->type))
		{
			if (!token->next || token->next->type != TOKEN_WORD)
			{
				fprintf(stderr, "minishell: syntax error near redirection\n");
				return (NULL);
			}
			add_redir(*cmd, token->type, token->next->value);
			token = token->next->next;
		}
		else if (token->type == TOKEN_WORD)
		{
			add_arg(*cmd, token->value);
			token = token->next;
		}
		else
			break ;
	}
	return (token);
}

t_cmd	*parser(t_token *tokens)
{
	t_cmd	*head;
	t_cmd	*current;
	t_cmd	*new_cmd;

	head = NULL;
	current = NULL;
	while (tokens)
	{
		tokens = parse_cmd(tokens, &new_cmd);
		if (!new_cmd)
		{
			free_cmds(head);
			return (NULL);
		}
		if (!head)
			head = new_cmd;
		else
			current->next = new_cmd;
		current = new_cmd;
		if (tokens && tokens->type == TOKEN_PIPE)
			tokens = tokens->next;
	}
	return (head);
}
