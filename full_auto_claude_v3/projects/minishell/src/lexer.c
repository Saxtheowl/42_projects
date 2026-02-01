/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   lexer.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static t_token	*create_token(t_token_type type, char *value)
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

static void	add_token(t_token **head, t_token *new)
{
	t_token	*curr;

	if (!*head)
	{
		*head = new;
		return ;
	}
	curr = *head;
	while (curr->next)
		curr = curr->next;
	curr->next = new;
}

void	free_tokens(t_token *tokens)
{
	t_token	*next;

	while (tokens)
	{
		next = tokens->next;
		free(tokens->value);
		free(tokens);
		tokens = next;
	}
}

static char	*get_quoted_str(char **input, char quote, t_shell *shell)
{
	char	*start;
	char	*result;
	char	*expanded;
	size_t	len;

	(*input)++;
	start = *input;
	len = 0;
	while (**input && **input != quote)
	{
		(*input)++;
		len++;
	}
	if (**input == quote)
		(*input)++;
	result = ft_substr(start, 0, len);
	if (quote == '"' && result)
	{
		expanded = expand_vars(result, shell);
		free(result);
		return (expanded);
	}
	return (result);
}

static char	*get_word(char **input, t_shell *shell)
{
	char	*result;
	char	*part;
	char	*tmp;

	result = ft_strdup("");
	while (**input && !ft_isspace(**input)
		&& **input != '|' && **input != '<' && **input != '>')
	{
		if (**input == '\'' || **input == '"')
		{
			part = get_quoted_str(input, **input, shell);
		}
		else
		{
			tmp = *input;
			while (**input && !ft_isspace(**input) && **input != '|'
				&& **input != '<' && **input != '>'
				&& **input != '\'' && **input != '"')
				(*input)++;
			part = ft_substr(tmp, 0, *input - tmp);
			tmp = expand_vars(part, shell);
			free(part);
			part = tmp;
		}
		tmp = ft_strjoin(result, part);
		free(result);
		free(part);
		result = tmp;
	}
	return (result);
}

static int	lex_operator(char **input, t_token **tokens)
{
	t_token	*tok;

	if (**input == '|')
	{
		tok = create_token(TOKEN_PIPE, ft_strdup("|"));
		(*input)++;
	}
	else if (**input == '<' && *(*input + 1) == '<')
	{
		tok = create_token(TOKEN_HEREDOC, ft_strdup("<<"));
		*input += 2;
	}
	else if (**input == '>' && *(*input + 1) == '>')
	{
		tok = create_token(TOKEN_APPEND, ft_strdup(">>"));
		*input += 2;
	}
	else if (**input == '<')
	{
		tok = create_token(TOKEN_REDIR_IN, ft_strdup("<"));
		(*input)++;
	}
	else if (**input == '>')
	{
		tok = create_token(TOKEN_REDIR_OUT, ft_strdup(">"));
		(*input)++;
	}
	else
		return (0);
	add_token(tokens, tok);
	return (1);
}

t_token	*lexer(char *input, t_shell *shell)
{
	t_token	*tokens;
	t_token	*tok;
	char	*word;

	tokens = NULL;
	while (*input)
	{
		while (ft_isspace(*input))
			input++;
		if (!*input)
			break ;
		if (lex_operator(&input, &tokens))
			continue ;
		word = get_word(&input, shell);
		if (!word || !*word)
		{
			free(word);
			continue ;
		}
		tok = create_token(TOKEN_WORD, word);
		add_token(&tokens, tok);
	}
	return (tokens);
}
