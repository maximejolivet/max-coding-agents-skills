---
name: release
description: Prépare une release GitHub - choisit la version d'après les commits sémantiques depuis le dernier tag, génère le changelog, aligne la version dans les fichiers du projet, crée le tag et la GitHub Release sur accord. Indépendant de la stack. À utiliser quand l'utilisateur veut publier une version, tagger, écrire un changelog ou des notes de version, ou invoque /max:release.
---

# Préparer une release

Transformer l'historique depuis le dernier tag en une version publiée : numéro, notes lisibles, tag, GitHub Release. Action visible de l'extérieur : **rien n'est tagué, poussé ni publié sans accord explicite**.

## Cadrer

1. Partir de `main` à jour et propre : `git switch main`, `git pull --ff-only origin main`, `git status -sb`. Sinon, s'arrêter et expliquer.
2. Dernier tag : `git describe --tags --abbrev=0` (`git tag --sort=-v:refname | head`). Sans tag, partir du premier commit et le dire.
3. Commits à publier : `git log <tag>..HEAD --oneline` ; relire aussi les PR mergées (`gh pr list --state merged --search "merged:>=<date du tag>"`).
4. CI verte sur `main` (`gh run list --branch main --limit 3`) ; sinon, le signaler avant d'aller plus loin.

## Choisir la version

Suivre le semver à partir des commits au format `max:commit` :

- un `!` ou `BREAKING CHANGE:` → **majeure** ;
- sinon un `feat` → **mineure** ;
- sinon `fix`, `perf`, `security`… → **correctif** (patch).

Proposer le numéro avec sa justification et laisser l'utilisateur trancher. Un dépôt qui incrémente à chaque PR (comme ce plugin, voir `/max:versioning`) garde sa règle : ne pas la contredire.

## Changelog

Regrouper par type, en français pour les notes (les sujets de commit restent en anglais, cités tels quels) :

```markdown
## <version> - <date>

### Ajouts (feat) · Corrections (fix) · Performances (perf) · Sécurité (security) · Divers (docs, build, ci, chore)
- <description> (#<PR>)
```

Mettre `security` et les changements cassants **en tête**, avec la marche à suivre pour migrer. Mettre à jour `CHANGELOG.md` s'il existe ; ne pas en créer sans accord.

## Publier (après accord)

1. Aligner la version dans les fichiers du projet (`package.json`, `composer.json`, manifestes…) via une branche et une PR, jamais par un commit direct sur `main`.
2. Une fois mergé : `git tag -a v<version> -m "v<version>"`, `git push origin v<version>`.
3. `gh release create v<version> --title "v<version>" --notes-file <fichier>` ; `--draft` d'abord si l'utilisateur veut relire.
4. Rapporter l'URL et l'état des workflows déclenchés par le tag.

## Format de la réponse

1. Dernier tag, nombre de commits, état de la CI.
2. Version proposée et pourquoi.
3. Notes de version.
4. Ce qui sera fait au « go », et ce qui reste à la charge de l'utilisateur.

## Hors périmètre

- Jamais de `git push` de tag, de `gh release create` ni de modification de `main` sans accord explicite ; jamais de `git tag -f` ni de suppression d'un tag publié.
- Ne pas modifier le code pour « préparer » la release : relève de `/max:pull-request`.
- Un correctif urgent sur une version en production relève de `/max:hotfix`.
