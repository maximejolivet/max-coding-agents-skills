# Stack : Next.js - spécificités

Point d'entrée des spécificités Next.js (Forme 1 : fichier unique sectionné). L'appelant lit `## core` plus la section correspondant à sa nature. Next.js s'appuie sur React : lire aussi `stacks/react/INDEX.md` (parent). Promouvoir une section en fichier voisin (Forme 2) si elle grossit.

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

- **Détection** : dépendance `next` dans `package.json`, `next.config.*`. Routeur : `app/` (App Router) ou `pages/` (Pages Router) ; ne pas mélanger les conventions et suivre celui du projet. Vérifier la version dans le lockfile et lire le guide de migration de la version cible avant d'affirmer qu'une API existe.
- **Composants serveur par défaut** (App Router) : un composant est un Server Component tant qu'il n'a pas `'use client'`. Mettre `'use client'` le plus bas possible dans l'arbre (état, effets, API du navigateur, gestionnaires d'événements).
- **Fichiers spéciaux** : `layout`, `page`, `loading`, `error`, `not-found`, `route` (handlers), `middleware` ou `proxy` selon la version.
- **Données et cache** : le comportement du cache change selon la version (`fetch`, `revalidate`, `use cache`) ; lire la documentation de la version du projet et ne pas supposer.
- **Commandes** : scripts de `package.json` (`dev`, `build`, `start`, `lint`), via le gestionnaire du lockfile.

---

## dev

- **Récupération de données** dans les Server Components (`async`), en parallèle quand les requêtes sont indépendantes (`Promise.all`) ; `Suspense` + `loading.tsx` pour le streaming.
- **Mutations** : Server Actions (`'use server'`) ou route handlers ; toujours **valider et autoriser côté serveur** (une Server Action est un point d'entrée public).
- **Frontière client/serveur** : ne passer aux composants client que des données sérialisables ; ne jamais importer du code serveur ou un secret dans un composant client.
- **Images, polices, métadonnées** : `next/image` (dimensions), `next/font`, `generateMetadata` ; liens avec `next/link`.
- **Variables d'environnement** : seules celles préfixées `NEXT_PUBLIC_` partent au navigateur.
- **Qualité** : `next lint` / ESLint, `tsc --noEmit`, `next build` doivent passer.

---

## review

- **`'use client'` trop haut** - page entière en client pour un seul bouton, bundle gonflé.
- **Secrets** - variable sans `NEXT_PUBLIC_` lue côté client (échec) ou, pire, secret préfixé `NEXT_PUBLIC_`.
- **Server Actions** sans validation ni contrôle d'accès, données de formulaire utilisées brutes.
- **Données** - cascade de requêtes séquentielles, `fetch` dans un composant client quand le serveur suffit, cache implicite non voulu.
- **Hydratation** - rendu dépendant de `window`, de la date ou de `Math.random` ; `useEffect` pour une donnée disponible côté serveur.
- **Images / SEO** - `<img>` brut sans dimensions, métadonnées manquantes, pas de page `not-found` ni `error`.

---

## security

- **Mises à jour** : `npm audit` / équivalent du gestionnaire ; suivre les avis de sécurité officiels de Next.js et les alertes Dependabot, notamment sur le `middleware` et les Server Actions.
- **Autorisation** : ne pas se reposer uniquement sur le `middleware` pour protéger une donnée ; revérifier la session dans la route, l'action ou le composant serveur.
- **En-têtes** : CSP, `X-Frame-Options`, `Referrer-Policy` via `next.config` ou le middleware ; cookies `HttpOnly`, `Secure`, `SameSite`.
- **Entrées** : validation (Zod) des paramètres de route, de requête et des corps ; pas de `dangerouslySetInnerHTML` avec du contenu non assaini ; SSRF sur les URL fournies à `fetch` côté serveur.

---

## test

- **Outils** : Vitest ou Jest + Testing Library pour les composants ; Playwright pour les parcours. Les Server Components asynchrones se testent mieux en bout en bout.
- **Règles** : tester le comportement visible, simuler le réseau (MSW) plutôt que les modules internes ; `next build` fait office de vérification de types et de routes.

---

## deploy

- **Sortie** : `output: 'standalone'` pour une image Docker minimale ; `next build` puis `node server.js` (ou `next start`).
- **Image** : multi-étapes, utilisateur non root, variables `NEXT_PUBLIC_*` fournies **au build**, autres secrets à l'exécution ; cache d'images (`.next/cache`) persistant si possible.
- **Plateforme** : sur Vercel, les skills Vercel s'appliquent (`vercel:nextjs`, `vercel:deploy`).
