#ifndef FT_SSL_H
#define FT_SSL_H

#include <stddef.h>
#include <stdio.h>

typedef enum e_mode
{
    MODE_ENCODE,
    MODE_DECODE
}   t_mode;

typedef enum e_cmd
{
    CMD_BASE64,
    CMD_DES_ECB,
    CMD_DES_CBC
}   t_cmd;

typedef struct s_opts
{
    t_cmd       cmd;
    t_mode      mode;
    const char  *infile;
    const char  *outfile;
    int         use_base64;
    int         wrap_base64;
    unsigned char key[8];
    unsigned char iv[8];
    int         have_key;
    int         have_iv;
    int         have_pass;
    const char  *password;
    int         have_salt;
    unsigned char salt[8];
}   t_opts;

int     parse_args(int argc, char **argv, t_opts *opts);
int     base64_encode(const unsigned char *in, size_t in_len, unsigned char **out, size_t *out_len);
int     base64_decode(const unsigned char *in, size_t in_len, unsigned char **out, size_t *out_len);
int     read_all(FILE *f, unsigned char **buf, size_t *len);
int     write_all(FILE *f, const unsigned char *buf, size_t len);
int     write_base64_wrapped(FILE *f, const unsigned char *buf, size_t len);

void    des_encrypt_buffer(const unsigned char *in, size_t len, unsigned char *out, const unsigned char subkeys[16][6]);
void    des_decrypt_buffer(const unsigned char *in, size_t len, unsigned char *out, const unsigned char subkeys[16][6]);
int     des_derive_subkeys(const unsigned char key[8], unsigned char subkeys_enc[16][6], unsigned char subkeys_dec[16][6]);
void    des_cbc_process(const unsigned char *in, size_t len, unsigned char *out, const unsigned char subkeys[16][6], const unsigned char iv[8], int decrypt);
size_t  des_pkcs7_pad(unsigned char **buf, size_t len);
int     remove_pkcs7(unsigned char *buf, size_t *len);
int     derive_key_iv_md5(const char *password, const unsigned char *salt, unsigned char key[8], unsigned char iv[8]);
int     generate_salt(unsigned char salt[8]);
int     has_salted_header(const unsigned char *buf, size_t len);

#endif
