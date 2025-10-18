# Born2beRoot – Jeux de tests

- `./tests_realisation/run_tests.sh` : vérifications statiques (ShellCheck, cohérence Vagrant/provisioning). À exécuter sur l’hôte, aucune VM requise.
- `./tests_realisation/validate_vm.sh` : vérifie la configuration d’une VM démarrée (`vagrant up`) via `vagrant ssh`. Exige la variable `B2BR_LOGIN` si vous avez personnalisé le login.
- `./scripts/generate_signature.sh` : calcule l’empreinte SHA1 du disque virtuel (`born2beroot-lvm.vdi`) après arrêt de la VM ; rediriger la sortie vers `signature.txt`.
