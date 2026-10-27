# Stack : React - spécificités

Point d'entrée des spécificités React (Forme 1 : fichier unique sectionné). L'appelant lit `## core` plus la section correspondant à sa nature. Cette ressource couvre React lui-même (application monopage avec Vite, ou React dans un autre outil) ; Next.js s'appuie dessus : si `stacks/nextjs/INDEX.md` existe, la lire en premier, puis celle-ci (parent). Promouvoir une section en fichier voisin (Forme 2) si elle grossit.

Nature → sections :

| Appelant                           | Sections        |
| ---------------------------------- | --------------- |
| `/max:react`                       | core + dev      |
| `/max:review`, `/max:pr-review`    | core + review   |
| `/max:security`                    | core + security |
| `/max:test`                        | core + test     |
| `/max:docker`, `/max:kubernetes`   | core + deploy   |

---

## core

- **Détection** : dépendance `react` (et `react-dom`) dans `package.json`. Outil de build : `vite.config.*` (Vite), `next.config.*` (Next.js, voir son parent), `webpack.config.*`, ou Create React App (obsolète, à migrer).
- **Composants** : fonctions uniquement (pas de composants de classe dans le nouveau code, sauf `ErrorBoundary` si aucune bibliothèque ne le fournit). Un composant est une fonction **pure** de ses props et de son état : même entrée, même rendu, pas d'effet de bord au rendu.
- **Langage** : TypeScript (`.tsx`) quand le projet l'utilise : props typées, pas de `any`. Suivre le choix existant.
- **Règles des hooks** : appelés au niveau supérieur d'un composant ou d'un hook personnalisé (jamais dans une condition, une boucle ou une fonction imbriquée), nommés `useXxx`. Le plugin `eslint-plugin-react-hooks` doit rester actif et ses avertissements ne sont pas ignorés.
- **Immutabilité** : l'état ne se mute jamais (`push`, `obj.x = …`) ; produire une nouvelle valeur (`[...liste, item]`, `{ ...obj, x }`).
- **Commandes** : lire les scripts de `package.json` (`dev`, `build`, `preview`, `lint`, `test`). Lancer via le gestionnaire du lockfile (`pnpm`, `npm`, `yarn`, `bun`) et le runner du projet.

### Versions (React 18, React 19)

- **Détecter la version** : `react` dans `package.json` / lockfile.
- **React 19** apporte notamment les *Actions* (fonctions asynchrones passées à `<form action>`), les hooks `useActionState`, `useOptimistic`, `useFormStatus`, le hook `use` (lecture d'une promesse ou d'un contexte), `ref` passé comme une simple prop (plus besoin de `forwardRef` pour les nouveaux composants) et les métadonnées de document (`<title>`, `<meta>`) dans les composants. Ne pas utiliser ces API dans un projet resté en React 18.
- **Compilateur React** : s'il est activé dans le projet, il mémoïse automatiquement ; ne pas ajouter de `useMemo` / `useCallback` par réflexe. S'il ne l'est pas, ne pas le supposer.
- **Mode strict** : `<StrictMode>` rend deux fois en développement pour révéler les effets impurs ; un effet qui "marche deux fois" révèle un manque de nettoyage, pas un bug de React.
- **Migrer** : lire le guide de migration officiel de la version cible, relever les avertissements de la console, et ne pas affirmer qu'une API existe sans l'avoir vérifiée dans la documentation de la version du projet.
- **Support** : vérifier l'état de maintenance de la version sur le site officiel ; une version hors support est un constat de fin de vie.

---

## dev

Pour écrire du code React, consommé par `/max:react`.

