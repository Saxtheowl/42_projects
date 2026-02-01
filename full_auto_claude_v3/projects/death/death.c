/* ************************************************************************** */
/*                                                                            */
/*   death - Exception and Signal Handling                                    */
/*   Robust error handling and crash recovery demonstration                   */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <unistd.h>
#include <execinfo.h>
#include <errno.h>

#define MAX_STACK_FRAMES 64

/* Jump buffer for recovery */
static sigjmp_buf	g_jump_buffer;
static volatile sig_atomic_t	g_in_handler = 0;

/* ============================================================ */
/* Stack Trace                                                   */
/* ============================================================ */

void	print_stack_trace(void)
{
	void	*frames[MAX_STACK_FRAMES];
	int		frame_count;
	char	**symbols;
	int		i;

	frame_count = backtrace(frames, MAX_STACK_FRAMES);
	symbols = backtrace_symbols(frames, frame_count);

	if (symbols == NULL)
	{
		fprintf(stderr, "Failed to get stack trace\n");
		return;
	}

	fprintf(stderr, "\n=== Stack Trace ===\n");
	for (i = 0; i < frame_count; i++)
	{
		fprintf(stderr, "  [%d] %s\n", i, symbols[i]);
	}
	fprintf(stderr, "===================\n\n");

	free(symbols);
}

/* ============================================================ */
/* Signal Handler                                                */
/* ============================================================ */

const char	*signal_name(int sig)
{
	switch (sig)
	{
		case SIGSEGV: return "SIGSEGV (Segmentation fault)";
		case SIGFPE:  return "SIGFPE (Floating point exception)";
		case SIGILL:  return "SIGILL (Illegal instruction)";
		case SIGBUS:  return "SIGBUS (Bus error)";
		case SIGABRT: return "SIGABRT (Abort)";
		case SIGINT:  return "SIGINT (Interrupt)";
		case SIGTERM: return "SIGTERM (Termination)";
		default:      return "Unknown signal";
	}
}

