# Nuxt

```bash
grep -E '"(nuxt|vue|nitropack|typescript)"' package.json
ls nuxt.config.* app pages components composables server 2>/dev/null
```

Lire `## core`, puis la section de la nature (tableau : `<max>/stacks/DETECT.md`), puis `<max>/stacks/vue/INDEX.md` (parent). Valable pour Nuxt 3 et 4.

---

## core

### Repérer

- Signaux : dépendance `nuxt`, `nuxt.config.ts`, dossier `.nuxt/`.
- CLI : `nuxt` ou `nuxi` selon la version. Lire les scripts de `package.json`.
- Gestionnaire : celui du lockfile, jamais un autre.
- Mode de rendu : `ssr`, `routeRules`, `nuxt generate`. Il fixe ce qui est permis côté serveur et côté client.

### Règles

- Les composants, composables et utilitaires sont auto-importés : aucun `import` pour eux, noms uniques.
- Serveur Nitro dans `server/` : `api/`, `routes/`, `middleware/`, `utils/`, gestionnaires `defineEventHandler`.
- Les valeurs d'environnement passent par `runtimeConfig`, jamais par `process.env` dans un composant.
- Le mode de rendu se choisit par route (`routeRules`). Ne pas changer le mode global pour un cas isolé.
- TypeScript : props, composables et réponses d'API typés.

### Versions

| Sujet | Nuxt 3 | Nuxt 4 |
| :-- | :-- | :-- |
| Code de l'application | à la racine | dans `app/`, à côté de `server/` et `shared/` |
| `useFetch` / `useAsyncData` | comportement d'origine | données partagées par clé, références superficielles par défaut |

- Repérer la version : `package.json`, lockfile ou `npx nuxt info`.
- Respecter la structure en place.
- Version de Node : la lire dans `engines` et la documentation, ne pas la supposer.
- Version hors support sur le site officiel : constat de fin de vie.
- Ne pas affirmer qu'une API existe sans l'avoir lue dans la documentation de la version du projet.

---

## dev

### Données

- Pages et composants : `useFetch` ou `useAsyncData` + `$fetch`, pour éviter la double requête serveur puis client.
- Gestionnaires d'événements : `$fetch` seul. Jamais `useFetch` dans un gestionnaire ni après un `await` hors contexte.
- Clé explicite pour `useAsyncData` quand la requête dépend de paramètres.
- Traiter `pending`, `error` et le cas vide dans le gabarit.

### État et client

- État partagé : `useState('clé', () => valeur)` ou Pinia. Jamais de `ref` au niveau d'un module : il fuit d'une requête serveur à l'autre.
- `window`, `document`, `localStorage` : dans `onMounted`, `<ClientOnly>` ou derrière `import.meta.client`.
- Logique réutilisable dans `composables/useXxx.ts`, pas dans les composants.

### Routage et serveur

- Routes par fichiers ; `definePageMeta` pour le layout, les middlewares et la validation des paramètres.
- `<NuxtLink>` et `navigateTo()` pour la navigation interne.
- Un gestionnaire par fichier dans `server/api/`, verbe dans le nom (`users.post.ts`).
- Entrées validées : `getValidatedQuery`, `readValidatedBody` avec un schéma Zod ou Valibot.
- Erreurs : `createError({ statusCode, statusMessage })`. Logique métier dans `server/utils/`.

### Vérifier

```bash
<gestionnaire> run lint
npx nuxt typecheck
<gestionnaire> run test
<gestionnaire> run build     # si la configuration, un module ou le rendu change
```

### Ne pas faire sans accord

- Ajouter un module ou une dépendance. Vérifier d'abord qu'il est maintenu et compatible avec la version.
- Désactiver une validation serveur, un contrôle d'accès ou l'assainissement du HTML.
- Appeler une API de production depuis les tests ou le développement.

---

## review

### Hydratation et état

- Rendu qui diffère entre serveur et client : `Date.now()`, `Math.random()`, `window`, `localStorage`.
- Composant dépendant du navigateur hors de `<ClientOnly>`.
- État global au niveau d'un module.
- `useState` sans clé unique.
- Mutation directe d'une donnée de `useFetch` quand une copie est attendue.

### Données

- `useFetch` ou `useAsyncData` hors de la configuration d'un composant, ou sans clé stable.
- `$fetch` dans `onMounted` pour des données à rendre côté serveur.
- `pending` et `error` non traités.
- Requêtes en cascade qui pourraient être parallèles.

### Serveur et configuration

- Gestionnaire `server/api` sans validation des entrées.
- Erreur non convertie en `createError`.
- Réponse qui expose plus de champs que nécessaire.
- Secret dans `runtimeConfig.public`, `process.env` lu hors de la configuration.
- `routeRules` qui change le rendu d'une route sans raison.

### Composants, performance, accessibilité

