#ifndef RL_WRAPPER_H
# define RL_WRAPPER_H

# ifdef MS_FORCE_READLINE
#  include <readline/readline.h>
#  include <readline/history.h>
#  define MS_USE_READLINE 1
# elif defined(__has_include)
#  if __has_include(<readline/readline.h>)
#   include <readline/readline.h>
#   include <readline/history.h>
#   define MS_USE_READLINE 1
#  endif
# endif

# if !defined(MS_USE_READLINE)
#  define MS_USE_READLINE 0
#  include <stddef.h>

char	*ms_rl_readline(const char *prompt);
void	ms_rl_add_history(const char *line);

#  define readline(prompt) ms_rl_readline(prompt)
#  define add_history(line) ms_rl_add_history(line)
#  define rl_on_new_line()
#  define rl_replace_line(line, count) (void)(line), (void)(count)
#  define rl_redisplay()
# endif

#endif
