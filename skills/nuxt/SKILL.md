---
name: nuxt
description: "Développe en Nuxt (3 et 4) - pages, composants, composables, chargement de données, état, routes serveur Nitro, modes de rendu - avec le déroulé de /max:dev et la stack fixée à Nuxt. À utiliser quand Maxime implémente ou modifie du code Nuxt, demande de l'aide sur Nuxt, ou invoque /max:nuxt."
argument-hint: "[issue, brief ou tâche]"
---

# Développer en Nuxt

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lancer `sh "<max>/stacks/detect.sh"` : la ligne `framework	nuxt` doit sortir.
2. Lire `<max>/references/regles.md`, une fois par session.
3. Lire `<max>/skills/dev/SKILL.md` : ses préalables, ses étapes, ses points d'arrêt et ses limites s'appliquent en entier. Ses chemins `<max>/…` partent de la même racine.
4. Lire `<max>/stacks/nuxt/INDEX.md`, sections `core` et `dev`, puis `<max>/stacks/vue/INDEX.md` (parent).

## Étapes

1. Suivre les étapes de `/max:dev`, sans refaire la détection.
2. Relever la version (structure `app/` ou racine) et le mode de rendu de la route touchée avant d'écrire.
3. Vérifier avec le bloc « Vérifier » de la section `dev`, par le gestionnaire du lockfile.

## Points d'arrêt

- Le projet n'est pas un projet Nuxt : le dire et passer à `/max:dev`.
- Le changement demande de modifier le mode de rendu global (`ssr`, preset Nitro, `nuxt generate`) : proposer `routeRules` sur la route, sinon attendre l'accord.

## Ce qu'il ne fait pas

- Rien de plus que `/max:dev`.
- Placer un secret dans `runtimeConfig.public` ou `app.config.ts`.
