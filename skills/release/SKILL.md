---
name: release
description: "Prépare une release GitHub - version choisie d'après les commits depuis le dernier tag, notes de version, alignement de la version dans les fichiers du projet, puis tag et GitHub Release sur accord. À utiliser quand Maxime veut publier une version, tagger, écrire un changelog ou des notes de version, ou invoque /max:release."
---

# Préparer une release

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session. Elle donne la branche par défaut (`<défaut>`) et la langue des notes.
2. Lancer `git switch <défaut>`, `git pull --ff-only origin <défaut>`, `git status -sb` : partir d'une branche à jour et propre.
3. Lancer `git describe --tags --abbrev=0` pour le dernier tag, et `gh run list --branch <défaut> --limit 3` pour l'état de la CI.

## Étapes

1. Lister ce qui part : `git log <tag>..HEAD --oneline` et `gh pr list --state merged --search "merged:>=<date du tag>"`.
2. Proposer la version, avec sa raison, et laisser Maxime trancher :

   | Commits depuis le tag | Version |
   | :-- | :-- |
   | `!` ou `BREAKING CHANGE:` | majeure |
   | sinon un `feat` | mineure |
   | sinon `fix`, `perf`, `security`… | correctif |

3. Rédiger les notes (annexe). Mettre à jour `CHANGELOG.md` s'il existe.
4. Montrer ce qui sera fait, puis attendre l'accord.
5. Aligner la version dans les fichiers du projet par une branche et une PR (`/max:pull-request`).
6. Après le merge : `git tag -a v<version> -m "v<version>"`, `git push origin v<version>`, puis `gh release create v<version> --title "v<version>" --notes-file <fichier>` (`--draft` si Maxime veut relire).
7. Donner l'URL de la release et l'état des workflows déclenchés par le tag.

## Points d'arrêt

- `<défaut>` n'est pas à jour ou pas propre : s'arrêter et expliquer.
- La CI est rouge : le dire avant d'aller plus loin.
- Aucun tag : partir du premier commit et le dire.
- Le dépôt a sa propre règle de version (le plugin Max suit `/max:versioning`) : l'appliquer, ne pas la contredire.
- Avant le tag, le push du tag et la release : un accord pour chacun.

## Ce qu'il ne fait pas

- `git tag -f`, ni supprimer un tag publié.
- Committer directement sur `<défaut>`.
- Modifier le code pour préparer la release.
- Créer `CHANGELOG.md` sans accord.
- Corriger en urgence une version en production : `/max:hotfix`.

## Annexe : notes de version

Dans la langue du dépôt, l'anglais par défaut. Les sujets de commit sont cités tels quels.

```markdown
## <version> - <date>

### Breaking changes
- <change, and how to migrate> (#<PR>)

### Security
### Added
### Fixed
### Performance
### Other
```

Ruptures et sécurité en tête. Une section vide disparaît.
