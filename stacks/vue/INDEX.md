# Stack : Vue - spécificités

Point d'entrée des particularités de Vue 3 (Forme 1 : un fichier unique découpé en sections). Le skill appelant lit `## core` puis la section correspondant à sa nature. Nuxt repose sur Vue : on lit d'abord `stacks/nuxt/INDEX.md`, puis celui-ci (le parent). Si une section grossit trop, la promouvoir en fichier voisin (Forme 2).

Nature → sections :

| Appelant                           | Sections        |
| ---------------------------------- | --------------- |
| `/max:review`, `/max:pr-review`    | core + review   |
| `/max:security`                    | core + security |
| `/max:test`                        | core + test     |
| `/max:docker`, `/max:kubernetes`   | core + deploy   |
| `/max:debug`, `/max:refactor`, `/max:perf`, `/max:migrate-db`, `/max:a11y` | core + dev |

---

## core

- **Détection** : dépendance `vue` dans `package.json`, `vite.config.*`, fichiers `.vue`. Seul Vue 3 est traité ici ; Vue 2 est en fin de vie.
- **Composants** : composants monofichier avec `<script setup lang="ts">` (API de composition), sauf si le projet reste sur l'API d'options ; suivre l'existant.
- **Réactivité** : `ref` pour une valeur, `reactive` pour un objet, `computed` pour le dérivé. Un `ref` s'atteint par `.value` dans le script, mais pas dans le gabarit.
- **Réactivité perdue** : déstructurer un objet `reactive` ou les `props` la casse ; passer par `toRefs` / `toRef` ou par `props.x`.
- **Commandes** : les scripts de `package.json` (`dev`, `build`, `lint`, `test`, `type-check` ou `vue-tsc`).

---

## dev

- **Props et événements** : `defineProps` et `defineEmits` typés ; les données descendent par props, les changements remontent par événements (`v-model` via `defineModel`). Une prop ne se mute jamais.
- **État partagé** : Pinia, un store par domaine, sans store global fourre-tout ; la logique réutilisable va dans des composables (`useXxx`).
- **Effets** : `watch` / `watchEffect` uniquement pour des effets de bord ; le dérivé relève de `computed`. Défaire ce qu'on a abonné (`onUnmounted`).
- **Gabarits** : `:key` stable sur `v-for`, jamais `v-if` et `v-for` sur le même élément, logique complexe extraite dans un `computed`.
- **Routage** : Vue Router, routes chargées paresseusement (`() => import(...)`).
- **Qualité** : ESLint (`eslint-plugin-vue`), `vue-tsc --noEmit` et Prettier doivent passer.

---

## review

- **Réactivité cassée** : déstructuration d'un `reactive` ou de props, `.value` oublié, objet remplacé plutôt que muté sans passer par un `ref`.
- **Props mutées**, `v-model` posé sur une prop, état copié d'une prop sans `watch`.
- **Watchers** : `watch` qui calcule du dérivé, absence de nettoyage, boucle de mise à jour.
- **Listes** : `:key` absente ou fondée sur l'index, `v-if` combiné à `v-for`.
- **XSS** : `v-html` avec un contenu non assaini.
- **Accessibilité** : `div` cliquable à la place d'un `button`, `label` absent, focus perdu.
- **Poids** : bibliothèque importée en entier, route lourde non chargée paresseusement.

---

## security

- **Mises à jour** : `npm audit` ou l'équivalent du gestionnaire de paquets.
- **XSS** : le gabarit échappe par défaut ; `v-html` et tout rendu de HTML externe exigent un assainisseur (DOMPurify). Pas d'URL `javascript:` dans un `href` dynamique.
- **Secrets** : tout ce qui commence par `VITE_` part dans le bundle du navigateur ; aucun secret dedans.
- **Jetons** : préférer des cookies `HttpOnly` au `localStorage` pour les sessions.

---

## test

- **Outils** : Vitest avec Vue Test Utils (ou Testing Library pour Vue) ; Playwright ou Cypress pour les parcours. Pinia : `createTestingPinia`.
- **Règles** : monter le composant et vérifier le rendu et les événements émis, pas l'état interne ; simuler le réseau plutôt que les modules.

---

## deploy

- **Build** : `vite build` produit des fichiers statiques (`dist/`) ; les servir avec un serveur statique qui renvoie `index.html` pour le routage côté client.
- **Image** : build multi-étapes (Node pour construire, serveur léger pour servir), utilisateur non root ; les variables `VITE_*` sont fournies **au build**.
