# Born2beRoot

## Synthèse
Infrastructure reproductible pour le projet système « Born2beRoot » : un environnement Vagrant Debian 12 minimal sans interface graphique, durci selon le sujet (LVM, SSH sur 4242, UFW actif, politique de mots de passe stricte, configuration `sudo`, script de monitoring cron). Tous les réglages sont automatisés par des scripts de provisioning (bash) pouvant aussi être appliqués sur une machine installée manuellement.

## Architecture
- `Vagrantfile` : VM Debian Bookworm, deux disques (root + LVM chiffré), port 4242 exposé, provisioning shell.
- `provisioning/00-system-prep.sh` : installe dépendances, configure réseau, SSH, UFW, journaux `sudo`, politique de mot de passe (PAM), groupes et utilisateur courant.
- `provisioning/10-monitoring.sh` : installe `monitoring.sh`, active timer cron (`/etc/cron.d/monitoring`), crée répertoire `/var/log/sudo`.
- `provisioning/files/pwquality.conf`, `sudoers_born2beroot` : gabarits appliqués respectivement à `/etc/security/pwquality.conf` et `/etc/sudoers.d/born2beroot`.
- `scripts/monitoring.sh` : script demandé (bash POSIX) diffusant les métriques toutes les 10 min via `wall`.
- `scripts/apply_configuration.sh` : lance localement les scripts de provisioning sur une VM existante (pour usage hors Vagrant).
- `scripts/generate_signature.sh` : calcule l’empreinte SHA1 du disque virtuel pour alimenter `signature.txt`.
- `scripts/install_shellcheck.sh` : installation autonome de `shellcheck` pour les tests.
- `tests_realisation/run_tests.sh` : vérifications statiques (shellcheck + cohérence gabarits) et génération des instructions d’exécution.
- `Sujet_Born2beRoot.pdf` : sujet officiel (lien symbolique).

## Préparation VM
1. Installer VirtualBox ≥7 + Vagrant ≥2.3.
2. `cd C/Born2beRoot`
3. `vagrant up` (premier démarrage ~10 min, création du disque LVM secondaire de 10 Go).
4. Se connecter : `vagrant ssh -- -p 4242` (le login Vagrant par défaut est `vagrant`/`vagrant` mais l’utilisateur projet est votre login 42).

### Détails LVM chiffré
Le provisioning crée automatiquement :
- `/dev/sdb` → partition unique `sdb1`
- chiffrement LUKS (`cryptsetup luksFormat`, passphrase stockée dans `/root/.luks_passphrase`)
- groupe de volumes `born2beroot-vg` avec deux volumes logiques (`lv_var`, `lv_srv`)
- `lv_var` monté sur `/var`, `lv_srv` monté sur `/srv`
Une fois la VM montée, pensez à noter la passphrase et à la régénérer (script `provisioning/00-system-prep.sh` la stocke dans un fichier sécurisé).

## Rejouer la configuration
Sur une Debian/Ubuntu installée manuellement (sans Vagrant) :
```bash
sudo ./scripts/apply_configuration.sh
```
Chaque script est idempotent pour permettre plusieurs exécutions (utile après modifications).

## Gestion des utilisateurs & mots de passe
- Paramètres injectés via variables d’environnement lors du `vagrant up` :
  - `B2BR_LOGIN` (défaut `student`)
  - `B2BR_PASSWORD` (défaut `ChangeMe42!`)
  - `B2BR_ROOT_PASSWORD` (défaut `RootChangeMe42!`)
- Après provisionnement, changez tous les mots de passe (`passwd`, `passwd root`) pour respecter la politique (10+ caractères, majuscule, chiffre, etc.).
- L’utilisateur configuré est membre des groupes `user42` et `sudo` conformément au sujet.

## Commandes utiles
- Lancer le monitoring immédiatement : `sudo /usr/local/sbin/monitoring.sh`
- Vérifier la politique de mot de passe : `sudo chage -l <user>`
- Consulter les logs sudo : `sudo tail -f /var/log/sudo/commands.log`
- Vérifier UFW : `sudo ufw status verbose`
- Inspecter LVM/chiffrement : `lsblk`, `sudo cryptsetup status cryptlvm`

## Tests
```bash
./tests_realisation/run_tests.sh
```
Le script s’assure que `shellcheck` est disponible (install automatique via `scripts/install_shellcheck.sh` si besoin), exécute `shellcheck` sur les scripts, valide la syntaxe de la configuration `sudoers` et vérifie quelques invariants (port 4242, limites `passwd_tries`, etc.).

## signature.txt
1. Créer/mettre à jour la VM (`vagrant up`), puis l’arrêter (`vagrant halt`).
2. Générer l’empreinte SHA1 du disque :
   ```bash
   ./scripts/generate_signature.sh > signature.txt
   ```
   (ou préciser le chemin du disque : `./scripts/generate_signature.sh /chemin/vers/disk.vdi`)
3. Ajouter `signature.txt` à votre dépôt 42 conformément au sujet.

## PDF
- `Sujet_Born2beRoot.pdf` (module principal).
