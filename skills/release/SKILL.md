---
name: release
description: Prépare une release GitHub - choisit la version d'après les commits sémantiques depuis le dernier tag, génère le changelog, aligne la version dans les fichiers du projet, crée le tag et la GitHub Release sur accord. Indépendant de la stack. À utiliser quand l'utilisateur veut publier une version, tagger, écrire un changelog ou des notes de version, ou invoque /max:release.
---

# Release

Passer de l'historique écoulé depuis le dernier tag à une version publiée : numéro, notes lisibles, tag, GitHub Release. La publication est visible de l'extérieur : **ni tag, ni push, ni release sans accord explicite**.

## 1. État des lieux

1. Se placer sur un `main` à jour et propre : `git switch main`, `git pull --ff-only origin main`, `git status -sb`. Sinon, s'arrêter et expliquer.
2. Dernier tag : `git describe --tags --abbrev=0` (ou `git tag --sort=-v:refname | head`). Sans tag, partir du premier commit et le dire.
3. Contenu à publier : `git log <tag>..HEAD --oneline`, complété par les PR mergées (`gh pr list --state merged --search "merged:>=<date du tag>"`).
4. CI de `main` au vert (`gh run list --branch main --limit 3`) ; sinon le signaler avant d'aller plus loin.

## 2. Numéro de version

Appliquer le semver d'après les commits au format `max:commit` :

- `!` ou `BREAKING CHANGE:` → version **majeure** ;
- à défaut, un `feat` → **mineure** ;
- à défaut, `fix`, `perf`, `security`… → **correctif** (patch).

Proposer le numéro avec sa justification et laisser l'utilisateur décider. Un dépôt qui incrémente à chaque PR (comme ce plugin, voir `/max:versioning`) garde sa règle : ne pas la contredire.

## 3. Changelog

Grouper par type, notes en français (les sujets de commit restent tels quels, en anglais) :

```markdown
## <version> - <date>

### Ajouts (feat) · Corrections (fix) · Performances (perf) · Sécurité (security) · Divers (docs, build, ci, chore)
- <description> (#<PR>)
```

Placer `security` et les changements cassants **en premier**, avec la marche à suivre pour migrer. Mettre à jour `CHANGELOG.md` s'il existe ; ne pas en créer sans accord.

## 4. Publier (après accord)

1. Aligner la version dans les fichiers du projet (`package.json`, `composer.json`, manifestes…) via une branche et une PR, jamais par un commit direct sur `main`.
2. Après le merge : `git tag -a v<version> -m "v<version>"`, puis `git push origin v<version>`.
3. `gh release create v<version> --title "v<version>" --notes-file <fichier>` ; commencer par `--draft` si l'utilisateur veut relire.
4. Donner l'URL de la release et l'état des workflows déclenchés par le tag.

## Forme de la réponse

1. Dernier tag, nombre de commits, état de la CI.
2. Version proposée et sa raison.
3. Notes de version.
4. Ce qui sera fait après le « go », et ce qui reste à l'utilisateur.

## Limites

- Aucun push de tag, `gh release create` ou modification de `main` sans accord explicite ; jamais de `git tag -f` ni de suppression d'un tag publié.
- Le code n'est pas retouché pour « préparer » la release : c'est le rôle de `/max:pull-request`.
- Un correctif urgent sur une version en production relève de `/max:hotfix`.
