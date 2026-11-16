# Next.js

```bash
grep -E '"(next|react|typescript)"' package.json
ls next.config.* app pages middleware.* proxy.* 2>/dev/null
```

Lire `## core`, puis la section de la nature (tableau : `stacks/DETECT.md`), puis `stacks/react/INDEX.md` (parent).

---

## core

- Signaux : dépendance `next`, `next.config.*`.
- Routeur : `app/` (App Router) ou `pages/` (Pages Router). Suivre celui du projet, sans mélanger.
- App Router : un composant est serveur tant qu'il n'a pas `'use client'`. Le placer le plus bas possible dans l'arbre.
- Le cache (`fetch`, `revalidate`, `use cache`) et le fichier `middleware` ou `proxy` changent selon la version : lire la documentation de la version du lockfile, ne rien supposer.
- Commandes : scripts de `package.json`, avec le gestionnaire du lockfile.

---

## dev

- Données dans les Server Components `async`, en `Promise.all` quand les requêtes sont indépendantes ; `Suspense` et `loading.tsx` pour le streaming.
- Une Server Action (`'use server'`) est un point d'entrée public : valider et autoriser côté serveur.
- Seules des données sérialisables passent à un composant client. Aucun code serveur ni secret importé côté client.
- Seules les variables `NEXT_PUBLIC_` partent au navigateur.
- `next/image` avec dimensions, `next/font`, `generateMetadata`, `next/link`.

Vérifier : `next lint` ou ESLint, `tsc --noEmit`, `next build`.

---

## review

- `'use client'` trop haut : une page entière en client pour un bouton.
- Secret préfixé `NEXT_PUBLIC_`, ou variable non préfixée lue côté client.
- Server Action sans validation ni contrôle d'accès.
- Requêtes séquentielles, `fetch` côté client alors que le serveur suffit, cache implicite non voulu.
- Rendu qui dépend de `window`, de la date ou de `Math.random` ; `useEffect` pour une donnée disponible côté serveur.

Aussi : `<img>` sans dimensions, métadonnées absentes, pas de `not-found` ni de `error`.

---

## security

- Audit du lockfile ; avis officiels de Next.js, surtout sur le `middleware` et les Server Actions.
- Le `middleware` seul ne protège pas une donnée : revérifier la session dans la route, l'action ou le composant serveur.
- Entrées validées (Zod) : paramètres de route, de requête, corps.
- URL fournie à un `fetch` serveur : valider l'hôte (SSRF).
- En-têtes par `next.config` ou le middleware : CSP, `X-Frame-Options`, `Referrer-Policy` ; cookies `HttpOnly`, `Secure`, `SameSite`.

---

## test

- Vitest ou Jest avec Testing Library ; Playwright pour les parcours.
- Les Server Components asynchrones se testent en bout en bout.
- Réseau simulé par MSW. `next build` vérifie aussi les types et les routes.

---

## deploy

- `output: 'standalone'`, puis `node server.js`.
- Les variables `NEXT_PUBLIC_*` sont fixées au build, les autres secrets à l'exécution.
- `.next/cache` persistant si possible.
- Sur Vercel : les skills `vercel:nextjs` et `vercel:deploy` s'appliquent.
