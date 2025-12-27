#include "ft_ssl.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_usage(void)
{
    fprintf(stderr, "usage:\n");
    fprintf(stderr, "  ft_ssl_base64_des base64 [-e|-d] [-i infile] [-o outfile]\n");
    fprintf(stderr, "                     [-A]\n");
    fprintf(stderr, "  ft_ssl_base64_des des-ecb [-e|-d] [-i infile] [-o outfile] -k hexkey [-a] [-A]\n");
    fprintf(stderr, "  ft_ssl_base64_des des-cbc [-e|-d] [-i infile] [-o outfile] -k hexkey -v hexiv [-a] [-A]\n");
}

static int open_in(const t_opts *opts, FILE **f)
{
    if (!opts->infile)
    {
        *f = stdin;
        return 0;
    }
    *f = fopen(opts->infile, "rb");
    if (!*f)
    {
        fprintf(stderr, "ft_ssl: %s: No such file or directory\n", opts->infile);
        return -1;
    }
    return 0;
}

static int open_out(const t_opts *opts, FILE **f)
{
    if (!opts->outfile)
    {
        *f = stdout;
        return 0;
    }
    *f = fopen(opts->outfile, "wb");
    if (!*f)
    {
        fprintf(stderr, "ft_ssl: %s: cannot open for write\n", opts->outfile);
        return -1;
    }
    return 0;
}

static int hex_to_bytes(const char *hex, unsigned char *out, size_t expected_len)
{
    size_t len = strlen(hex);
    if (len != expected_len * 2)
        return -1;
    for (size_t i = 0; i < expected_len; ++i)
    {
        unsigned int byte;
        if (sscanf(hex + 2 * i, "%2x", &byte) != 1)
            return -1;
        out[i] = (unsigned char)byte;
    }
    return 0;
}

int parse_args(int argc, char **argv, t_opts *opts)
{
    if (argc < 2)
        return -1;
    if (strcmp(argv[1], "base64") == 0)
        opts->cmd = CMD_BASE64;
    else if (strcmp(argv[1], "des-ecb") == 0)
        opts->cmd = CMD_DES_ECB;
    else if (strcmp(argv[1], "des-cbc") == 0)
        opts->cmd = CMD_DES_CBC;
    else
        return -1;

    opts->mode = MODE_ENCODE;
    opts->infile = NULL;
    opts->outfile = NULL;
    opts->use_base64 = 0;
    opts->wrap_base64 = 1;
    opts->have_key = 0;
    opts->have_iv = 0;
    opts->have_pass = 0;
    opts->have_salt = 0;

    for (int i = 2; i < argc; ++i)
    {
        if (strcmp(argv[i], "-e") == 0)
            opts->mode = MODE_ENCODE;
        else if (strcmp(argv[i], "-d") == 0)
            opts->mode = MODE_DECODE;
        else if (strcmp(argv[i], "-i") == 0 && i + 1 < argc)
            opts->infile = argv[++i];
        else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc)
            opts->outfile = argv[++i];
        else if (strcmp(argv[i], "-a") == 0)
            opts->use_base64 = 1;
        else if (strcmp(argv[i], "-A") == 0)
            opts->wrap_base64 = 0;
        else if (strcmp(argv[i], "-k") == 0 && i + 1 < argc)
        {
            if (hex_to_bytes(argv[++i], opts->key, 8) != 0)
                return -1;
            opts->have_key = 1;
        }
        else if (strcmp(argv[i], "-v") == 0 && i + 1 < argc)
        {
            if (hex_to_bytes(argv[++i], opts->iv, 8) != 0)
                return -1;
            opts->have_iv = 1;
        }
        else if (strcmp(argv[i], "-p") == 0 && i + 1 < argc)
        {
            opts->password = argv[++i];
            opts->have_pass = 1;
        }
        else if (strcmp(argv[i], "-s") == 0 && i + 1 < argc)
        {
            if (hex_to_bytes(argv[++i], opts->salt, 8) != 0)
                return -1;
            opts->have_salt = 1;
        }
        else
            return -1;
    }
    if (opts->cmd == CMD_DES_ECB || opts->cmd == CMD_DES_CBC)
    {
        if (!opts->have_key && !opts->have_pass)
            return -1;
        if (opts->cmd == CMD_DES_CBC && !opts->have_iv && !opts->have_pass)
            return -1;
        if (opts->have_pass && !opts->have_salt)
            memset((unsigned char *)opts->salt, 0, 8);
    }
    return 0;
}

