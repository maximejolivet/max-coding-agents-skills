---
name: nuxt
description: "Développe en Nuxt (3 et 4) - pages, composants, composables, chargement de données, état, routes serveur Nitro, modes de rendu - avec le déroulé de /max:dev et la stack fixée à Nuxt. À utiliser quand Maxime implémente ou modifie du code Nuxt, demande de l'aide sur Nuxt, ou invoque /max:nuxt."
argument-hint: "[issue, brief ou tâche]"
---

# Développer en Nuxt

## Préalables

1. Lancer `sh "${CLAUDE_SKILL_DIR}/../../stacks/detect.sh"` : la ligne `framework	nuxt` doit sortir.
2. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
3. Lire `${CLAUDE_SKILL_DIR}/../dev/SKILL.md` : ses préalables, ses étapes, ses points d'arrêt et ses limites s'appliquent en entier. Dans ce fichier, `${CLAUDE_SKILL_DIR}` n'est pas remplacé : `${CLAUDE_SKILL_DIR}/../../` désigne la racine du plugin, comme ici.
4. Lire `${CLAUDE_SKILL_DIR}/../../stacks/nuxt/INDEX.md`, sections `core` et `dev`, puis `${CLAUDE_SKILL_DIR}/../../stacks/vue/INDEX.md` (parent).

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
