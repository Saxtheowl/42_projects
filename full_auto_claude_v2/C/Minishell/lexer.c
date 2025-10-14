/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   lexer.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

t_token	*create_token(t_token_type type, char *value)
{
	t_token	*token;

	token = malloc(sizeof(t_token));
	if (!token)
		return (NULL);
	token->type = type;
	token->value = value;
	token->next = NULL;
	return (token);
}

void	add_token(t_token **tokens, t_token *new_token)
{
	t_token	*current;

	if (!*tokens)
	{
		*tokens = new_token;
		return ;
	}
	current = *tokens;
	while (current->next)
		current = current->next;
	current->next = new_token;
}

void	free_tokens(t_token *tokens)
{
	t_token	*tmp;

	while (tokens)
	{
		tmp = tokens;
		tokens = tokens->next;
		free(tmp->value);
		free(tmp);
	}
}

static int	handle_quotes(char *line, int *i, char quote)
{
	int	start;

	start = *i;
	(*i)++;
	while (line[*i] && line[*i] != quote)
		(*i)++;
	if (line[*i] != quote)
	{
		error_msg("unclosed quote");
		return (-1);
	}
	(*i)++;
	return (start);
}

static char	*extract_word(char *line, int *i)
{
	int		start;
	int		len;
	char	*word;

	start = *i;
	len = 0;
	while (line[*i] && !ft_isspace(line[*i])
		&& line[*i] != '|' && line[*i] != '<' && line[*i] != '>')
	{
		if (line[*i] == '\'' || line[*i] == '"')
		{
			if (handle_quotes(line, i, line[*i]) == -1)
				return (NULL);
		}
		else
			(*i)++;
	}
	len = *i - start;
	word = ft_substr(line, start, len);
	return (word);
}

t_token	*lexer(char *line)
{
	t_token	*tokens;
	int		i;

	tokens = NULL;
	i = 0;
	while (line[i])
	{
		while (line[i] && ft_isspace(line[i]))
			i++;
		if (!line[i])
			break ;
		if (line[i] == '|')
			add_token(&tokens, create_token(TOKEN_PIPE, ft_strdup("|"))), i++;
		else if (line[i] == '<' && line[i + 1] == '<')
			add_token(&tokens, create_token(TOKEN_REDIR_HEREDOC, ft_strdup("<<"))), i += 2;
		else if (line[i] == '>' && line[i + 1] == '>')
			add_token(&tokens, create_token(TOKEN_REDIR_APPEND, ft_strdup(">>"))), i += 2;
		else if (line[i] == '<')
			add_token(&tokens, create_token(TOKEN_REDIR_IN, ft_strdup("<"))), i++;
		else if (line[i] == '>')
			add_token(&tokens, create_token(TOKEN_REDIR_OUT, ft_strdup(">"))), i++;
		else
			add_token(&tokens, create_token(TOKEN_WORD, extract_word(line, &i)));
	}
	return (tokens);
}
