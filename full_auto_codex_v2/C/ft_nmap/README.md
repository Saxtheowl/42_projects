# ft_nmap

 Dernière mise à jour : 2025-12-26 20:58:33

Scanner TCP minimal qui tente des connexions non bloquantes (poll + lots inflight) sur une liste de ports et signale ceux qui répondent dans le délai imparti. Résolution DNS effectuée une seule fois puis réutilisée pour chaque port. Export JSON optionnel. Inclut un mode “dry-run” (`-n`) qui se limite à la résolution DNS/override et laisse les ports en `pending/unknown` pour valider la configuration sans toucher au réseau.

## Usage

```
./ft_nmap -t target [-p ports|-P file|-k top] [-x ports|-X file] [-F|-f count] [-T timeout_ms] [-c inflight] [-R retries] [-b backoff_pct] [-w delay_ms] [-M deadline_ms] [-q] [-S] [-l] [-r] [-e seed] [-g progress_ms] [-u stop_timeouts] [-I ip_override] [-n] [-4|-6] [-o file.json] [-J summary.json] [-C file.csv] [-N file.ndjson] [-Y file.yaml] [-Z file.xml] [-H file.html] [-m file.md] [-L open_list] [-E export_filter] [-Q] [-V]
```

- `-t <host>` : cible obligatoire (hostname ou IPv4/IPv6).
- `-p <liste>` : ports séparés par des virgules ou des plages `start-end` (`22,80-90,443`). Par défaut : 1-1024.
- `-P <fichier>` : fichier contenant des ports/plages séparés par espaces/virgules/nouvelles lignes (le dernier `-p`/`-P` rencontré l’emporte). `-P -` lit depuis stdin (ex: `echo 22 | ft_nmap -P - ...`).
- `-k <n>` : scan des `<n>` ports TCP les plus courants (liste embarquée). Idéal pour un balayage rapide sans préciser les ports.
- `-x <liste>` : exclut des ports/plages de la liste finale à scanner (appliqué après `-p/-P`).
- `-X <fichier>` : exclut les ports/plages provenant d’un fichier (ou de stdin via `-X -`). Le dernier `-x/-X` l’emporte. Les stats JSON/CSV mentionnent le nombre de ports exclus.
- `-F` : arrête le scan dès le premier port OPEN trouvé (utile pour un “ping” TCP rapide). Le compteur “scanned” reflète uniquement les ports réellement traités.
- `-f <n>` : arrête le scan après `<n>` ports OPEN trouvés, marque les ports restants en `pending/unknown` dans les stats/exports.
- `-T <ms>` : timeout en millisecondes par tentative (défaut 500 ms).
- `-c <n>` : connexions simultanées (1-1024, défaut 256).
- `-R <n>` : nombre de retries sur TIMEOUT avant de considérer le port fermé (0-5, défaut 0).
- `-b <pct>` : augmente le timeout de `pct%%` pour chaque retry (backoff croissant). Exemple `-R 2 -b 50` donne des timeouts de 500ms, puis 750ms, puis 1000ms.
- `-w <ms>` : délai entre les cycles de poll (en millisecondes) pour limiter le rythme des batches (0-60000). Exporté dans les stats via `delay_ms`.
- `-M <ms>` : durée maximale du scan (en millisecondes). Dès que la limite est atteinte, tous les sockets actifs sont clos comme TIMEOUT, les ports restants passent en statut `unknown` (champ `pending` dans les stats) et les exports portent le flag `deadline_hit`.
- `-q` : silencieux (résumé uniquement).
- `-O` : n’affiche que les ports ouverts dans les sorties par port et dans le tableau.
- `-S` : affiche le service connu (getservbyport) pour les ports ouverts.
- `-l` : imprime un tableau récapitulatif après le scan.
- `-r` : randomise l’ordre des ports avant le scan; `-e <seed>` fixe la seed RNG pour rejouer exactement le même shuffle (implique `-r`).
- `-g <ms>` : imprime périodiquement la progression (scanned/open/closed/timeouts/active/pending) vers stderr toutes les `<ms>` millisecondes (utile pour suivre un scan long).
- `-u <n>` : arrête le scan après `<n>` timeouts, marque les ports restants en `pending/unknown` et trace le hit dans le résumé/stats.
- `-I <ip>` : force l’IP à scanner (bypass DNS) tout en conservant le target dans les exports/résumés.
- `-n` : mode “dry-run” qui se limite à la résolution DNS/override, ne crée aucun socket et laisse les ports en `pending/unknown` (flag `dry_run` dans les exports).
- `-4/-6` : force l’usage IPv4 ou IPv6 uniquement (par défaut les deux).
- `-o <f>` : exporte le résultat complet en JSON (ports + stats).
- `-J <f>` : exporte uniquement les stats en JSON (pas de liste de ports), utile pour un payload léger/monitoring.
- `-C <f>` : exporte aussi en CSV (ports + stats en en-tête).
- `-N <f>` : export NDJSON (une ligne JSON par port scanné, triées par port).
- `-Y <f>` : export YAML lisible (ports + stats regroupées).
- `-Z <f>` : export XML structuré (balises `<stats>` et `<port>` avec attributs, compatible parsers standards).
- `-H <f>` : export HTML autonome (stats en cartes et table des ports).
- `-m <f>` : export Markdown (rapport lisible en table markdown).
- `-L <f>` : écrit uniquement la liste des ports OPEN (un par ligne, ajoute le service si `-S`).
- `-E <filter>` : filtre les ports exportés (`all` par défaut, `open` pour ne garder que les ports OPEN, `known` pour exclure les pending/unknown) pour tous les formats (JSON/CSV/YAML/HTML/NDJSON/Markdown). Les rapports incluent aussi la version de ft_nmap pour tracer la provenance.
- `-Q` : envoie le résumé final (et le tableau) vers stderr, pratique pour garder stdout propre lors d’exports vers `-`.
- `-V` : affiche la version puis quitte.
- Pour tous les exports, passer `-` comme chemin écrit sur stdout. Lorsqu’un export stdout est demandé, le résumé est automatiquement redirigé vers stderr pour éviter de mélanger le flux texte et le format choisi.