- **Composition** : petits composants, une responsabilité ; préférer la composition (`children`, slots par props) à l'héritage ou aux drapeaux booléens en cascade. Extraire un **hook personnalisé** quand une logique avec état est réutilisée ou alourdit un composant.
- **Où mettre l'état** : au plus près de son usage (colocation) ; le remonter seulement quand plusieurs composants le partagent. N'utiliser un contexte (`useContext`) ou une bibliothèque d'état (Zustand, Redux Toolkit, Jotai…) que pour un état réellement partagé et fréquent ; suivre le choix du projet.
- **État dérivé** : calculer pendant le rendu (`const total = items.reduce(…)`), ne pas le stocker dans un état synchronisé par `useEffect`.
- **Effets (`useEffect`)** : seulement pour se synchroniser avec un système **extérieur** à React (abonnement, minuteur, API du navigateur, requête). Pas pour transformer des données, ni réagir à un clic (qui va dans le gestionnaire d'événement). Toujours un **nettoyage** quand l'effet crée un abonnement, et un tableau de dépendances complet.
- **Données du serveur** : TanStack Query (ou SWR, ou les chargeurs du routeur, ou React 19 `use` + Suspense) plutôt que `fetch` dans `useEffect` ; gérer les états de chargement, d'erreur et les données vides ; annuler ou ignorer les réponses obsolètes (condition de course) si l'on fait un `fetch` à la main.
- **Formulaires** : composants contrôlés pour les cas simples ; React Hook Form + Zod pour les formulaires riches ; en React 19, les Actions avec `useActionState`. Validation côté serveur même si le client valide.
- **Routage** : React Router, TanStack Router ou le routeur du framework ; routes chargées paresseusement (`React.lazy` + `Suspense`) ; une page d'erreur et une page 404.
- **Listes** : `key` stable et unique (identifiant métier), jamais l'index pour une liste qui change.
- **Performances** : mesurer avant d'optimiser (React DevTools Profiler). `memo`, `useMemo`, `useCallback` seulement quand un coût réel est mesuré ou qu'une référence doit rester stable ; virtualiser les très longues listes.
- **Erreurs** : `ErrorBoundary` autour des zones indépendantes ; ne pas avaler les erreurs en silence.
- **Accessibilité** : éléments sémantiques (`button`, `a`, `label`), `alt`, focus géré à l'ouverture et à la fermeture d'une fenêtre modale, navigation au clavier, attributs ARIA seulement quand le HTML ne suffit pas.
- **Styles** : suivre le choix du projet (CSS Modules, Tailwind, styled-components, bibliothèque de composants) ; ne pas en mélanger plusieurs.
- **Structure** : organisation par fonctionnalité (`features/<nom>/` avec composants, hooks, API, tests) ou par type, selon l'existant ; un fichier = un composant exporté.
- **Qualité** : ESLint (avec `react-hooks`), Prettier, `tsc --noEmit` doivent passer ; pas de `@ts-ignore` ni de `eslint-disable` sans justification.

---

## review

Consommé par `/max:review` et `/max:pr-review`. S'ajoute aux dimensions génériques.

- **Effets** - `useEffect` utilisé pour dériver un état ou réagir à un événement, dépendances manquantes ou désactivées par `eslint-disable`, absence de nettoyage (abonnement, minuteur, `addEventListener`), `fetch` sans gestion de la condition de course, boucle de rendu infinie.
- **État** - mutation directe de l'état ou d'une prop, état dérivé stocké au lieu d'être calculé, état trop haut dans l'arbre, `setState` appelé pendant le rendu, état local dupliqué par rapport à une source de vérité (props, serveur, URL).
- **Hooks** - appel conditionnel, hook dans une boucle ou une fonction imbriquée, logique répétée qui devrait être un hook personnalisé.
- **Listes** - `key` absente, instable ou basée sur l'index pour une liste dynamique, composant défini à l'intérieur d'un autre composant (remonté à chaque rendu).
- **Rendus inutiles** - objets ou fonctions recréés et passés en props à des composants mémoïsés, contexte qui change souvent et fait re-rendre tout l'arbre, `memo` / `useMemo` / `useCallback` ajoutés sans mesure.
- **Données** - requêtes dans `useEffect` quand le projet a une bibliothèque de requêtes, absence des états de chargement / d'erreur / vide, cascade de requêtes qui pourraient être parallèles.
- **Types** - `any`, assertions `as` qui cachent un vrai problème, props optionnelles sans valeur par défaut gérée, types de réponse d'API non vérifiés.
- **Accessibilité** - `div` ou `span` cliquable à la place d'un `button`, `label` manquant, `alt` absent, focus perdu, `autoFocus` abusif.
- **Gestion des erreurs** - pas de frontière d'erreur, erreur avalée (`catch` vide), message d'erreur technique montré à l'utilisateur.
- **Taille du paquet** - import d'une bibliothèque entière pour une fonction, pas de chargement paresseux d'une route lourde, dépendance dupliquée.
- **Résidus** - `console.log`, `debugger`, code commenté, `TODO` sans issue.
- **Contrôles à lancer** (via le runner, sur les fichiers modifiés quand c'est possible) :
  - `tsc --noEmit`
  - `eslint .` (ou le script `lint` du projet, avec `react-hooks`)
  - `prettier --check`
  - le script de test du projet (Vitest ou Jest)
  - `build` quand le changement touche la configuration ou les dépendances

---

## security

Consommé par `/max:security`.

- **Avis de sécurité** : `npm audit` / `pnpm audit` / `yarn npm audit` sur le lockfile (séparer production et développement) ; alertes Dependabot ; GitHub Advisory Database pour `react`, `react-dom`, le routeur et chaque bibliothèque installée. Dans une application monopage, tout ce qui est importé est livré au navigateur : une CVE sur du code exécuté côté client compte ; les outils de build ne sont que du risque faible.
- **Fin de vie** : la version de React et de Node est-elle encore maintenue ?
- **XSS** :
  - `dangerouslySetInnerHTML` avec une donnée venant d'un utilisateur ou d'une API : l'assainir (DOMPurify) ou l'éviter.
  - URL non vérifiée dans `href` / `src` (`javascript:`) : valider le protocole.
  - HTML non fiable injecté par une bibliothèque de rendu Markdown sans assainissement.
  - Rendu côté serveur : données initiales sérialisées dans le HTML (`window.__STATE__ = …`) sans échappement.
- **Secrets** : **tout ce qui est dans le paquet livré est public**. Les variables d'environnement lues par le client (`VITE_*`, `REACT_APP_*`, `NEXT_PUBLIC_*`) sont incluses dans le JavaScript : aucune clé secrète, aucun jeton privé. Une clé d'API qui doit rester secrète passe par un serveur (API intermédiaire). Vérifier aussi les cartes de sources (`sourcemap`) publiées en production.
- **Authentification** : jeton de session dans un cookie `httpOnly`, `secure`, `sameSite`, pas dans `localStorage` / `sessionStorage` (lisibles par n'importe quel script injecté) ; l'accès côté client (routes protégées) n'est qu'un confort d'interface - **l'autorisation se vérifie côté serveur**.
- **Requêtes** : CORS limité aux origines connues côté API ; protection CSRF quand l'authentification repose sur des cookies ; pas de données sensibles dans l'URL.
- **Scripts tiers** : charger un script externe (analytique, widget) avec intégrité (`integrity`) et une politique CSP ; limiter ce qu'un tiers peut lire.
- **En-têtes** : CSP, `X-Content-Type-Options`, `Referrer-Policy`, HSTS configurés sur le serveur ou le CDN qui sert l'application.
- **Dépendances** : paquets maintenus, versions épinglées par le lockfile, attention aux paquets homonymes (typosquatting) et aux scripts `postinstall`.
- **Outils complémentaires** - seulement s'ils sont déjà disponibles (ne rien installer) ; sinon « (indispo) » : `gitleaks detect` ou `trufflehog filesystem .` pour les secrets, `semgrep --config p/react` pour le code, `trivy fs .` en complément.

---

## test

Consommé par `/max:test`.

- **Outil** : Vitest (projets Vite) ou Jest, avec **React Testing Library** (`@testing-library/react`) et `@testing-library/user-event` ; `@testing-library/jest-dom` pour les assertions DOM. Lancer via le script `test` de `package.json`, à travers le runner du projet.
- **Principe** : tester le **comportement visible par l'utilisateur**, pas l'implémentation. Interroger par rôle et par texte accessible (`getByRole('button', { name: /enregistrer/i })`), pas par classe CSS ni par structure interne ; `findBy*` / `waitFor` pour l'asynchrone, jamais un `sleep`.
- **Interactions** : `userEvent.setup()` puis `await user.click(…)`, plus fidèle aux vrais événements que `fireEvent`.
- **Niveaux** :
  - **Unitaire** : fonctions pures, reducers, hooks personnalisés (`renderHook`) ;
  - **Composant** : un composant rendu avec ses fournisseurs (routeur, `QueryClientProvider`, contexte) via une fonction utilitaire `renderWithProviders` ;
  - **Navigateur** : Playwright ou Cypress pour quelques parcours critiques seulement.
- **Réseau** : simuler les appels avec **MSW** (`msw`) plutôt que de moquer `fetch` à la main ; chaque test déclare ses réponses ; `QueryClient` neuf par test (retries désactivés) pour éviter les fuites d'état.
- **Doublures** : aux frontières seulement (réseau, horloge, API du navigateur) ; ne pas simuler les composants enfants sauf nécessité.
- **Déterminisme** : `vi.useFakeTimers()` / `jest.useFakeTimers()` pour les minuteurs, figer la date, réinitialiser les mocks entre les tests ; un test ne dépend pas de l'ordre.
- **Avertissements `act`** : un avertissement `not wrapped in act(...)` signale une mise à jour d'état non attendue - attendre le résultat avec `findBy*` plutôt que de l'ignorer.
- **Snapshots** : à éviter pour des composants entiers (fragiles, peu lisibles) ; réserver à de petites sorties stables.
- **Accessibilité** : `jest-axe` / `vitest-axe` si le projet l'a, comme filet de sécurité.
- **Couverture** : `vitest run --coverage` ou `jest --coverage` si installé.

---

## deploy

Consommé par `/max:docker` et `/max:kubernetes` quand le projet est un projet React. S'ajoute à leurs règles générales. (Pour Next.js, la ressource `nextjs` prime : il a un serveur Node.)

### Image et Dockerfile

- **Application monopage (Vite)** : `npm run build` produit des fichiers **statiques** dans `dist/`. Pas besoin de Node à l'exécution : build multi-stage, étape de build Node (installation depuis le lockfile : `npm ci` / `pnpm install --frozen-lockfile`) puis une étape finale `nginx` (image légère, version épinglée) qui sert `dist/`.
- **Configuration Nginx** : repli SPA (`try_files $uri $uri/ /index.html;`) pour que les routes côté client fonctionnent au rechargement ; cache long et `immutable` pour les fichiers avec empreinte (`assets/*`), `no-cache` pour `index.html` ; compression (`gzip` / `brotli`) ; en-têtes de sécurité (CSP, `X-Content-Type-Options`, `Referrer-Policy`).
- **Variables d'environnement** : celles du build (`VITE_*`) sont **figées dans le JavaScript** au moment du `build` : une même image ne peut pas changer d'environnement. Pour une image unique déployée partout, charger la configuration à l'exécution (fichier `config.js` / `env.js` généré au démarrage du conteneur à partir de variables, lu par l'application) plutôt que de reconstruire. Aucun secret dans ces variables : elles sont publiques.
- **Utilisateur non root** : image Nginx sans privilèges (écoute sur un port > 1024, ex. 8080) ; `readOnlyRootFilesystem` possible avec des `emptyDir` pour les répertoires que Nginx doit écrire (`/tmp`, `/var/cache/nginx`, `/var/run`).
- **Santé** : une route statique (`/healthz` renvoyant 200 depuis la configuration Nginx) pour la readiness et la liveness.
- **`.dockerignore`** : `node_modules`, `dist`, `.env*`, `.git`, `coverage`.

### Docker Compose (développement)

- Service `app` : image Node, code monté en bind mount, `node_modules` en volume nommé, commande `vite --host 0.0.0.0`, port `127.0.0.1:5173:5173`. Le rechargement à chaud (HMR) peut demander d'exposer le port WebSocket de Vite ; le tester avant de conclure.
- L'API est un autre service ; configurer le proxy de développement de Vite plutôt que d'activer CORS partout.

### Kubernetes

- Un Deployment sans état servant des fichiers statiques ; plusieurs réplicas sans difficulté, ressources très faibles.
- **Configuration** : `ConfigMap` monté en fichier `config.js` / `env.js` (lu au chargement de la page) pour changer d'environnement sans reconstruire l'image.
- **Probes** : `readinessProbe` et `livenessProbe` HTTP sur `/healthz`.
- **Sécurité du pod** : utilisateur non root, `readOnlyRootFilesystem: true` avec `emptyDir` sur les répertoires d'écriture de Nginx.
- **Exposition** : `Ingress` avec TLS ; assets fingerprintés servis avec cache long, éventuellement par un CDN devant l'application.

### CI GitHub Actions

- Installation depuis le lockfile avec cache du gestionnaire de paquets (`actions/setup-node` avec `cache`), version de Node épinglée.
- Étapes avant le build d'image : lint, `tsc --noEmit`, tests, puis `build`.
- `<sha de la release>` à remplir pour chaque action épinglée ; ne jamais inventer le SHA.
