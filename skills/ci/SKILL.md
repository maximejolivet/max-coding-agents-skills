---
name: ci
description: Écrit, optimise et débogue les workflows GitHub Actions - lecture des logs d'un run en échec, cache, matrices, jobs parallèles, réutilisation de workflows, déclencheurs, permissions minimales et actions épinglées. Indépendant de la stack - charge stacks/<stack>/INDEX.md (deploy). À utiliser quand l'utilisateur écrit ou corrige un workflow, une CI qui échoue ou qui est lente, un pipeline de build, de test ou de déploiement, ou invoque /max:ci.
---

# Workflows GitHub Actions

Une CI fiable, rapide et sobre en permissions. L'audit de sécurité des workflows relève de `/max:security` (agent `actions-auditor`) ; ce skill écrit et répare.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis charger `stacks/<stack>/INDEX.md` pour la nature **deploy** (qui tire `core`) afin de connaître les commandes de build et de test. Sans ressource, s'en tenir aux scripts et au runner lus dans le projet. Ne jamais `Read` une ressource inexistante.

## Déboguer un run en échec

1. `gh run list --limit 5`, puis `gh run view <id> --log-failed` : lire l'erreur **réelle**, pas la dernière ligne.
2. Distinguer : échec du projet (test, lint, build), de l'environnement (version, dépendance, cache), du workflow (syntaxe, permission, secret absent) ou intermittent (relancer une fois avec `gh run rerun --failed` pour le mesurer).
3. Reproduire en local avec les mêmes commandes et les mêmes versions avant de corriger. Pour un échec intermittent, chercher ce qui varie (ordre, temps, ressource partagée) au lieu d'ajouter un retry.

## Écrire ou améliorer un workflow

- **Déclencheurs** précis (`pull_request`, `push` sur `main`, `workflow_dispatch`) ; `concurrency` avec `cancel-in-progress` pour les PR.
- **Permissions** minimales au niveau du workflow (`permissions: contents: read`), élargies par job seulement si nécessaire.
- **Actions épinglées** sur un SHA de commit (avec le tag en commentaire) ; mises à jour par Dependabot ou Renovate.
- **Cache** des dépendances via le cache intégré de `actions/setup-*` ou `actions/cache` (clé sur le lockfile) ; mesurer le gain avant de le garder.
- **Vitesse** : jobs indépendants en parallèle, `needs:` seulement quand il y a une vraie dépendance, matrices limitées aux versions réellement supportées, `timeout-minutes` sur chaque job.
- **Réutilisation** : `workflow_call` ou une action composite pour ce qui est répété, plutôt que du copier-coller.
- **Secrets** : jamais en clair ni dans les logs ; jamais d'interpolation d'une entrée non fiable (`${{ github.event.* }}`) directement dans un `run:` (passer par une variable d'environnement).
- Valider la syntaxe avec `actionlint` si disponible ; sinon relire à la main.

## Format de la réponse

1. Le symptôme ou l'objectif, et la cause établie (pas supposée).
2. Le changement du workflow, avec le gain ou la correction attendus.
3. La vérification réelle : commande locale lancée, ou run observé (`gh run watch`).
4. Les points non vérifiables en local (secrets, runners, environnements).

## Hors périmètre

- Pas de `gh workflow run`, de relance de run ni de push sans accord ; modifier un workflow de déploiement ou de release demande un accord explicite.
- Ne jamais créer ni afficher un secret ; ne pas élargir les permissions pour « faire passer » un run.
- L'audit de sécurité complet relève de `/max:security`, la PR de `/max:pull-request`.
