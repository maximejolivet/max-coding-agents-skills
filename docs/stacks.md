# Ajouter une techno

Les skills ne contiennent aucune techno : ils détectent la stack, puis chargent `stacks/<techno>/INDEX.md`.

## Détection

`stacks/detect.sh` (lecture seule) lit les fichiers du projet et affiche `catégorie<TAB>identifiant<TAB>preuve` : `language`, `package-manager`, `framework`, `parent`, `test`, `tooling`, `runner`, `resource`. La procédure complète est dans `stacks/DETECT.md`. Règles clés :

- Le framework prime sur le langage.
- Le plus spécifique d'abord, puis son parent (`nuxt` puis `vue`).
- Plusieurs frameworks : chacun ne s'applique qu'à ses fichiers.
- Monorepo : lancer le script sur chaque sous-dossier.
- Runner : `make`, puis `docker compose`.

## Ajouter une techno

1. Ajouter sa détection dans `stacks/detect.sh`.
2. Créer `stacks/<techno>/INDEX.md`.
3. Lancer `sh tests/check.sh`.

Aucun skill ne change.

## Formes d'un dossier de techno

- **Forme 1** : un seul `INDEX.md` découpé en sections (toutes les stacks fournies l'utilisent : Symfony, Nuxt, React, Next.js, Vue, Laravel, Django). Commencer par là.
- **Forme 2** : `INDEX.md` (dispatcher) + `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md`, quand une section devient trop longue.

## Sections et natures

| Section        | Chargée pour la nature | Contenu                                    |
| :------------- | :--------------------- | :----------------------------------------- |
| `## core`      | toujours               | Conventions et pièges propres à la techno. Écrit **une seule fois**. |
| `## dev`       | `dev`                  | Écrire du code idiomatique.                |
| `## review`    | `review`               | Checklist de relecture.                    |
| `## security`  | `security`             | Avis, configuration, points d'audit.       |
| `## test`      | `test`                 | Outils et façon d'écrire les tests.        |
| `## deploy`    | `deploy`               | Build, image, déploiement.                 |

Ne mettre que les sections utiles. Une nature se charge avec `core` plus sa section.