La commande imprime `host:port open` (optionnellement avec le service) pour chaque port accessible et un résumé final incluant les ports ouverts/fermés/timeouts ainsi que le débit, avec jusqu’à 1024 connexions simultanées (256 par défaut). Le tableau (`-l`) et les lignes “live” indiquent désormais le nombre de retries et la durée mesurée. Avec `-o`/`-J`/`-C`/`-Y`/`-Z`/`-H`/`-m`, un fichier JSON (complet ou stats-only)/CSV/YAML/XML/HTML/Markdown liste les ports (ou uniquement les stats pour `-J`) et les stats globales, en incluant les timestamps de début/fin (millisecondes epoch), les durées min/max/moyenne/p50/p90/p99, le nombre de ports demandés/scannés/pending, le délai inter-batch (`delay_ms`), les taux `open_rate/closed_rate/timeout_rate` (en %% des ports scannés, aussi affichés dans le résumé final), l’`avg_retries_per_port` (retries moyens sur les ports scannés), le backoff appliqué aux retries (`retry_backoff_pct`), le délai jusqu’au premier open (`first_open_ms`), l’état du deadline (`deadline_ms` + `deadline_hit`), les ports les plus rapides/lents (`fastest_port/slowest_port` avec leurs durées) ainsi que le flag `timeout_stop_hit`/`timeout_stop_threshold` lorsque `-u` stoppe après un nombre de timeouts. Les exports ajoutent aussi le flag `randomized` et la seed `random_seed` réellement utilisée (utile pour rejouer un ordre de ports avec `-e`), le flag `dry_run` (vrai quand le scan est court-circuité avant l’ouverture de sockets) et respectent le filtre `-E`. Ils incluent également les ports non scannés (status `unknown`) lorsqu’un arrêt anticipé se produit (deadline, `-F`, `-u` ou `-n`). Lorsqu’un export stdout est utilisé, le résumé est dirigé vers stderr pour laisser un flux machine propre sur stdout.

## Construction / tests

```
make        # construit ft_nmap
make test   # lance les scans de base (ports par arguments, stdin, exclusions, top ports, stop-on-open*, ndjson, deadline)
./ft_nmap -t 127.0.0.1 -p 22,80,443 -T 200 -c 64 -S -o out.json
```

*Les tests “stop-on-open” et “stop-after-n-open” démarrent de petits serveurs TCP locaux; s’il est impossible de binder un port dans l’environnement, ils sont automatiquement ignorés.

Un scan rapide local (ex. `localhost -p 22`) est suffisant pour vérifier le binaire dans l’état actuel. Ajoutez vos scénarios dans `tests_realisation/` si besoin. Le Makefile génère des dépendances (`*.d`) pour recompiler automatiquement lorsqu’un header change, évitant les incohérences binaires; `-r` mélange réellement les ports, `-c` contrôle la taille des batches en poll non bloquant, `-P` charge des listes de ports depuis un fichier ou stdin, `-x/-X` filtrent/éliminent certains ports (compteur “excluded” dans les stats JSON/CSV), `-F` permet de stopper dès le premier OPEN (le compteur “scanned” reflète les ports réellement traités), `-I` force l’IP à scanner (bypass DNS) tout en conservant le target pour les exports, `-4/-6` ciblent IPv4/IPv6, `-R` réessaie les ports en TIMEOUT (compteur exporté en JSON/CSV), `-O` filtre les sorties/tableaux aux seuls “open” et `-n` évite toute création de socket (utile pour valider les listes et les exports). Codes de retour : 0 si aucun open/timeout, 2 s’il y a au moins un port open, 3 s’il reste des timeouts.
Les exports incluent désormais les champs `resolved_ip`/`resolved_family` ainsi que `resolved_count` et le tableau `resolved` (adresses numériques + famille) pour identifier clairement toutes les résolutions DNS retournées. Avec `-I`, ces champs reflètent l’adresse forcée et le résumé indique “override”. En mode dry-run, les exports portent `dry_run: true`, `scanned: 0`, `pending` = ports demandés et la liste des ports reste en statut `unknown`.

## Exemples rapides

- Dry-run pour vérifier la résolution et le pipeline d’exports sans ouvrir de socket :  
  `./ft_nmap -t example.com -p 22,80,443 -n -J stats.json` (résumé vers stderr, stats-only JSON avec `dry_run: true`, `pending: 3`).
- Scan classique restreint aux ports courants, export Markdown et liste des ouverts :  
  `./ft_nmap -t 192.0.2.10 -k 50 -S -m report.md -L open_ports.txt`
