2025-10-13 | Hello/hello_vue | DONE | Exercices ex00-ex05 fournis avec README et tests automatisés.
2025-10-13 | Web/hello_node | DONE | Implémentation des ex00-ex09 avec batterie de tests Node.js.
2025-10-13 | Wordle/Wordle | DONE | Jeu Wordle CLI en Python avec dictionnaire et tests unitaires.
2025-10-13 | Unix/A_completely_UNIX_project | DONE | Implémentation ft_nm/ft_otool avec Makefile, libft et tests automatisés.
2025-10-13 | Unix/A_rather_UNIX_project | DONE | ft_malloc (malloc/free/realloc/show_alloc_mem) avec bibliothèque partagée et tests LD_PRELOAD.
2025-10-13 | Unix/UNIX_Project | DONE | ft_strace (ptrace, syscalls 32/64 bits) avec tableaux générés et tests Python.
2025-10-13 | Unix/Projet_UNIX | DONE | Implantation du trojan Durex (daemon TCP, persistance simulée, tests automatiques).
2025-10-13 | Unix/UNIX_leaning_project | DONE | ft_select (termcaps, navigation multi-colonnes) avec tests pseudo-terminal.
2025-10-13 | C/Get_Next_Line | DONE | Fonction get_next_line multi-fd avec tests automatiques (fichier + stdin).
2025-10-13 | C/Pipex | DONE | Implémentation pipex (pipe/fork/exec avec analyse de commandes) et tests comparatifs.
2025-10-13 | C/Push_swap | DONE | push_swap complet (parsing, opérations, tri hybride + tests simulateur).
2025-10-13 | C/Libft | DONE | libft.a (parties 1 & 2 complètes) prête à l'usage avec Makefile.
2025-10-13 | C/So_Long | DONE | Rendu MiniLibX complet (sprites, déplacements, sortie), fallback headless et tests parsing.
2025-10-13 | C/Ft_server | DONE | Autoindex variable, WordPress/phpMyAdmin versions vérifiées (SHA256), WP-CLI install auto + durcissement entrypoint.
2025-10-13 | C/Born2beRoot | IN_PROGRESS | Provisioning complet (Vagrant + LVM chiffré, politique PAM/sudo, monitoring); reste validation VM et signature.
2025-10-18 | C/Born2beRoot | DONE | Ajout validation VM (vagrant), doc tests/signature et ShellCheck.
2025-10-18 | C/Minishell | IN_PROGRESS | Initialisation projet, plan détaillé et TODO pipeline minishell.
2025-10-18 | C/Minishell | IN_PROGRESS | Toolchain Makefile + boucle readline (stub getline) et signaux interactifs.
2025-10-18 | C/Minishell | IN_PROGRESS | Lexer tokens/pipes/redirs + quotes et expansions $VAR/$? intégrés.
2025-10-18 | C/Minishell | IN_PROGRESS | Parser AST pipeline+redir avec détection syntaxe (build OK, exécution à venir).
2025-10-18 | C/Minishell | IN_PROGRESS | Executor fork/exec + pipes/redirs (sans heredoc/builtins).
2025-10-18 | C/Minishell | IN_PROGRESS | Builtins (echo/pwd/env/exit) intégrés, exécution parentale avec redirections.
2025-10-18 | C/Minishell | IN_PROGRESS | Builtins cd/export/unset, export listing, env mutations persistants.
2025-10-18 | C/Minishell | IN_PROGRESS | Heredoc pré-collecté avant fork, signaux enfants rétablis, suites unit/e2e automatisées.
2025-10-18 | C/Minishell | IN_PROGRESS | Documentation alignée, harness Python (unit/e2e) opérationnel ; reste expansions avancées + valgrind/norme.
2025-10-18 | C/Minishell | IN_PROGRESS | Lancement implémentation expansions avancées (`~`, `export +=`, variables spéciales) avant campagne valgrind/norme.
2025-10-18 | C/Minishell | IN_PROGRESS | Expansions `~`, `~+`, `~-` et `export +=` finalisées avec tests unit/e2e ; prochaine étape valgrind + norme.
2025-10-18 | C/Minishell | IN_PROGRESS | Tentative valgrind (outil absent sur l'environnement) ; orientation vers build ASan/valgrind ultérieur.
2025-10-18 | C/Minishell | IN_PROGRESS | Build optionnel ASan (Makefile SANITIZE=address) + tests automatiques passés (LSan neutralisé via ASAN/LSAN_OPTIONS).
2025-10-18 | C/Minishell | IN_PROGRESS | Tentative norminette (outil absent) ; prévoir revue manuelle du style + exécution norminette lors d'un prochain accès.
2025-10-18 | C/Minishell | IN_PROGRESS | Lancement audit manuel norme 42 (repérage fonctions >25 lignes, découpage planifié avant refactor).
2025-10-18 | C/Minishell | IN_PROGRESS | Audit norme 42 : aucune fonction >25 lignes détectée dans `src/`; refacto ciblé non requis pour l'instant.
2025-10-18 | C/Minishell | IN_PROGRESS | Préparation refacto norme (ciblage fonctions à découper : lexer `collect_heredoc_input`, executor `apply_redirects` & pipeline).
2025-10-18 | C/Minishell | IN_PROGRESS | Analyse approfondie norme 42 : `collect_heredoc_input` (145 lignes), `apply_redirects` (36) et `execute_pipeline` (69) doivent être refactorées ; plan de découpe à définir.
2025-10-18 | C/Minishell | IN_PROGRESS | Plan refacto : scinder `collect_heredoc_input` (lecture, expansion, écriture), `apply_redirects` (dispatch par type) et `execute_pipeline` (setup, fork left/right, wait) avant implémentation.
2025-10-18 | C/Minishell | IN_PROGRESS | Lancement refacto norme : rédaction du plan d'extraction (helpers heredoc/pipeline) avant modifications du code.
