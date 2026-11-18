# React

```bash
grep -E '"(react|react-dom|typescript|vite|next|react-router|@tanstack/react-query)"' package.json
ls vite.config.* next.config.* tsconfig.json src app 2>/dev/null
```

Lire `## core`, puis la section de la nature (tableau : `<max>/stacks/DETECT.md`). Sur un projet Next.js, lire d'abord `<max>/stacks/nextjs/INDEX.md`. Valable pour React 18 et 19.

---

## core

### Repérer

- Signaux : dépendances `react` et `react-dom`.
- Outil de build : Vite, Next.js, Webpack. Create React App est obsolète.
- Gestionnaire : celui du lockfile.
- Bibliothèques déjà retenues pour le routage, les données, les formulaires, l'état et les styles : s'y tenir.

### Règles

- Un composant est une fonction pure de ses props et de son état. Aucun effet de bord pendant le rendu.
- Hooks au niveau supérieur seulement, jamais dans une condition, une boucle ou une fonction imbriquée.
- `eslint-plugin-react-hooks` reste actif. `exhaustive-deps` ne se désactive pas : corriger la cause.
- L'état ne se mute pas : `[...liste, item]`, `{ ...obj, x }`.
- TypeScript quand le projet l'emploie : props typées, pas de `any`.

### Versions

| Sujet | React 18 | React 19 |
| :-- | :-- | :-- |
| Actions, `useActionState`, `useOptimistic`, `useFormStatus`, `use` | absents | disponibles |
| `ref` | `forwardRef` | simple prop |
| `<title>`, `<meta>` dans un composant | non | oui |

- Compilateur React actif : pas de `useMemo` ni `useCallback` par réflexe. Inactif : ne pas le supposer.
- `<StrictMode>` rend deux fois en développement. Un effet qui casse au second passage manque de nettoyage.
- Ne pas affirmer qu'une API existe sans l'avoir lue dans la documentation de la version du projet.
- Version hors support : constat de fin de vie.

---

## dev

### État et effets

- État au plus près de son usage. Contexte ou bibliothèque d'état seulement pour un état réellement partagé.
- L'état dérivé se calcule pendant le rendu, pas dans un `useEffect`.
- `useEffect` sert à se synchroniser avec un système extérieur à React. Jamais pour transformer des données ni réagir à un clic.
- Tout effet qui s'abonne se nettoie, avec un tableau de dépendances complet.
- `memo`, `useMemo`, `useCallback` : après une mesure, ou pour stabiliser une référence.

### Données et formulaires

- Données serveur : TanStack Query, SWR, chargeurs du routeur ou `use` avec Suspense, plutôt que `fetch` dans `useEffect`.
- Un `fetch` à la main annule ou ignore les réponses obsolètes.
- Traiter le chargement, l'erreur et le cas vide.
- Formulaires riches : React Hook Form et Zod ; en React 19, Actions et `useActionState`. La validation serveur reste.

### Structure

- `key` stable tirée d'un identifiant métier, jamais l'index d'une liste qui change.
- Routes lourdes en `React.lazy` et `Suspense` ; une page d'erreur et une page 404.
- `ErrorBoundary` autour des zones indépendantes.
- Une seule solution de styles par projet.

### Vérifier

```bash
<gestionnaire> run lint      # avec react-hooks
npx tsc --noEmit
<gestionnaire> run test
<gestionnaire> run build     # si la configuration ou les dépendances changent
```

### Ne pas faire sans accord

- Ajouter une bibliothèque. Vérifier d'abord qu'elle est maintenue et compatible avec la version de React.
- `dangerouslySetInnerHTML` avec une donnée non assainie.
- Appeler une API de production depuis les tests ou le développement.

---

## review

### Effets et état

- `useEffect` qui dérive un état ou réagit à un événement.
- Dépendances manquantes ou masquées par `eslint-disable`.
- Nettoyage absent : abonnement, minuteur, `addEventListener`.
- Mutation de l'état ou d'une prop, `setState` pendant le rendu.
- État local qui duplique les props, le serveur ou l'URL.

### Hooks, listes, rendus

- Hook appelé dans une condition, une boucle ou une fonction imbriquée.
- `key` absente, instable ou fondée sur l'index.
- Composant défini dans un autre composant.
- Objets ou fonctions recréés et passés à des composants mémoïsés.
- `memo`, `useMemo`, `useCallback` ajoutés sans mesure.

### Données et types

- Requête dans `useEffect` alors que le projet a une bibliothèque de requêtes.
- `fetch` sans traitement de la condition de course.
- Chargement, erreur ou cas vide absents ; requêtes en cascade.
- `any`, assertion `as` qui cache un problème, réponse d'API non vérifiée.

