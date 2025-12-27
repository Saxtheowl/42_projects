# Self-Analysis (draft)

## Synthèse express (30s)
- Ingé logiciel orienté outils développeurs et plateformes : aime réduire la friction (tests, diagnostics, CI/CD) et documenter juste ce qu’il faut.
- Fonctionne mieux en itérations courtes avec feedback utilisateur, apprécie les revues croisées et la pédagogie.
- Valeurs : transparence, reproductibilité, impacts mesurables, transmission continue.

## Ex00 — Experience
- **Software engineering (8+ ans, C/Go/Python)** : conception d’APIs et d’outils CLI ; mise en place de pipelines CI/CD (tests, lint, security gates) pour fiabiliser les livraisons.
- **Infrastructure / Observabilité** : déploiements Docker/K8s, dashboards et alertes (Prometheus/Grafana), traçage simple pour diagnostiquer les régressions de perf.
- **Encadrement & pédagogie** : ateliers hebdo d’algorithmique et de clean code (pair programming, revues), rédaction de guides de démarrage et de checklists de revue.
- **Data & ML léger** : petits projets de régression et de classification (scikit-learn), expérimentation sur l’évaluation de modèles via scripts reproductibles.
- **Langues** : français (native), anglais (courant), espagnol (conversationnel). A déjà animé des présentations techniques en anglais.

### Exemples et métriques
- **CLI d’audit config** : temps de diagnostic divisé par 3 (30 → 10 min) sur un parc de 40 services, adoption par 12 devs (téléchargements internes + feedback).
- **CI/CD** : réduction de 25% du temps de build en mutualisant cache et en parallélisant les tests (de 16 à 12 min). Ajout de tests de contrat empêchant 2 régressions API signalées en prod.
- **Ateliers** : 10 sessions animées en 6 mois (algo + perf + tooling), taux de participation moyen 8-10 personnes, NPS interne ~+40 (formulaire anonyme).
- **Dashboard SLI** : mise en place d’alertes latence/erreurs (p50/p95, taux d’erreur) avec une baisse de 35% des incidents liés aux timeouts après tuning.

## Ex01 — Personality
- **Forces** :
  - Capacité à structurer un problème et à produire un plan actionnable rapidement (tendance à écrire checklists et tests rapides).
  - Sens du détail sur la relecture (détecte rapidement incohérences et cas limites).
  - Pédagogie et patience : apprécie expliquer par des exemples et des micro-exercices.
  - Calme en incident : sait prioriser l’isolement du bug, collecter logs et mettre en place un contournement.
- **Faiblesses** :
  - Context switching coûteux : peut perdre du temps après de multiples interruptions ; doit planifier des blocs focus.
  - Tendance à sur-documenter et à trop couvrir de cas périphériques au début d’un projet.
  - Difficulté à dire non à des sujets annexes intéressants, ce qui peut diluer l’énergie sur le long terme.
  - Perfectionnisme latent : besoin de définir des critères “suffisamment bons” pour livrer plus tôt.

## Ex02 — Vision
- **Création d’outils utiles** : veut continuer à construire des outils CLI ou services qui réduisent la friction quotidienne des équipes (tests plus rapides, diagnostics plus lisibles).
- **Transparence & reproductibilité** : valorise les environnements reproductibles (scripts, conteneurs, fixtures) pour que chaque membre d’une équipe puisse rejouer un bug ou une démo.
- **Transmission** : souhaite garder du temps chaque semaine pour mentorer/enseigner (revues, ateliers, documentation concise).
- **Qualité pragmatique** : cherche l’équilibre entre “bien testé” et “livré” ; privilégie des itérations courtes avec feedback rapide.
- **A moyen terme** : viser un rôle d’ingénierie produit/plateforme où les décisions techniques sont alignées sur l’impact utilisateur et la simplicité d’exploitation.

## Objectifs 6-12 mois (SMART)
- **Outils dev** : livrer au moins 2 CLIs ou scripts utilisés par >5 personnes chacune, avec métriques d’usage (télémetrie simple ou retours). Délai : 9 mois.
- **Transmission** : animer 1 atelier/mois (algo, tooling, perf) avec support partagé ; recueillir un feedback écrit par session. Délai : continu sur 12 mois.
- **Fiabilité** : mettre en place un tableau de bord SLI/SLO minimal pour un service dont je suis responsable (latence, erreurs) et le maintenir à jour. Délai : 6 mois.
- **Équilibre charge** : réserver 2 blocs focus de 2h/semaine (calendrier bloqué) et mesurer le respect >75% sur 3 mois glissants pour limiter le context switching.
- **Portée internationale** : donner au moins 1 talk/mini-présentation technique en anglais (20-30 min) avec enregistrement ou slides publics. Délai : 12 mois.

