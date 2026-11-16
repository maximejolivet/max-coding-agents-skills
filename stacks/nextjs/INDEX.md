# Stack : Next.js - spécificités

Point d'entrée des particularités de Next.js (Forme 1 : un fichier unique découpé en sections). Le skill appelant lit `## core` puis la section correspondant à sa nature. Next.js repose sur React : lire aussi `stacks/react/INDEX.md` (le parent). Si une section grossit trop, la promouvoir en fichier voisin (Forme 2).

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

- **Détection** : dépendance `next` dans `package.json`, `next.config.*`. Routeur : `app/` (App Router) ou `pages/` (Pages Router) ; ne pas mélanger les conventions, suivre celui du projet. Vérifier la version dans le lockfile et lire le guide de migration de la version visée avant d'affirmer qu'une API existe.
- **Composants serveur par défaut** (App Router) : un composant reste un Server Component tant qu'il ne porte pas `'use client'`. Placer `'use client'` le plus bas possible dans l'arbre (état, effets, API du navigateur, gestionnaires d'événements).
- **Fichiers spéciaux** : `layout`, `page`, `loading`, `error`, `not-found`, `route` (handlers), `middleware` ou `proxy` selon la version.
- **Données et cache** : le comportement du cache varie selon la version (`fetch`, `revalidate`, `use cache`) ; lire la documentation de la version du projet sans rien supposer.
- **Commandes** : scripts de `package.json` (`dev`, `build`, `start`, `lint`), avec le gestionnaire du lockfile.

---

## dev

- **Chargement de données** dans les Server Components (`async`), en parallèle quand les requêtes sont indépendantes (`Promise.all`) ; `Suspense` et `loading.tsx` pour le streaming.
- **Mutations** : Server Actions (`'use server'`) ou route handlers ; toujours **valider et autoriser côté serveur** (une Server Action est un point d'entrée public).
- **Frontière client/serveur** : ne transmettre aux composants client que des données sérialisables ; jamais de code serveur ni de secret importé dans un composant client.
- **Images, polices, métadonnées** : `next/image` (dimensions), `next/font`, `generateMetadata` ; liens via `next/link`.
- **Variables d'environnement** : seules celles préfixées `NEXT_PUBLIC_` partent au navigateur.
- **Qualité** : `next lint` / ESLint, `tsc --noEmit` et `next build` doivent passer.

---

## review

- **`'use client'` placé trop haut** : page entière en client pour un seul bouton, bundle gonflé.
- **Secrets** : variable sans `NEXT_PUBLIC_` lue côté client (échec) ou, pire, secret préfixé `NEXT_PUBLIC_`.
- **Server Actions** sans validation ni contrôle d'accès, données de formulaire utilisées brutes.
- **Données** : cascade de requêtes séquentielles, `fetch` dans un composant client alors que le serveur suffit, cache implicite non voulu.
- **Hydratation** : rendu dépendant de `window`, de la date ou de `Math.random` ; `useEffect` pour une donnée disponible côté serveur.
- **Images et SEO** : `<img>` brut sans dimensions, métadonnées absentes, pas de page `not-found` ni `error`.

---

## security

- **Mises à jour** : `npm audit` ou l'équivalent du gestionnaire ; suivre les avis de sécurité officiels de Next.js et les alertes Dependabot, en particulier sur le `middleware` et les Server Actions.
- **Autorisation** : ne pas compter sur le seul `middleware` pour protéger une donnée ; revérifier la session dans la route, l'action ou le composant serveur.
- **En-têtes** : CSP, `X-Frame-Options`, `Referrer-Policy` via `next.config` ou le middleware ; cookies `HttpOnly`, `Secure`, `SameSite`.
- **Entrées** : valider (Zod) paramètres de route, de requête et corps ; pas de `dangerouslySetInnerHTML` avec un contenu non assaini ; attention à la SSRF sur les URL passées à `fetch` côté serveur.

---

## test

- **Outils** : Vitest ou Jest avec Testing Library pour les composants ; Playwright pour les parcours. Les Server Components asynchrones se testent mieux en bout en bout.
- **Règles** : tester le comportement visible, simuler le réseau (MSW) plutôt que les modules internes ; `next build` sert aussi de contrôle des types et des routes.

---

## deploy

- **Sortie** : `output: 'standalone'` pour une image Docker minimale ; `next build`, puis `node server.js` (ou `next start`).
- **Image** : multi-étapes, utilisateur non root, variables `NEXT_PUBLIC_*` fournies **au build**, autres secrets à l'exécution ; cache d'images (`.next/cache`) persistant si possible.
- **Plateforme** : sur Vercel, les skills Vercel s'appliquent (`vercel:nextjs`, `vercel:deploy`).
