---
name: versioning
description: "Gère la version du plugin à chaque pull request - lit la version actuelle, incrémente le PATCH de 0.0.1 par défaut (ou MINOR/MAJOR si le changement l'exige), l'aligne dans plugin.json, marketplace.json et le badge du README, met à jour CHANGELOG.md s'il existe, puis lance tests/check.sh. À utiliser avant d'ouvrir une PR, lors d'une release, ou quand l'utilisateur demande de monter ou d'aligner la version."
---

# Versionnement

Garder une version cohérente, prévisible et traçable. Claude Code ne propose une mise à jour du plugin que si la `version` augmente : une PR mergée sans incrément n'arrive jamais chez les utilisateurs.

## Source de vérité

La version vit à trois endroits, qui doivent rester **identiques** (`tests/check.sh` vérifie les deux premiers) :

- `.claude-plugin/plugin.json` : `version`
- `.claude-plugin/marketplace.json` : `version` du plugin `max`
- `README.md` : badge `version-X.Y.Z-lightgrey`

Ne jamais modifier la version sans avoir lu la valeur actuelle. Ne pas confondre avec la version d'une dépendance ou d'une stack.

## Règle du projet

**Chaque PR incrémente le PATCH de `0.0.1`** (`1.0.1` → `1.0.2`), même pour une nouvelle fonctionnalité. Le projet reste sous contrôle de l'auteur : passer à MINOR ou MAJOR uniquement sur demande explicite de l'utilisateur.

Cas particuliers :

- **Plusieurs PR ouvertes en même temps** : la deuxième à être mergée rebase sur `main` et reprend la version suivante.
- **PR de documentation seule** (README, docs) : incrémenter quand même, la règle reste simple.
- **Version installée plus haute que le dépôt** : Claude Code ignore alors la mise à jour. Repartir au-dessus de la plus haute version déjà publiée (lire `~/.claude/plugins/installed_plugins.json` si besoin).

## SemVer, si MINOR ou MAJOR est demandé

- `PATCH` : correction rétrocompatible.
- `MINOR` : ajout rétrocompatible (nouveau skill, nouvel agent).
- `MAJOR` : changement incompatible (skill renommé ou supprimé, namespace modifié).

N'incrémenter MAJOR que si la compatibilité est réellement rompue, jamais parce que le numéro précédent est élevé.

## Procédure

1. Repérer les changements depuis la dernière version (`git log`, `git diff main`) et l'état de Git ; ne pas embarquer de modifications sans rapport.
2. Lire la version actuelle dans `plugin.json`.
3. Annoncer l'incrément (ancienne → nouvelle version, et pourquoi).
4. Mettre à jour les trois fichiers ci-dessus, et seulement eux.
5. Mettre à jour `CHANGELOG.md` **s'il existe** (sections `Added`, `Changed`, `Fixed`, date `YYYY-MM-DD`). Ne pas le créer de sa propre initiative.
6. Lancer `sh tests/check.sh` et vérifier le diff : trois versions identiques, rien d'autre de touché.

## Tags et releases

Ne créer ni tag Git ni release GitHub sans demande explicite. Le marketplace lit `main` : le merge suffit à publier.
