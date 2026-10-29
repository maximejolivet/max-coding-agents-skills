# Stack : Vue - spécificités

Point d'entrée des spécificités Vue 3 (Forme 1 : fichier unique sectionné). L'appelant lit `## core` plus la section correspondant à sa nature. Nuxt s'appuie sur Vue : `stacks/nuxt/INDEX.md` est lu en premier, puis celle-ci (parent). Promouvoir une section en fichier voisin (Forme 2) si elle grossit.

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

- **Détection** : dépendance `vue` dans `package.json`, `vite.config.*`, fichiers `.vue`. Vue 3 uniquement ici ; Vue 2 est en fin de vie.
- **Composants** : SFC avec `<script setup lang="ts">` (API de composition) sauf si le projet utilise l'API d'options ; suivre l'existant.
- **Réactivité** : `ref` pour les valeurs, `reactive` pour les objets, `computed` pour le dérivé. Dans un `ref`, la valeur s'atteint par `.value` (script) mais pas dans le gabarit.
- **Perte de réactivité** : déstructurer un objet `reactive` ou une `props` casse la réactivité ; utiliser `toRefs` / `toRef` ou `props.x`.
- **Commandes** : scripts de `package.json` (`dev`, `build`, `lint`, `test`, `type-check`/`vue-tsc`).

---

## dev

- **Props / événements** : `defineProps` et `defineEmits` typés ; les données descendent par props, les changements remontent par événements (`v-model` via `defineModel`). Ne pas muter une prop.
- **État partagé** : Pinia (stores par domaine), pas de store global fourre-tout ; composables (`useXxx`) pour la logique réutilisable.
- **Effets** : `watch` / `watchEffect` seulement pour des effets de bord ; le dérivé va dans `computed`. Nettoyer ce qu'on abonne (`onUnmounted`).
- **Gabarits** : `:key` stable sur `v-for`, pas de `v-if` avec `v-for` sur le même élément, logique complexe sortie dans `computed`.
- **Routage** : Vue Router, routes chargées paresseusement (`() => import(...)`).
- **Qualité** : ESLint (`eslint-plugin-vue`), `vue-tsc --noEmit`, Prettier doivent passer.

---

## review

- **Réactivité cassée** - déstructuration de `reactive`/props, `.value` oublié, objet remplacé au lieu de muté sans `ref`.
- **Props mutées**, `v-model` sur une prop, état dupliqué à partir d'une prop sans `watch`.
- **Watchers** - `watch` qui calcule du dérivé, absence de nettoyage, boucle de mise à jour.
- **Listes** - `:key` absente ou basée sur l'index, `v-if` + `v-for` ensemble.
- **XSS** - `v-html` avec du contenu non assaini.
- **Accessibilité** - `div` cliquable au lieu de `button`, `label` manquant, focus perdu.
- **Taille** - import d'une bibliothèque entière, route lourde non paresseuse.

---

## security

- **Mises à jour** : `npm audit` / équivalent du gestionnaire.
- **XSS** : le gabarit échappe par défaut ; `v-html` et rendu de HTML externe demandent une assainisseur (DOMPurify). Pas d'URL `javascript:` en `href` dynamique.
- **Secrets** : tout ce qui est préfixé `VITE_` part dans le bundle navigateur ; aucun secret dedans.
- **Jetons** : préférer des cookies `HttpOnly` au `localStorage` pour les sessions.

---

## test

- **Outils** : Vitest + Vue Test Utils (ou Testing Library pour Vue) ; Playwright / Cypress pour les parcours. Pinia : `createTestingPinia`.
- **Règles** : monter le composant et vérifier le rendu et les événements émis, pas l'état interne ; simuler le réseau plutôt que les modules.

---

## deploy

- **Build** : `vite build` produit des fichiers statiques (`dist/`) ; servir avec un serveur statique et un repli vers `index.html` pour le routage côté client.
- **Image** : build multi-étapes (Node pour construire, serveur léger pour servir), utilisateur non root ; variables `VITE_*` fournies **au build**.
