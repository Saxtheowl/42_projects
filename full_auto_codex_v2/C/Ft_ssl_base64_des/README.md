# ft_ssl_base64_des

Statut : DONE

Dernière mise à jour (2026-01-17 01:04:55) : passage DONE (tests OK).

## Usage
```bash
./ft_ssl_base64_des base64 [-e|-d] [-i infile] [-o outfile] [-A]
./ft_ssl_base64_des des-ecb [-e|-d] [-i infile] [-o outfile] -k hexkey [-a] [-A]
./ft_ssl_base64_des des-cbc [-e|-d] [-i infile] [-o outfile] -k hexkey -v hexiv [-a] [-A]
```
- `-e` : encode (défaut)
- `-d` : decode
- `-i` : fichier d’entrée (sinon stdin)
- `-o` : fichier de sortie (sinon stdout)
- `-k` : clé hex 16 chars (DES)
- `-v` : IV hex 16 chars (CBC)
- `-a` : base64 en sortie (encrypt) ou entrée (decrypt) pour DES
- `-A` : pas de retour à la ligne en Base64 (wrap désactivé, comme `openssl base64 -A`)

## Build
```bash
make
```

## Tests
```bash
make test
```

## Notes
- Implémentations base64 et DES (ECB/CBC) en C pur, padding PKCS7, sous-clefs générées PC1/PC2 + 16 rounds Feistel.
- Option `-a` applique Base64 après encryption ou avant décryption; fichiers manquants/erreurs remontés avec code de sortie.
- Le script de tests compare base64 à `openssl base64`, valide DES ECB/CBC roundtrip et les modes `-a`.