int main(int argc, char **argv)
{
    t_opts opts;
    if (parse_args(argc, argv, &opts) != 0)
    {
        print_usage();
        return EXIT_FAILURE;
    }

    FILE *fin;
    if (open_in(&opts, &fin) != 0)
        return EXIT_FAILURE;
    unsigned char *input = NULL;
    size_t in_len = 0;
    if (read_all(fin, &input, &in_len) != 0)
    {
        fprintf(stderr, "ft_ssl: read error\n");
        if (fin != stdin)
            fclose(fin);
        return EXIT_FAILURE;
    }
    if (fin != stdin)
        fclose(fin);

    unsigned char *output = NULL;
    size_t out_len = 0;
    int ret = 0;

    unsigned char subkeys_enc[16][6];
    unsigned char subkeys_dec[16][6];
    if (opts.cmd == CMD_DES_ECB || opts.cmd == CMD_DES_CBC)
    {
        /* decode path: handle base64 + salted header before deriving subkeys */
        unsigned char *cipher_buf = input;
        size_t cipher_len = in_len;
        if (opts.mode == MODE_DECODE && opts.use_base64)
        {
            unsigned char *cipher = NULL;
            size_t decoded_len = 0;
            if (base64_decode(input, in_len, &cipher, &decoded_len) != 0)
            {
                fprintf(stderr, "ft_ssl: base64 processing failed\n");
                free(input);
                return EXIT_FAILURE;
            }
            free(input);
            input = cipher;
            cipher_buf = input;
            cipher_len = decoded_len;
        }
        size_t offset = 0;
        if (opts.mode == MODE_DECODE && has_salted_header(cipher_buf, cipher_len) && !opts.have_key)
        {
            if (!opts.password)
            {
                fprintf(stderr, "ft_ssl: bad decrypt (password missing)\n");
                free(input);
                return EXIT_FAILURE;
            }
            memcpy(opts.salt, cipher_buf + 8, 8);
            derive_key_iv_md5(opts.password ? opts.password : "", opts.salt, opts.key, opts.iv);
            opts.have_key = 1;
            opts.have_iv = 1;
            offset = 16;
            cipher_buf += offset;
            cipher_len -= offset;
            offset = 0;
        }
        if (opts.mode == MODE_ENCODE && opts.have_pass && !opts.have_salt)
        {
            generate_salt((unsigned char *)opts.salt);
            opts.have_salt = 1;
        }
        if (opts.have_pass && !opts.have_key)
        {
            derive_key_iv_md5(opts.password, opts.salt, opts.key, opts.iv);
            opts.have_key = 1;
            opts.have_iv = 1;
        }
        des_derive_subkeys(opts.key, subkeys_enc, subkeys_dec);

        if (opts.mode == MODE_ENCODE)
        {
            size_t padded_len = des_pkcs7_pad(&input, in_len);
            if (padded_len == 0)
            {
                fprintf(stderr, "ft_ssl: pad failed\n");
                return EXIT_FAILURE;
            }
            in_len = padded_len;
            output = malloc(in_len + (opts.have_pass ? 16 : 0));
            if (!output)
                return EXIT_FAILURE;
            unsigned char *cipher_out = output;
            size_t cipher_len = in_len;
            if (opts.have_pass)
            {
                memcpy(cipher_out, "Salted__", 8);
                memcpy(cipher_out + 8, opts.salt, 8);
                cipher_out += 16;
            }
            if (opts.cmd == CMD_DES_ECB)
                des_encrypt_buffer(input, in_len, cipher_out, subkeys_enc);
            else
                des_cbc_process(input, in_len, cipher_out, subkeys_enc, opts.iv, 0);
            out_len = cipher_len + (opts.have_pass ? 16 : 0);
            if (opts.use_base64)
            {
                unsigned char *b64 = NULL;
                size_t b64_len = 0;
                if (base64_encode(output, out_len, &b64, &b64_len) != 0)
                {
                    free(output);
                    free(input);
                    fprintf(stderr, "ft_ssl: base64 processing failed\n");
                    return EXIT_FAILURE;
                }
                free(output);
                output = b64;
                out_len = b64_len;
            }
            free(input);
        }
        else
        {
            if ((cipher_len - offset) % 8 != 0)
            {
                fprintf(stderr, "ft_ssl: bad decrypt\n");
                free(input);
                return EXIT_FAILURE;
            }
            output = malloc(cipher_len - offset);
            if (!output)
            {
                if (cipher_buf != input)
                    free(cipher_buf);
                else
                    free(input);
                return EXIT_FAILURE;
            }
            if (opts.cmd == CMD_DES_ECB)
                des_decrypt_buffer(cipher_buf + offset, cipher_len - offset, output, subkeys_dec);
            else
                des_cbc_process(cipher_buf + offset, cipher_len - offset, output, subkeys_dec, opts.iv, 1);
            out_len = cipher_len - offset;
            if (remove_pkcs7(output, &out_len) != 0)
            {
                fprintf(stderr, "ft_ssl: bad decrypt\n");
                free(input);
                free(output);
                return EXIT_FAILURE;
            }
            free(input);
        }
    }
    else
    {
        if (opts.mode == MODE_ENCODE)
            ret = base64_encode(input, in_len, &output, &out_len);
        else
            ret = base64_decode(input, in_len, &output, &out_len);
        free(input);
        if (ret != 0)
        {
            fprintf(stderr, "ft_ssl: base64 processing failed\n");
            return EXIT_FAILURE;
        }
    }

    FILE *fout;
    if (open_out(&opts, &fout) != 0)
    {
        free(output);
        return EXIT_FAILURE;
    }
    int write_status = 0;
    if (opts.cmd == CMD_BASE64 && opts.mode == MODE_ENCODE)
    {
        if (opts.wrap_base64)
            write_status = write_base64_wrapped(fout, output, out_len);
        else
            write_status = write_all(fout, output, out_len);
    }
    else if (opts.use_base64 && (opts.cmd == CMD_DES_ECB || opts.cmd == CMD_DES_CBC))
    {
        if (opts.wrap_base64)
            write_status = write_base64_wrapped(fout, output, out_len);
        else
            write_status = write_all(fout, output, out_len);
    }
    else
        write_status = write_all(fout, output, out_len);
    if (write_status != 0)
    {
        fprintf(stderr, "ft_ssl: write error\n");
        if (fout != stdout)
            fclose(fout);
        free(output);
        return EXIT_FAILURE;
    }
    if (fout != stdout)
        fclose(fout);
    free(output);
    return EXIT_SUCCESS;
}
