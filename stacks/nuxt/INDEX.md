# Stack : Nuxt - spécificités

Point d'entrée des spécificités Nuxt (Forme 1 : fichier unique sectionné). L'appelant lit `## core` plus la section correspondant à sa nature. Nuxt s'appuie sur Vue : si `stacks/vue/INDEX.md` existe, le lire aussi (parent). Promouvoir une section en fichier voisin (Forme 2) si elle grossit.

Nature → sections :

| Appelant                           | Sections        |
| ---------------------------------- | --------------- |
| `/max:nuxt`                        | core + dev      |
| `/max:review`, `/max:pr-review`    | core + review   |
| `/max:security`                    | core + security |
| `/max:test`                        | core + test     |
| `/max:docker`, `/max:kubernetes`   | core + deploy   |

---

## core

- **Détection** : dépendance `nuxt` dans `package.json`, présence de `nuxt.config.ts` (ou `.js`), dossier `.nuxt/` généré.
- **Langage** : TypeScript par défaut ; typer les props, les composables et les réponses d'API. `<script setup lang="ts">` pour les composants (Composition API).
- **Structure et auto-imports** : `pages/` (routes par fichiers), `layouts/`, `components/`, `composables/`, `utils/`, `middleware/`, `plugins/`, `assets/`, `public/`, et `server/` pour le serveur. Les composants, composables et utilitaires sont importés automatiquement ; ne pas ajouter d'`import` pour ce que Nuxt auto-importe, et garder des noms uniques.
- **Serveur** : Nitro, dans `server/` : `server/api/` (routes `/api/...`), `server/routes/`, `server/middleware/`, `server/utils/`, avec les gestionnaires `defineEventHandler`.
- **Configuration** : `nuxt.config.ts` (modules, `runtimeConfig`, `routeRules`, `app`, `nitro`). Les valeurs d'environnement passent par `runtimeConfig` (voir sécurité), jamais par `process.env` lu dans le code des composants.
- **Modes de rendu** : rendu serveur (SSR) par défaut ; rendu côté client (`ssr: false`), génération statique (`nuxt generate`), et règles par route (`routeRules` : `prerender`, `swr`, `isr`, `ssr: false`). Choisir le mode par route selon le besoin, et ne pas changer le mode global sans en mesurer les effets.
- **Commandes** : `nuxt dev`, `nuxt build`, `nuxt generate`, `nuxt preview`, `nuxt prepare` (génère les types), `nuxt typecheck`. Selon la version, la CLI s'appelle `nuxt` ou `nuxi` ; lire les scripts de `package.json`. Lancer via le gestionnaire du projet (`pnpm`, `npm`, `yarn`, `bun`) et le runner du projet.

### Versions (Nuxt 3, Nuxt 4)

- **Détecter la version** : `nuxt` dans `package.json` / lockfile, ou `npx nuxt info`.
- **Structure** : Nuxt 4 place le code de l'application dans `app/` (`app/pages`, `app/components`…), à côté de `server/` et `shared/` ; Nuxt 3 utilise la racine. Respecter la structure déjà en place dans le projet.
- **Chargement de données** : le comportement de `useFetch` / `useAsyncData` a évolué entre les versions (partage des données entre appels de même clé, références superficielles par défaut). Vérifier la version avant d'écrire du code qui suppose l'un ou l'autre.
- **Préparer une montée de version** : relever les avertissements de dépréciation en développement, appliquer les options de compatibilité documentées pour la version cible, et tester sur les routes principales ; ne pas affirmer qu'une API existe sans l'avoir vérifiée dans la documentation de la version du projet.
- **Prérequis** : la version de Node requise dépend de la version de Nuxt ; la lire dans la documentation et le champ `engines` plutôt que la supposer.
- **Support** : vérifier l'état de maintenance de la version sur le site officiel de Nuxt ; une version hors support est un constat de fin de vie même sans CVE nommée.

---

## dev

Pour écrire du code Nuxt, consommé par `/max:nuxt`.

- **Composants** : petits, une responsabilité ; props typées avec `defineProps`, événements typés avec `defineEmits`, `defineModel` pour `v-model`. La logique réutilisable va dans des **composables** (`composables/useXxx.ts`), pas dans les composants.
- **Chargement de données** :
  - `useFetch` ou `useAsyncData` + `$fetch` dans les pages et composants pour du rendu serveur sans double requête ; `$fetch` seul dans les gestionnaires d'événements (clic, soumission).
  - Donner une **clé** explicite à `useAsyncData` quand la requête dépend de paramètres ; gérer les états `pending`, `error` et les données vides dans le gabarit.
  - Ne jamais appeler `useFetch` dans un gestionnaire d'événement ni après un `await` hors contexte.