- Les points de `<max>/stacks/vue/INDEX.md` > `review`.
- Composant lourd sans préfixe `Lazy` ni `defineAsyncComponent`, images non optimisées, paquet importé en entier.
- Page stable sans `swr` ni `prerender`.
- Page publique sans `useHead` / `useSeoMeta`.
- `console.log`, `debugger`, code commenté, `TODO` sans issue.

### Contrôles à lancer

Les commandes de `dev` > « Vérifier », sur les fichiers modifiés si possible.

---

## security

### Avis et fin de vie

- Audit du lockfile avec le gestionnaire du projet, production et développement séparés.
- GitHub Advisory Database pour `nuxt`, `nitropack`, `h3`, `vue`, `vite` et chaque module.
- Une dépendance de build non livrée pèse peu. `nitropack`, `h3` et les modules qui tournent côté serveur pèsent plein.
- Version de Nuxt ou de Node hors support : constat à part entière.

### Secrets

- `runtimeConfig` : le privé à la racine, seul `public` part au navigateur.
- Un secret dans `runtimeConfig.public`, `app.config.ts` ou un composant est public.
- Variables préfixées `NUXT_` (`NUXT_API_SECRET` alimente `runtimeConfig.apiSecret`). Aucun secret dans un `.env` versionné.

### Routes serveur et rendu

- Chaque route `server/api` vérifie elle-même l'authentification et l'autorisation. Un middleware de `middleware/` ne protège pas l'API.
- Contrôle d'accès sur l'objet demandé (IDOR).
- `v-html` et `useHead` (`innerHTML`, `script`) avec une donnée non fiable : assainir ou éviter.
- `$fetch` serveur vers une URL fournie par l'utilisateur : valider l'hôte (SSRF).
- Fichiers envoyés : taille, type, extension.

### Session et en-têtes

- Cookie de session `httpOnly`, `secure`, `sameSite`. Aucun jeton dans `localStorage`.
- Solution maintenue (`nuxt-auth-utils`, `@sidebase/nuxt-auth`) plutôt que du code maison.
- En-têtes via `routeRules.headers` ou `nuxt-security` : CSP, HSTS, `X-Content-Type-Options`, `Referrer-Policy`.
- CSRF sur les routes à cookies qui modifient l'état ; limitation de débit sur la connexion ; CORS aux origines connues.
- Scripts tiers par `useScript`.

### Outils complémentaires

S'ils sont déjà disponibles ; sinon « (indispo) » : `gitleaks detect`, `trufflehog filesystem .`, `semgrep --config p/javascript`, `trivy fs .`.

---

## test

Vitest avec `@nuxt/test-utils`, lancé par le script `test`.

| Niveau | Moyen | Pour |
| :-- | :-- | :-- |
| Unitaire | Vitest seul | `utils/`, `server/utils/`, composables sans Nuxt |
| Composant | `mountSuspended` de `@nuxt/test-utils/runtime` | un composant avec auto-imports et plugins |
| Route serveur | `setup()` de `@nuxt/test-utils/e2e`, puis `$fetch()` | parcours importants ; lent |
| Navigateur | Playwright | quelques parcours critiques |

- Doublures : `mockNuxtImport('useFetch', ...)`, `registerEndpoint('/api/xxx', ...)`, `useRuntimeConfig` remplacé.
- Un avertissement `Hydration mismatch` est un bug, pas du bruit.
- Heure figée (`vi.useFakeTimers()`, `vi.setSystemTime`), mocks remis à zéro (`vi.restoreAllMocks`).
- `nuxt typecheck` fait partie de la vérification.
- Couverture : `vitest run --coverage` si installé.

---

## deploy

### Image

- `nuxt build` produit `.output/`. L'image finale ne contient que ce dossier et lance `node .output/server/index.mjs`.
- Installation depuis le lockfile (`npm ci`, `pnpm install --frozen-lockfile`).
- Les variables `NUXT_*` se lisent à l'exécution : ne pas les passer en `ARG`.
- `NITRO_HOST=0.0.0.0`, port par `NITRO_PORT` ou `PORT`.
- `.dockerignore` : `node_modules`, `.nuxt`, `.output`, `.env*`, `.git`.

Site statique (`nuxt generate`) : servir `.output/public` par Nginx ou un CDN, sans Node.

### Compose et Kubernetes

- Développement : `nuxt dev --host 0.0.0.0`, port `127.0.0.1:3000:3000`, `node_modules` en volume nommé. Tester le rechargement à chaud avant de conclure.
- Santé : route `/api/health`, sans dépendance externe pour la liveness.
- `ConfigMap` pour `NUXT_PUBLIC_*`, `Secret` pour le reste ; un changement demande un redémarrage des pods.
- `readOnlyRootFilesystem: true` avec `emptyDir` sur `/tmp`.
- Aucune session en mémoire dès qu'il y a plusieurs réplicas.

### CI

`nuxt prepare`, lint, `nuxt typecheck`, tests, puis `nuxt build`.
