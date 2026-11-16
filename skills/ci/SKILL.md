---
name: ci
description: "Écrit, accélère et débogue les workflows GitHub Actions - lecture des logs d'un run en échec, déclencheurs, permissions minimales, actions épinglées, cache, jobs parallèles, réutilisation. À utiliser quand Maxime écrit ou corrige un workflow, a une CI qui échoue ou qui est lente, monte un pipeline de build, de test ou de déploiement, ou invoque /max:ci."
argument-hint: "[workflow ou run en échec]"
---

# Workflows GitHub Actions

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Lancer `ls .github/workflows/ 2>/dev/null; gh run list --limit 5`.
3. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **deploy**. Elle donne les commandes de build et de test.

## Étapes

### Déboguer un run

1. Lire l'erreur réelle : `gh run view <id> --log-failed`, pas seulement la dernière ligne.
2. Classer la cause :

   | Origine | Exemples |
   | :-- | :-- |
   | Projet | test, lint, build |
   | Environnement | version, dépendance, cache |
   | Workflow | syntaxe, permission, secret absent |
   | Intermittent | ordre, durée, ressource partagée |

3. Reproduire en local avec les mêmes commandes et les mêmes versions.
4. Corriger la cause, puis observer le run suivant (`gh run watch`).

### Écrire ou améliorer

1. Reprendre les commandes que le projet lance déjà en local.
2. Appliquer les règles de l'annexe.
3. Valider avec `actionlint` s'il est installé, sinon relire à la main.
4. Rendre compte : le changement, le gain ou la correction attendus, ce qui a été vérifié, ce qui ne peut pas l'être en local (secrets, runners, environnements).

## Points d'arrêt

- L'échec est intermittent : chercher ce qui varie. Un retry n'est pas un correctif.
- Relancer un run (`gh run rerun --failed`) ou en déclencher un (`gh workflow run`) : attendre l'accord.
- Le workflow touché déploie ou publie une release : accord explicite avant toute modification.
- Un SHA d'action n'est pas retrouvable : écrire `<sha de la release vX.Y>`, ne pas l'inventer.

## Ce qu'il ne fait pas

- Élargir les permissions pour faire passer un run.
- Créer ou afficher un secret.
- Auditer la sécurité de tous les workflows : `/max:security`.
- Pousser ou ouvrir la PR : `/max:pull-request`.

## Annexe : règles d'un workflow

Sécurité :

- `permissions: contents: read` à la racine, relevées job par job au besoin.
- Chaque action épinglée sur un SHA de commit complet, le tag en commentaire ; mises à jour par Dependabot ou Renovate.
- Aucun secret en clair ni dans les logs.
- Aucune entrée non fiable (`${{ github.event.* }}`) interpolée dans un `run:` : passer par une variable `env:`.
- OIDC (`id-token: write`) plutôt qu'une clé cloud durable.

Vitesse :

- Cache des dépendances par `actions/setup-*` ou `actions/cache`, clé sur le lockfile. Mesurer le gain avant de le garder.
- Jobs indépendants en parallèle ; `needs:` seulement pour une vraie dépendance.
- Matrice limitée aux versions réellement supportées.
- `timeout-minutes` sur chaque job.
- `concurrency` avec `cancel-in-progress` pour les PR.

Structure :

- Déclencheurs précis : `pull_request`, `push` sur la branche par défaut, `workflow_dispatch`.
- `workflow_call` ou action composite pour ce qui se répète.
- Tests : mêmes commandes que le runner local, `services:` avec `healthcheck` pour la base, rapport JUnit ou couverture en artefact si utile.
- Image Docker : construite à chaque PR sans être publiée, publiée depuis la branche par défaut ou un tag ; secrets de build par `secrets:`, pas par `build-args`.