- **État** : `useState('clé', () => valeur)` pour un état partagé et sérialisé entre serveur et client ; Pinia (`@pinia/nuxt`) quand le projet l'utilise. **Jamais** de `ref` ou d'objet défini au niveau du module comme état global : il fuit entre les requêtes serveur.
- **Routage** : routes par fichiers (`[id].vue`, `[...slug].vue`), `definePageMeta` pour le layout, les middlewares et la validation de paramètres ; middlewares de route dans `middleware/` ; `<NuxtLink>` plutôt que `<a>` pour les liens internes ; `navigateTo()` pour les redirections.
- **API serveur** : un gestionnaire par fichier dans `server/api/`, le verbe dans le nom (`users.get.ts`, `users.post.ts`) ; valider les entrées (`getValidatedQuery`, `readValidatedBody` avec un schéma Zod ou Valibot) ; lever `createError({ statusCode, statusMessage })` pour les erreurs ; logique métier dans `server/utils/`, pas dans le gestionnaire.
- **Code propre au client** : tout ce qui touche à `window`, `document` ou `localStorage` va dans `onMounted`, dans `<ClientOnly>` ou derrière `import.meta.client`, pour éviter les erreurs d'hydratation.
- **SEO et métadonnées** : `useHead` / `useSeoMeta` par page ; titres, descriptions, balises Open Graph ; `routeRules` ou `@nuxtjs/sitemap` selon le projet.
- **Styles et assets** : suivre le choix du projet (Tailwind, CSS Modules, SCSS, `@nuxt/ui`) ; images via `<NuxtImg>` / `<NuxtPicture>` (`@nuxt/image`) quand le module est présent.
- **Modules** : n'ajouter un module que s'il apporte une vraie valeur, le déclarer dans `modules` de `nuxt.config.ts`, noter sa version ; vérifier qu'il est maintenu et compatible avec la version de Nuxt du projet.
- **Qualité** : `@nuxt/eslint` ; `nuxt typecheck` doit passer ; pas de `any` ni de `@ts-ignore` sans justification.

---

## review

Consommé par `/max:review` et `/max:pr-review`. S'ajoute aux dimensions génériques.

