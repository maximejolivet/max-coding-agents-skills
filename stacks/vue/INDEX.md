# Vue

```bash
grep -E '"(vue|vite|pinia|vue-router|typescript)"' package.json
```

Lire `## core`, puis la section de la nature (tableau : `<max>/stacks/DETECT.md`). Vue 3 seulement : Vue 2 est en fin de vie. Parent de Nuxt.

---

## core

- Signaux : dépendance `vue`, `vite.config.*`, fichiers `.vue`.
- Composants monofichier en `<script setup lang="ts">`, sauf si le projet reste sur l'API d'options.
- `ref` pour une valeur, `reactive` pour un objet, `computed` pour le dérivé. `.value` dans le script, pas dans le gabarit.
- Déstructurer un `reactive` ou des `props` casse la réactivité : `toRefs`, `toRef` ou `props.x`.
- Commandes : scripts de `package.json` (`dev`, `build`, `lint`, `test`, `type-check`).

---

## dev

- `defineProps` et `defineEmits` typés ; `v-model` par `defineModel`. Une prop ne se mute jamais.
- État partagé : Pinia, un store par domaine. Logique réutilisable en composable `useXxx`.
- `watch` et `watchEffect` pour les effets de bord seulement ; le dérivé va dans `computed`. Défaire ses abonnements dans `onUnmounted`.
- `:key` stable sur `v-for` ; jamais `v-if` et `v-for` sur le même élément.
- Routes chargées paresseusement : `() => import(...)`.

Vérifier : ESLint (`eslint-plugin-vue`), `vue-tsc --noEmit`, Prettier, tests.

---

## review

- Réactivité cassée : déstructuration, `.value` oublié, objet remplacé au lieu d'être muté.
- Prop mutée, `v-model` sur une prop, état copié d'une prop sans `watch`.
- `watch` qui calcule du dérivé, sans nettoyage, ou qui boucle.
- `:key` absente ou fondée sur l'index ; `v-if` avec `v-for`.
- `v-html` avec un contenu non assaini.

Aussi : `div` cliquable au lieu d'un `button`, `label` absent, focus perdu, bibliothèque importée en entier, route lourde non paresseuse.

---

## security

- Audit du lockfile avec le gestionnaire du projet.
- `v-html` et tout HTML externe : assainir (DOMPurify). Pas d'URL `javascript:` dans un `href` dynamique.
- Tout ce qui est préfixé `VITE_` part dans le bundle : aucun secret.
- Session en cookie `HttpOnly`, pas dans `localStorage`.

---

## test

- Vitest avec Vue Test Utils ou Testing Library ; Playwright ou Cypress pour les parcours ; `createTestingPinia`.
- Monter le composant, vérifier le rendu et les événements émis, pas l'état interne.
- Simuler le réseau, pas les modules.

---

## deploy

- `vite build` produit `dist/`, servi par un serveur statique qui renvoie `index.html` pour les routes côté client.
- Les variables `VITE_*` sont fixées au build.
