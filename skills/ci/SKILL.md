---
name: ci
description: Écrit, optimise et débogue les workflows GitHub Actions - lecture des logs d'un run en échec, cache, matrices, jobs parallèles, réutilisation de workflows, déclencheurs, permissions minimales et actions épinglées. Indépendant de la stack - charge stacks/<stack>/INDEX.md (deploy). À utiliser quand l'utilisateur écrit ou corrige un workflow, une CI qui échoue ou qui est lente, un pipeline de build, de test ou de déploiement, ou invoque /max:ci.
---

# Workflows GitHub Actions

Viser une CI fiable, rapide et économe en permissions. L'audit de sécurité des workflows appartient à `/max:security` (agent `actions-auditor`) ; ce skill, lui, écrit et répare.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis lire `stacks/<stack>/INDEX.md` pour la nature **deploy** (qui inclut `core`) : commandes de build et de test. Sans ressource, s'en tenir aux scripts et au runner lus dans le projet. Ne jamais `Read` une ressource inexistante.

## Diagnostiquer un run en échec

1. `gh run list --limit 5`, puis `gh run view <id> --log-failed` : lire l'erreur **réelle**, pas seulement la dernière ligne.
2. Classer la cause : projet (test, lint, build), environnement (version, dépendance, cache), workflow (syntaxe, permission, secret absent) ou intermittent (un `gh run rerun --failed` permet de le constater).
3. Reproduire en local avec les mêmes commandes et versions avant de corriger. Face à un échec intermittent, chercher ce qui varie (ordre, durée, ressource partagée) plutôt que d'ajouter un retry.

## Écrire ou améliorer un workflow

- **Déclencheurs** précis (`pull_request`, `push` sur `main`, `workflow_dispatch`) ; `concurrency` avec `cancel-in-progress` pour les PR.
- **Permissions** minimales à la racine (`permissions: contents: read`), relevées job par job seulement au besoin.
- **Actions épinglées** sur un SHA de commit (tag en commentaire), tenues à jour par Dependabot ou Renovate.
- **Cache** des dépendances via celui des `actions/setup-*` ou `actions/cache` (clé sur le lockfile) ; mesurer le gain avant de le conserver.
- **Vitesse** : jobs indépendants en parallèle, `needs:` seulement pour une vraie dépendance, matrices limitées aux versions réellement supportées, `timeout-minutes` sur chaque job.
- **Réutilisation** : `workflow_call` ou action composite pour ce qui se répète, plutôt que du copier-coller.
- **Secrets** : jamais en clair ni dans les logs ; jamais d'entrée non fiable (`${{ github.event.* }}`) interpolée directement dans un `run:` (passer par une variable d'environnement).
- Valider la syntaxe avec `actionlint` s'il est présent ; sinon, relire à la main.

## Forme de la réponse

1. Symptôme ou objectif, et cause établie (non supposée).
2. Changement apporté au workflow, avec le gain ou la correction attendus.
3. Vérification réelle : commande locale exécutée ou run observé (`gh run watch`).
4. Points impossibles à vérifier en local (secrets, runners, environnements).

## Limites

- Pas de `gh workflow run`, de relance de run ni de push sans accord ; toucher à un workflow de déploiement ou de release exige un accord explicite.
- Ne jamais créer ni afficher un secret, et ne pas élargir les permissions pour « faire passer » un run.
- L'audit de sécurité complet relève de `/max:security`, la PR de `/max:pull-request`.
