#ifndef OP_H
#define OP_H

#define MEM_SIZE        (4 * 1024)
#define IDX_MOD         512
#define CHAMP_MAX_SIZE  (MEM_SIZE / 6)

#define PROG_NAME_LENGTH    128
#define COMMENT_LENGTH      2048

#define CYCLE_TO_DIE    1536
#define CYCLE_DELTA     50
#define NBR_LIVE        21

#define REG_NUMBER      16

#define COREWAR_EXEC_MAGIC 0x00EA83F3

#ifndef TRUE
# define TRUE 1
#endif
#ifndef FALSE
# define FALSE 0
#endif

#define T_REG   1
#define T_DIR   2
#define T_IND   4

typedef struct  s_header
{
    unsigned int    magic;
    char            prog_name[PROG_NAME_LENGTH + 1];
    unsigned int    prog_size;
    char            comment[COMMENT_LENGTH + 1];
}               t_header;

#endif
