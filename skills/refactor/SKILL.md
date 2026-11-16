---
name: refactor
description: "Mène un refactoring ou une migration à grande échelle sans changer le comportement - suite verte d'abord, lots indépendants et annulables, vérification après chaque lot, un commit par lot. À utiliser quand Maxime veut renommer, déplacer, restructurer, migrer vers une nouvelle API, version ou bibliothèque, supprimer du code mort ou appliquer un changement répétitif à beaucoup de fichiers, ou invoque /max:refactor."
argument-hint: "[objectif du refactoring]"
---

# Refactorer par lots

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **dev**.
3. Mesurer l'ampleur : `git grep -c <motif>`, `grep -rn`. Ne pas l'estimer.
4. Lancer la suite : elle doit être verte avant toute modification. Sinon, noter les échecs de départ.

## Étapes

1. Fixer en une ligne chacun : l'objectif, le périmètre, le comportement à préserver (API publique, formats, effets de bord) et le critère de fin (« plus aucune occurrence de `X` »).
2. Si la zone n'a pas de tests : écrire des tests de caractérisation avec `/max:test` et les voir passer.
3. Découper en lots indépendants, de taille voisine, chacun vérifiable seul. Les moins risqués d'abord.
4. Écrire le plan en cases à cocher, le proposer et attendre l'accord.
5. Pour chaque lot : appliquer le changement et rien d'autre, puis lancer linter, types, build et tests concernés par le runner.
6. Committer le lot si Maxime l'a demandé : `refactor(<scope>): ♻️ …` (`/max:commit`).
7. À la fin : relancer toute la suite, vérifier le critère de fin, puis `/max:review` et `/max:pull-request`.

Un changement mécanique (renommage, déplacement) passe par l'outil du langage ou un script, pas par des éditions une à une. Sur un gros chantier, l'agent `max:codebase-surveyor` cartographie les usages ; les écritures restent dans la session, un lot après l'autre.

## Points d'arrêt

- Un lot échoue : lire l'erreur et corriger la cause, trois essais au plus. Au-delà, annuler le lot et remonter le blocage.
- Aucun test n'est possible : le dire, réduire les lots et décrire la vérification manuelle.
- Un bug apparaît en route : le signaler, le traiter dans un commit à part.
- La PR devient trop grosse pour être relue : proposer de la scinder par lot.

## Ce qu'il ne fait pas

- Changer le comportement en même temps que la structure.
- Supprimer, ignorer ou affaiblir un test pour qu'un lot passe.
- Monter une version ou ajouter une dépendance sans accord.
- Éditer à la main un fichier généré ou un lockfile.
- Travailler sur la branche par défaut.
