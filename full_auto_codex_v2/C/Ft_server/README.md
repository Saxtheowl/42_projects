# ft_server

## Synthèse
Image Docker Debian Buster autonome fournissant un stack complet Nginx + MariaDB + PHP-FPM pour héberger WordPress et phpMyAdmin en HTTPS (certificat auto-signé). À chaque démarrage, l’entrypoint :
- applique dynamiquement l’autoindex souhaité (`AUTO_INDEX=on|off`) avant de lancer Nginx,
- initialise/renforce MariaDB (mot de passe root, base + utilisateur dédiés),
- télécharge WordPress/phpMyAdmin aux versions verrouillées (SHA256 vérifiées), génère les secrets, puis installe WordPress via WP-CLI,
- démarre PHP-FPM et remet la main au processus `nginx -g 'daemon off;'`.

## Architecture
- `Dockerfile` : construction de l’image, installation paquets (gettext/envsubst, wp-cli), génération certificat SSL.
- `srcs/entrypoint.sh` : orchestration des services et provisionning (autoindex, DB, WordPress, phpMyAdmin).
- `srcs/nginx.conf.template` : template Nginx avec placeholder `AUTO_INDEX`.
- `Sujet_Ft_server.pdf` : sujet officiel.
- `progress_notes.txt` : journal interne d’avancement.

## Variables & comportements
| Variable | Rôle | Valeur par défaut |
|----------|------|-------------------|
| `AUTO_INDEX` | Active/désactive l’autoindex nginx (`on`/`off`). | `off` |
| `MYSQL_ROOT_PASSWORD` | Mot de passe root MariaDB (obligatoire à redéfinir en prod). | `changeme` |
| `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` | Base et compte applicatif WordPress. | `wordpress`, `wp_user`, `wp_password` |
| `WORDPRESS_VERSION` / `WORDPRESS_SHA256` | Version et empreinte vérifiée de WordPress. | `6.5.3`, `526c0ff9...ca6c` |
| `PHPMYADMIN_VERSION` / `PHPMYADMIN_SHA256` | Version + SHA256 de phpMyAdmin. | `5.2.1`, `61c763f2...1c46` |
| `WORDPRESS_URL`, `WORDPRESS_TITLE`, `WORDPRESS_ADMIN_*` | Paramétrage WP-CLI (URL, titre, admin). | `https://localhost`, `ft_server`, `admin/...` |

Les valeurs ci-dessus sont sûres pour un environnement de test mais doivent être surchargées pour une exposition réelle.

## Construction & exécution
```bash
cd C/Ft_server
docker build -t ft_server .

# Exemple : autoindex activé + mots de passe personnalisés
docker run -it --rm \
  -e AUTO_INDEX=on \
  -e MYSQL_ROOT_PASSWORD=supersecret \
  -e MYSQL_PASSWORD=wp_secret \
  -e WORDPRESS_ADMIN_PASSWORD=ChangeMe42! \
  -p 80:80 -p 443:443 \
  ft_server
```
À la première exécution, l’entrypoint télécharge WordPress/phpMyAdmin, génère `wp-config.php` et réalise l’installation WP (admin créé automatiquement). Les fichiers restent persistants dans l’image conteneurisée ; montez un volume sur `/var/www/html` si nécessaire pour la persistance.

## Tests manuels rapides
1. Construire l’image (voir ci-dessus).
2. Lancer le conteneur et attendre les logs `WordPress already configured`.
3. Vérifier :
   - https://localhost (WordPress opérationnel, certificat auto-signé à accepter),
   - https://localhost/phpmyadmin (accès phpMyAdmin, autoindex respecté selon `AUTO_INDEX`),
   - `wp-config.php` contient la bonne URL + salts uniques.

## Notes de sécurité
- Les téléchargements WordPress/phpMyAdmin sont systématiquement contrôlés via SHA256.
- MariaDB est initialisé avec un mot de passe root et un utilisateur dédié au site.
- phpMyAdmin reçoit une `blowfish_secret` aléatoire.
- Le binaire WP-CLI est embarqué pour éviter l’exécution via la web UI.
