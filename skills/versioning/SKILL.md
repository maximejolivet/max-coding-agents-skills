---
name: versioning
description: "Gère la version du plugin à chaque pull request - lit la version actuelle, incrémente le PATCH de 0.0.1 par défaut (ou MINOR/MAJOR si le changement l'exige), l'aligne dans plugin.json, marketplace.json et le badge du README, met à jour CHANGELOG.md s'il existe, puis lance tests/check.sh. À utiliser avant d'ouvrir une PR, lors d'une release, ou quand l'utilisateur demande de monter ou d'aligner la version."
---

# Versionnement

Une version cohérente, prévisible et traçable. Claude Code ne propose la mise à jour du plugin que si la `version` augmente : une PR mergée sans incrément n'atteint jamais les utilisateurs.

## Où vit la version

Trois emplacements, **toujours identiques** (`tests/check.sh` compare les deux premiers) :

- `.claude-plugin/plugin.json` : champ `version`
- `.claude-plugin/marketplace.json` : `version` du plugin `max`
- `README.md` : badge `version-X.Y.Z-lightgrey`

Lis la valeur actuelle avant toute modification, et ne la confonds pas avec la version d'une dépendance ou d'une stack.

## Règle du dépôt

**Chaque PR augmente le PATCH de `0.0.1`** (`1.0.1` → `1.0.2`), nouvelle fonctionnalité comprise. Le projet reste piloté par son auteur : MINOR ou MAJOR seulement sur demande explicite.

Cas particuliers :

- **Plusieurs PR ouvertes en parallèle** : la seconde mergée se rebase sur `main` et prend la version suivante.
- **PR de documentation seule** (README, docs) : on incrémente quand même, pour garder une règle simple.
- **Version installée supérieure à celle du dépôt** : Claude Code ignore alors la mise à jour. Repartir au-dessus de la plus haute version déjà publiée (au besoin, lire `~/.claude/plugins/installed_plugins.json`).

## SemVer, si MINOR ou MAJOR est demandé

- `PATCH` : correction compatible.
- `MINOR` : ajout compatible (nouveau skill, nouvel agent).
- `MAJOR` : rupture (skill renommé ou supprimé, namespace modifié).

MAJOR n'est justifié que par une vraie rupture de compatibilité, jamais par la hauteur du numéro précédent.

## Déroulé

1. Relever ce qui a changé depuis la dernière version (`git log`, `git diff main`) et l'état de Git ; ne pas embarquer de modifications étrangères.
2. Lire la version actuelle dans `plugin.json`.
3. Annoncer l'incrément (ancienne → nouvelle version) et sa raison.
4. Modifier les trois fichiers ci-dessus, et eux seuls.
5. Mettre à jour `CHANGELOG.md` **s'il existe** (sections `Added`, `Changed`, `Fixed`, date `YYYY-MM-DD`) ; ne pas le créer de sa propre initiative.
6. Lancer `sh tests/check.sh` et relire le diff : trois versions identiques, rien d'autre touché.

## Tags et releases

Pas de tag Git ni de release GitHub sans demande explicite. Le marketplace lit `main` : le merge suffit à publier.