### Accessibilité, erreurs, poids

- `div` ou `span` cliquable, `label` ou `alt` absent, focus perdu, `autoFocus` abusif.
- Aucune frontière d'erreur, `catch` vide, message technique montré à l'utilisateur.
- Bibliothèque importée en entier, route lourde non paresseuse, dépendance dupliquée.
- `console.log`, `debugger`, code commenté, `TODO` sans issue.

### Contrôles à lancer

Les commandes de `dev` > « Vérifier », plus `prettier --check`, sur les fichiers modifiés si possible.

---

## security

### Avis et fin de vie

- Audit du lockfile avec le gestionnaire du projet, production et développement séparés.
- GitHub Advisory Database pour `react`, `react-dom`, le routeur et chaque bibliothèque.
- Dans une application monopage, tout import est livré au navigateur. Les outils de build pèsent peu.
- Version de React ou de Node hors support : constat à part entière.

### XSS

- `dangerouslySetInnerHTML` avec une donnée d'utilisateur ou d'API : assainir (DOMPurify) ou éviter.
- URL non vérifiée dans `href` ou `src` (`javascript:`).
- Rendu Markdown sans assainissement.
- Données initiales sérialisées dans le HTML sans échappement (`window.__STATE__`).

### Secrets et session

- Tout ce qui est dans le paquet livré est public : `VITE_*`, `REACT_APP_*`, `NEXT_PUBLIC_*`.
- Une clé secrète passe par un serveur intermédiaire.
- Cartes de sources publiées en production : à vérifier.
- Session en cookie `httpOnly`, `secure`, `sameSite`, pas dans `localStorage`.
- Une route protégée côté client est un confort d'interface. L'autorisation se vérifie côté serveur.

### Requêtes, tiers, dépendances

- CORS limité aux origines connues ; CSRF quand la session repose sur des cookies ; rien de sensible dans l'URL.
- Script tiers avec `integrity` et CSP.
- En-têtes sur le serveur ou le CDN : CSP, `X-Content-Type-Options`, `Referrer-Policy`, HSTS.
- Paquets homonymes (typosquatting) et scripts `postinstall`.

### Outils complémentaires

S'ils sont déjà disponibles ; sinon « (indispo) » : `gitleaks detect`, `trufflehog filesystem .`, `semgrep --config p/react`, `trivy fs .`.

---

## test

Vitest ou Jest, avec React Testing Library, `user-event` et `jest-dom`, par le script `test`.

- Interroger par rôle et texte accessible (`getByRole('button', { name: /save/i })`), pas par classe CSS.
- Asynchrone : `findBy*` ou `waitFor`, jamais `sleep`.
- Interactions : `userEvent.setup()`, puis `await user.click(…)`.
- Réseau : MSW ; un `QueryClient` neuf par test, retries coupés.
- Un avertissement `not wrapped in act(...)` signale une mise à jour non attendue : attendre avec `findBy*`.

| Niveau | Moyen |
| :-- | :-- |
| Unitaire | fonctions pures, reducers, hooks par `renderHook` |
| Composant | rendu avec ses fournisseurs par un utilitaire `renderWithProviders` |
| Navigateur | Playwright ou Cypress, quelques parcours critiques |

Pas de snapshot d'un composant entier. Minuteurs et date figés. Couverture : `vitest run --coverage` ou `jest --coverage` si installé.

---

## deploy

Pour Next.js, la ressource `nextjs` prime : il a un serveur Node.

### Image

- `npm run build` produit des fichiers statiques dans `dist/`. Étape de build Node, étape finale `nginx` épinglée.
- Nginx : `try_files $uri $uri/ /index.html;`, cache long et `immutable` pour `assets/*`, `no-cache` pour `index.html`.
- Les variables `VITE_*` sont figées au build. Pour une image unique, générer `config.js` au démarrage du conteneur.
- Nginx sans privilèges sur un port supérieur à 1024, avec `emptyDir` sur `/tmp`, `/var/cache/nginx`, `/var/run`.
- `.dockerignore` : `node_modules`, `dist`, `.env*`, `.git`.

### Compose, Kubernetes, CI

- Développement : `vite --host 0.0.0.0`, port `127.0.0.1:5173:5173`. Proxy de Vite vers l'API plutôt que CORS ouvert.
- Santé : route statique `/healthz` servie par Nginx.
- `ConfigMap` monté en `config.js` pour changer d'environnement sans reconstruire.
- CI : lint, `tsc --noEmit`, tests, puis `build`.