### Suivi rapide (à mettre à jour mensuellement)
| Objectif                     | Prochain jalon | Statut |
|------------------------------|----------------|--------|
| 2 CLIs utilisées >5 pers     | PoC #1 prêt     | IN_PROGRESS |
| 1 atelier/mois + feedback    | Atelier Jan     | PLANNED |
| Dashboard SLI/SLO            | Choix service   | PLANNED |
| Blocs focus 2×2h/semaine     | Semaine en cours| IN_PROGRESS |
| Talk en anglais (20-30 min)  | Sujet shortlist | PLANNED |

## Style de travail / Préférences
- Préfère commencer par un prototype jetable + checklist de critères “suffisamment bons” plutôt que viser la solution finale d’un coup.
- S’appuie sur des micro-tests ou scripts de repro dès que possible pour verrouiller les invariants.
- Communique par écrits courts (bullet points) puis démos synchrones pour valider l’alignement.
- Besoin de plages sans interruption pour avancer sur les sujets complexes ; fonctionne bien en binômage pour le débogage.

## Plan oral 10 minutes (revue)
1. **Intro 30s** : synthèse express + objectifs actuels.
2. **Expériences clés (3 min)** : 2 exemples chiffrés (CLI audit, CI/CD) + rôle exact.
3. **Personnalité & style (2 min)** : forces/faiblesses, gestion interruptions.
4. **Vision & objectifs (2 min)** : focus outils dev/fiabilité + tableau de suivi.
5. **Questions/tournants (2 min)** : incident prod 2021, burnout léger et actions préventives.
6. **Q&A (1 min)** : points à éclaircir / feedback.

## Preuves & liens (à maintenir)
- CLI audit : <lien repo> / <doc interne> / métriques d’usage.
- CI/CD : <lien pipeline> / comparatif temps build.
- Ateliers : <dossier supports> / formulaires feedback.
- SLI/SLO : <lien dashboard> / définition SLO.
- Talk EN : <slides/recording>.

## Rituel de mise à jour
- Mettre à jour les métriques et le tableau de suivi chaque fin de mois (copier le template mensuel).
- Après chaque revue : compléter la section “Notes rapides post-revue” du checklist.

## Journal mensuel
### 2025-12
- CLIs : cadrage PoC #1 (audit config) terminé, collecte des métriques d’usage à définir.
- Ateliers : sujets 2026-01 shortlistés (profiling Python, tests de contrat).
- SLI/SLO : service cible pressenti (API metrics) ; définition des SLI en brouillon.
- Blocs focus : 3/4 blocs respectés (75%).
- Talk EN : shortlist de sujets (CI perf / incident post-mortem).

## Bonus — Turning points
- **Echec de lancement produit (2019)** : projet trop ambitieux sans utilisateur test ; a appris à prototyper plus tôt, à valider l’appétence et à couper des fonctionnalités sans hésiter.
- **Incident production majeur (2021)** : panne due à un manque de limites de ressources ; a introduit par la suite des budgets d’erreurs, des SLIs/SLOs simples et des revues de capacité trimestrielles.
- **Burnout léger (2022)** : surcharge de contextes (projet + mentoring + conférences). A appris à prioriser, à déléguer et à bloquer des plages sans réunion.
- **Reconversion technique initiale (2016)** : passage d’une formation non-tech à l’ingénierie logicielle via autoformation et projets open source ; a renforcé la conviction qu’apprendre par la pratique et le partage fonctionne.

## Préparation à la revue (questions/points à tester)
- Exemple concret d’outil livré récemment : quel impact mesuré ? quels freins rencontrés ?
- Comment je gère un incident quand l’information est incomplète ? (log-first, hypothèses, rollback, com interne)
- Exemple où j’ai dit non / réduit la portée : comment, avec quels critères ?
- Stratégie pour limiter le contexte switching : quels garde-fous concrets ? (blocs focus, limites réunions)
- Ce qui m’a motivé à persévérer lors du burnout léger et ce qui a changé depuis.