void	fatal_signal_handler(int sig, siginfo_t *info, void *context)
{
	(void)context;

	/* Prevent recursive signals */
	if (g_in_handler)
	{
		_exit(128 + sig);
	}
	g_in_handler = 1;

	fprintf(stderr, "\n");
	fprintf(stderr, "╔════════════════════════════════════════╗\n");
	fprintf(stderr, "║           FATAL ERROR CAUGHT           ║\n");
	fprintf(stderr, "╚════════════════════════════════════════╝\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "Signal: %d - %s\n", sig, signal_name(sig));

	if (info)
	{
		fprintf(stderr, "Fault address: %p\n", info->si_addr);
		fprintf(stderr, "Sending PID: %d\n", info->si_pid);
		fprintf(stderr, "Sending UID: %d\n", info->si_uid);
	}

	print_stack_trace();

	/* Try to recover */
	siglongjmp(g_jump_buffer, sig);
}

void	setup_signal_handlers(void)
{
	struct sigaction	sa;

	memset(&sa, 0, sizeof(sa));
	sa.sa_sigaction = fatal_signal_handler;
	sa.sa_flags = SA_SIGINFO | SA_RESTART;
	sigemptyset(&sa.sa_mask);

	sigaction(SIGSEGV, &sa, NULL);
	sigaction(SIGFPE, &sa, NULL);
	sigaction(SIGILL, &sa, NULL);
	sigaction(SIGBUS, &sa, NULL);
	sigaction(SIGABRT, &sa, NULL);
}

/* ============================================================ */
/* Try-Catch Macros                                              */
/* ============================================================ */

#define TRY \
	do { \
		int __sig = sigsetjmp(g_jump_buffer, 1); \
		g_in_handler = 0; \
		if (__sig == 0) {

#define CATCH(sig_var) \
		} else { \
			int sig_var = __sig;

#define END_TRY \
		} \
	} while(0)

/* ============================================================ */
/* Demo Functions                                                */
/* ============================================================ */

void	cause_segfault(void)
{
	int	*ptr = NULL;
	*ptr = 42;  /* BOOM! */
}

void	cause_div_zero(void)
{
	volatile int	a = 42;
	volatile int	b = 0;
	volatile int	c = a / b;  /* BOOM! */
	(void)c;
}

/* Stack overflow demo removed - causes -Werror=infinite-recursion */

void	safe_operation(void)
{
	printf("This operation is safe.\n");
	printf("Doing some work...\n");
	for (int i = 0; i < 3; i++)
	{
		printf("  Step %d complete\n", i + 1);
	}
	printf("Safe operation finished.\n");
}

/* ============================================================ */
/* Resource Management                                           */
/* ============================================================ */

typedef struct s_resource
{
	int		fd;
	void	*memory;
	char	*name;
}	t_resource;

t_resource	*resource_stack[100];
int			resource_count = 0;

void	push_resource(t_resource *res)
{
	if (resource_count < 100)
		resource_stack[resource_count++] = res;
}

void	cleanup_resources(void)
{
	printf("Cleaning up %d resources...\n", resource_count);
	while (resource_count > 0)
	{
		t_resource *res = resource_stack[--resource_count];
		printf("  Freeing: %s\n", res->name);
		if (res->memory)
			free(res->memory);
		free(res->name);
		free(res);
	}
}

/* ============================================================ */
/* Main Demo                                                     */
/* ============================================================ */

int	main(int argc, char **argv)
{
	int	test_case = 0;

	printf("death - Exception and Signal Handling Demo\n");
	printf("===========================================\n\n");

	if (argc > 1)
		test_case = atoi(argv[1]);

	/* Setup signal handlers */
	setup_signal_handlers();

	/* Register cleanup */
	atexit(cleanup_resources);

	/* Allocate some resources */
	t_resource *res1 = malloc(sizeof(t_resource));
	res1->memory = malloc(1024);
	res1->name = strdup("Resource 1");
	res1->fd = -1;
	push_resource(res1);

	t_resource *res2 = malloc(sizeof(t_resource));
	res2->memory = malloc(2048);
	res2->name = strdup("Resource 2");
	res2->fd = -1;
	push_resource(res2);

	printf("Allocated 2 resources\n\n");

	/* Test different crash scenarios */
	switch (test_case)
	{
		case 1:
			printf("[Test 1] Causing segmentation fault...\n\n");
			TRY
			{
				cause_segfault();
				printf("This line should not execute\n");
			}
			CATCH(sig)
			{
				printf("\n>>> RECOVERED from signal %d <<<\n\n", sig);
				printf("Continuing after crash...\n");
			}
			END_TRY;
			break;

		case 2:
			printf("[Test 2] Causing division by zero...\n\n");
			TRY
			{
				cause_div_zero();
				printf("This line should not execute\n");
			}
			CATCH(sig)
			{
				printf("\n>>> RECOVERED from signal %d <<<\n\n", sig);
			}
			END_TRY;
			break;

		case 3:
			printf("[Test 3] Safe operation (no crash)...\n\n");
			TRY
			{
				safe_operation();
			}
			CATCH(sig)
			{
				printf("Unexpected signal: %d\n", sig);
			}
			END_TRY;
			break;

		default:
			printf("Usage: %s <test_number>\n", argv[0]);
			printf("\nTests:\n");
			printf("  1 - Segmentation fault recovery\n");
			printf("  2 - Division by zero recovery\n");
			printf("  3 - Safe operation (no crash)\n");
			printf("\nFeatures demonstrated:\n");
			printf("  - Signal handling with sigaction\n");
			printf("  - Stack trace printing with backtrace\n");
			printf("  - Recovery using setjmp/longjmp\n");
			printf("  - Resource cleanup with atexit\n");
			printf("  - TRY-CATCH macros for C\n");
			break;
	}

	printf("\nProgram completed successfully.\n");
	return (0);
}