- **Hydratation** - contenu différent entre serveur et client (`Date.now()`, `Math.random()`, `window`, `localStorage` utilisés au rendu), balises HTML invalides, composants non enveloppés dans `<ClientOnly>` alors qu'ils dépendent du navigateur.
- **État partagé** - état global défini au niveau du module (fuite entre requêtes serveur), `useState` sans clé unique, mutation directe d'une donnée venue de `useFetch` quand une copie est attendue.
- **Chargement de données** - `useFetch` / `useAsyncData` appelé hors de la configuration d'un composant, requête sans clé stable, double requête serveur + client (`$fetch` dans `onMounted` pour des données qui devraient être rendues côté serveur), `pending` / `error` non gérés, cascade de requêtes qui pourraient être parallèles.
- **Réactivité Vue** - perte de réactivité (déstructuration d'un `reactive` ou de `props`), `watch` sans nettoyage, `watchEffect` qui lit trop, `computed` avec effet de bord, `v-for` sans `:key` stable, `v-if` combiné à `v-for`.
- **Composants** - props mutées, trop de responsabilités, logique qui devrait être un composable, événements non déclarés avec `defineEmits`.
- **Serveur** - gestionnaire `server/api` sans validation des entrées, erreurs non converties en `createError`, logique métier collée dans le gestionnaire, réponse qui expose plus de champs que nécessaire.
- **Configuration** - `runtimeConfig` : secret placé dans `public`, valeur lue avec `process.env` ailleurs que dans la configuration, `routeRules` qui change le rendu d'une route sans raison.
- **Performance** - composants lourds sans chargement paresseux (`Lazy` + préfixe, `defineAsyncComponent`), images non optimisées, gros paquets importés en entier (`lodash`), absence de `swr` / `prerender` sur des pages stables, dépendance inutile côté client.
- **Accessibilité et SEO** - `alt` manquant, éléments cliquables non interactifs, titres mal hiérarchisés, `useHead` / `useSeoMeta` absent sur une page publique.
- **Résidus** - `console.log`, `debugger`, code commenté, `TODO` sans issue.
- **Contrôles à lancer** (via le runner, sur les fichiers modifiés quand c'est possible) :
  - `nuxt typecheck` (ou `vue-tsc --noEmit`)
  - `eslint .` (ou le script `lint` du projet)
  - le script de test du projet (Vitest)
  - `nuxt build` quand le changement touche la configuration, les modules ou le rendu

---

## security

Consommé par `/max:security`.

- **Avis de sécurité** : `npm audit` / `pnpm audit` / `yarn npm audit` sur le lockfile (séparer production et développement) ; alertes Dependabot ; GitHub Advisory Database pour `nuxt`, `nitropack`, `h3`, `vue`, `vite` et chaque module installé. Beaucoup de dépendances d'un projet Nuxt sont du build : classer en risque réel faible celles qui ne sont pas livrées, mais pas `nitropack` / `h3` / les modules qui tournent sur le serveur.
- **Fin de vie** : la version de Nuxt et de Node est-elle encore maintenue ? Une version hors support est un constat à part entière.
- **Secrets et configuration** - dans `runtimeConfig`, tout ce qui est **privé** reste à la racine ; seul ce qui est `public` part dans le navigateur. Un secret dans `runtimeConfig.public`, dans `app.config.ts` ou lu par un composant est exposé à tous. Les variables d'environnement se mappent avec le préfixe `NUXT_` (`NUXT_API_SECRET` → `runtimeConfig.apiSecret`). Aucun secret dans `.env` versionné.
- **Routes serveur** - chaque route `server/api` valide ses entrées (corps, paramètres, requête) et vérifie l'authentification et l'autorisation elle-même ; un middleware de route côté client (`middleware/`) **ne protège pas** l'API. Contrôle d'accès sur l'objet demandé (risque d'IDOR).
- **Rendu** - `v-html` avec une donnée venant d'un utilisateur ou d'une API (XSS) : l'assainir (DOMPurify) ou l'éviter ; ne jamais injecter de HTML non fiable via `useHead` (`innerHTML`, `script`).
- **État du rendu serveur** - état partagé au niveau du module : fuite de données d'un utilisateur à un autre (grave si ce sont des données privées).
- **Authentification** - session par cookie `httpOnly`, `secure`, `sameSite` ; solution maintenue (`nuxt-auth-utils`, `@sidebase/nuxt-auth`…) plutôt que du code maison ; jeton jamais stocké dans `localStorage`.
- **En-têtes et abus** - en-têtes de sécurité (CSP, HSTS, `X-Content-Type-Options`, `Referrer-Policy`) via `routeRules.headers` ou le module `nuxt-security` ; CSRF sur les routes qui modifient l'état et utilisent des cookies ; limitation du débit sur la connexion et les routes sensibles ; CORS limité aux origines connues.
- **Fichiers et appels sortants** - envois de fichiers validés (taille, type, extension) ; appels `$fetch` serveur vers une URL fournie par l'utilisateur : risque de SSRF, valider l'hôte.
- **Modules et scripts** - modules tiers à vérifier (maintenus, nombre de téléchargements, auteur) ; scripts tierces chargés avec `useScript` plutôt qu'insérés à la main.
- **Outils complémentaires** - seulement s'ils sont déjà disponibles (ne rien installer) ; sinon « (indispo) » : `gitleaks detect` ou `trufflehog filesystem .` pour les secrets, `semgrep --config p/javascript` pour le code, `trivy fs .` en complément.

---

## test

Consommé par `/max:test`.

- **Outil** : Vitest avec `@nuxt/test-utils` (environnement Nuxt). Lancer via le script `test` de `package.json`, à travers le runner du projet.
- **Niveaux** :
  - **Unitaire** : fonctions de `utils/`, composables sans dépendance à Nuxt, logique de `server/utils/` - Vitest simple, sans environnement Nuxt.
  - **Composant** : `mountSuspended` (de `@nuxt/test-utils/runtime`) monte un composant dans l'environnement Nuxt, avec ses auto-imports, ses plugins et `Suspense` ; `@vue/test-utils` pour interroger le résultat.
  - **API serveur / bout en bout** : `setup()` de `@nuxt/test-utils/e2e` démarre l'application, puis `$fetch()` interroge les routes ; réservé aux parcours importants, plus lent.
  - **Navigateur** : Playwright (`@nuxt/test-utils` s'y intègre) pour quelques parcours critiques seulement.
- **Doublures** : `mockNuxtImport('useFetch', ...)` pour remplacer un composable auto-importé ; `registerEndpoint('/api/xxx', ...)` pour simuler une route d'API ; remplacer `useRuntimeConfig`. Aux frontières seulement : ne pas simuler le composant que l'on teste.
- **Rendu et hydratation** : tester qu'un composant se rend sans erreur de console ni avertissement d'hydratation ; les avertissements `Hydration mismatch` sont des bugs.
- **Déterminisme** : figer l'heure (`vi.useFakeTimers()`, `vi.setSystemTime`), ne pas dépendre du hasard ni du réseau réel, réinitialiser les mocks entre les tests (`vi.restoreAllMocks`).
- **Typage** : `nuxt typecheck` fait partie de la vérification, au même titre que les tests.
- **Couverture** : `vitest run --coverage` (fournisseur `v8`) si installé.

---

## deploy

Consommé par `/max:docker` et `/max:kubernetes` quand le projet est un projet Nuxt. S'ajoute à leurs règles générales.

### Image et Dockerfile

- **Sortie de build** : `nuxt build` produit `.output/` (serveur Nitro autonome, preset `node-server` par défaut). L'image finale ne contient que `.output/` : pas de `node_modules` complet ni de sources.
- **Build multi-stage** : une étape de build (installation depuis le lockfile, `pnpm build` / `npm run build`) et une étape finale légère (`node:<LTS>-alpine` ou `-slim`, version de Node épinglée selon la version de Nuxt) qui copie `.output/` et lance `node .output/server/index.mjs`.
- **Installation reproductible** : `npm ci` / `pnpm install --frozen-lockfile`, pas de `npm install` libre ; cache du gestionnaire de paquets monté (`--mount=type=cache`).
- **Variables d'exécution** : `NITRO_PORT` / `PORT` et `NITRO_HOST` (écouter sur `0.0.0.0` dans un conteneur) ; les variables `NUXT_*` sont lues **à l'exécution** pour `runtimeConfig`, pas figées au build : ne pas les passer en `ARG`.
- **Utilisateur non root**, système de fichiers en lecture seule possible (le serveur Nitro n'écrit pas hors `/tmp` en fonctionnement normal).
- **Santé** : une route `/api/health` minimale (statut 200) pour la readiness et la liveness, qui ne dépend pas d'un service externe pour la liveness.
- **`.dockerignore`** : `node_modules`, `.nuxt`, `.output`, `.env*`, `.git`, `coverage`.
- **Site statique** : avec `nuxt generate` (`.output/public`), servir les fichiers par Nginx ou un CDN ; pas besoin de Node à l'exécution.

### Docker Compose (développement)

- Service `app` : image Node, code monté en bind mount, `node_modules` en volume nommé, port 3000 (`127.0.0.1:3000:3000`), commande `nuxt dev --host 0.0.0.0`.
- Le rechargement à chaud (HMR) peut demander d'exposer le port de Vite / WebSocket ; le tester avant de conclure.

### Kubernetes

- Un Deployment sans état (le serveur Nitro ne stocke rien localement) ; mise à l'échelle horizontale sans souci tant que l'état est dans une base ou un cache partagé (pas de session en mémoire).
- **Configuration** : `ConfigMap` pour les valeurs `NUXT_PUBLIC_*`, `Secret` pour les valeurs `NUXT_*` privées ; elles sont lues à l'exécution, donc un changement demande un redémarrage des pods.
- **Probes** : `readinessProbe` et `livenessProbe` sur `/api/health` ; `startupProbe` si le démarrage est lent.
- **Sécurité du pod** : `readOnlyRootFilesystem: true` avec un `emptyDir` sur `/tmp` ; utilisateur non root.
- **Ressources** : mémoire dimensionnée selon le rendu serveur (SSR) ; surveiller les `OOMKilled`.
- **Assets** : fichiers statiques versionnés (`_nuxt/`) servis par un CDN ou le contrôleur Ingress avec cache long, pour décharger le serveur.

### CI GitHub Actions

- Installation depuis le lockfile avec cache du gestionnaire de paquets (`actions/setup-node` avec `cache`), version de Node épinglée.
- Étapes avant le build d'image : `nuxt prepare`, lint, `nuxt typecheck`, tests, puis `nuxt build`.
- `<sha de la release>` à remplir pour chaque action épinglée ; ne jamais inventer le SHA.
