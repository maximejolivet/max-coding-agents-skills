---
name: react
description: "Développe en React (18 et 19) - composants, hooks, état, effets, données serveur, formulaires, routage - avec le déroulé de /max:dev et la stack fixée à React. À utiliser quand Maxime implémente ou modifie du code React, demande de l'aide sur React, ou invoque /max:react."
argument-hint: "[issue, brief ou tâche]"
---

# Développer en React

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lancer `sh "<max>/stacks/detect.sh"` : la ligne `framework	react` doit sortir.
2. Lire `<max>/references/regles.md`, une fois par session.
3. Lire `<max>/skills/dev/SKILL.md` : ses préalables, ses étapes, ses points d'arrêt et ses limites s'appliquent en entier. Ses chemins `<max>/…` partent de la même racine.
4. Lire `<max>/stacks/react/INDEX.md`, sections `core` et `dev`. Sur un projet Next.js, lire d'abord `<max>/stacks/nextjs/INDEX.md`.

## Étapes

1. Suivre les étapes de `/max:dev`, sans refaire la détection.
2. Relever la version de React et les bibliothèques déjà retenues (routage, données, formulaires, état) avant d'écrire.
3. Vérifier avec le bloc « Vérifier » de la section `dev`, par le gestionnaire du lockfile.

## Points d'arrêt

- Le projet n'utilise pas React : le dire et passer à `/max:dev`.
- Un avertissement `react-hooks/exhaustive-deps` apparaît : corriger la cause, ne pas le désactiver.

## Ce qu'il ne fait pas

- Rien de plus que `/max:dev`.
- Ajouter `memo`, `useMemo` ou `useCallback` sans mesure.
