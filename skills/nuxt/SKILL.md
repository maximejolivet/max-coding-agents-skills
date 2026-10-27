---
name: nuxt
description: Guide le développement Nuxt (3 et 4) - pages et routage, composants, composables, chargement de données (useFetch, useAsyncData), état, routes serveur Nitro, rendu SSR/statique, configuration et tests. Lit d'abord le code existant du projet, propose l'approche, implémente, puis renvoie vers /max:review. À utiliser quand l'utilisateur implémente ou modifie du code Nuxt, ajoute une page, un composant, un composable, une route d'API serveur ou un module, ou demande de l'aide sur Nuxt, ou invoque /max:nuxt.
---

# Développement Nuxt

Point d'entrée du développement Nuxt. Ce skill porte le **workflow** ; le savoir Nuxt lui-même vit dans la ressource partagée `stacks/nuxt/`, pour que `/max:review`, `/max:pr-review`, `/max:security`, `/max:test`, `/max:docker` et `/max:kubernetes` puisent à la même source.

## Charger le savoir Nuxt

Suivre la procédure commune `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), puis charger `${CLAUDE_SKILL_DIR}/../../stacks/nuxt/INDEX.md` pour la nature **dev** : elle tire `## core` (détection, structure, auto-imports, Nitro, modes de rendu, versions) et `## dev` (composants, chargement de données, état, routage, API serveur, code propre au client, SEO, modules). Nuxt s'appuie sur Vue : lire aussi `stacks/vue/INDEX.md` s'il existe (parent). Appliquer cette discipline pendant tout le travail ci-dessous.

**`dev` est la base, pas toujours assez.** Quand la demande dépasse du développement courant, charger aussi la nature concernée pour construire avec le bon regard dès le départ :

- Demande touchant la **sécurité, les accès ou l'exposition de données** (authentification, secrets, routes d'API, données privées) → lire aussi `## security`.
- Travail sur du **code existant à ne pas casser**, ou où l'hydratation, les performances et les standards sont le cœur du sujet → lire aussi `## review`.
- Demande de **tests** → `/max:test` charge `## test`. De **conteneurisation ou déploiement** → `/max:docker` ou `/max:kubernetes` chargent `## deploy`.

Charger ce qui est pertinent, ignorer le reste - ne pas tout lire par réflexe. Si le projet n'est pas un projet Nuxt (la détection ne remonte pas `nuxt`), le dire et orienter vers le skill de la bonne techno plutôt que d'appliquer des règles Nuxt à autre chose.

## Partir de la demande

Si l'utilisateur donne une issue ou un brief, le lire d'abord et en extraire : le comportement attendu, les contraintes et risques, et les fichiers ou composants à examiner en premier. S'il n'y en a pas, demander l'intention en une ligne avant de coder. Ces contraintes décident aussi quelles natures supplémentaires charger.

## Repérer la version et le contexte

Avant de choisir une API, savoir sur quoi on travaille :

```bash
grep -E '"(nuxt|vue|nitropack|typescript)"' package.json
ls nuxt.config.* app pages components composables server 2>/dev/null
```

- La **version de Nuxt** (voir « Versions » dans la ressource) décide de la structure (`app/` en Nuxt 4, racine en Nuxt 3) et de certains comportements de chargement de données. Ne pas écrire de code qui suppose une API ou une structure absente de la version du projet.
- Le **gestionnaire de paquets** (`pnpm`, `npm`, `yarn`, `bun`, d'après le lockfile) et le **runner** du projet : lancer les commandes à travers eux, jamais un autre gestionnaire que celui du lockfile.
- Le **mode de rendu** du projet (`ssr`, `routeRules`, `nuxt generate`) : il change ce qui est permis côté serveur et côté client.

## Explorer le code existant d'abord

Avant d'écrire du code, **lire l'existant** pour ne pas réinventer ni dupliquer. Sauf si cela a déjà été fait dans la session :

- Lire `nuxt.config.ts` (modules, `runtimeConfig`, `routeRules`, `nitro`), `package.json` (scripts, dépendances) et lister `pages/`, `components/`, `composables/`, `server/`, `middleware/`, `layouts/`, `plugins/` (sous `app/` en Nuxt 4).
- Repérer les **composants, composables, utilitaires et types** à réutiliser plutôt qu'à refaire, et les **idiomes locaux** (organisation par domaine ou par type, nommage, bibliothèque de composants, gestion d'état Pinia ou `useState`, façon d'appeler l'API) pour que le nouveau code s'accorde au style du projet.
- Relever ce que le changement va toucher ou remplacer, et signaler les conflits **avant** de coder.

**Sur un gros projet** (plusieurs dizaines de fichiers pertinents, ou une demande encore floue), déléguer cette exploration à l'agent **`max:codebase-surveyor`** avec l'outil Agent plutôt que de remplir le contexte : lui donner la racine du projet, la tâche en quelques lignes, la stack détectée, le chemin de la ressource `stacks/<stack>/INDEX.md` et les dossiers à regarder en premier. Il rend un résumé de 40 lignes au plus ; relire lui-même les fichiers qu'on va réellement modifier. Sur un petit projet, lire directement.

Résumer en quelques lignes ce qui a été trouvé (ou confirmer qu'il n'y a rien de réutilisable) avant de proposer une approche.

## Démarche

1. **Classer** le problème : présentation (composant, page), logique réutilisable (composable), données (chargement, API serveur), ou configuration (module, rendu).
2. **Proposer** l'approche la plus simple qui respecte la section `## dev` : où va le code, quelle API de données, quel état, quel mode de rendu pour cette route.
3. **Puis** implémenter, par petits pas : le composable ou la route serveur, le composant, la page, puis le branchement.
4. **Mentionner** les cas limites : états de chargement et d'erreur, données vides, route inexistante, utilisateur non connecté.
5. **Mentionner** l'hydratation et les performances : code qui dépend du navigateur, requêtes en cascade, composants lourds à charger paresseusement, images.
6. **Mentionner** les tests à ajouter ou mettre à jour (voir `/max:test`), et les écrire quand c'est raisonnable.
7. **Vérifier avant de conclure** : lancer ce qui peut l'être via le gestionnaire du projet et rapporter ce qui a réellement tourné.

```bash
<gestionnaire> run lint            # ou le script équivalent du projet
npx nuxt typecheck                 # types (nuxt ou nuxi selon la version)
<gestionnaire> run test            # la partie liée au changement
<gestionnaire> run build           # quand le changement touche la configuration, les modules ou le rendu
```

Les outils ou scripts absents se notent « (indispo) » : ne rien installer pour l'occasion, et ne jamais affirmer qu'un contrôle est passé s'il n'a pas tourné.

8. **Relire avant de finir** - une fois le changement terminé, lancer **`/max:review`** pour obtenir un verdict classé par gravité avant d'ouvrir la pull request, puis `/max:pull-request`. Ne pas considérer le travail comme fini tant que cette revue n'a pas tourné.

## Garde-fous

- Ne jamais mettre de secret dans `runtimeConfig.public`, `app.config.ts`, un composant ou un fichier versionné ; les secrets vont dans `runtimeConfig` (privé) alimenté par les variables `NUXT_*`.
- Ne pas installer de module ni de dépendance sans le demander et le justifier ; vérifier qu'il est maintenu et compatible avec la version de Nuxt du projet.
- Ne pas changer le mode de rendu global (`ssr`, preset Nitro, `nuxt generate`) pour régler un cas isolé : utiliser `routeRules` sur la route concernée.
- Ne jamais définir d'état global au niveau d'un module (il fuit entre les requêtes serveur) : `useState` ou Pinia.
- Ne pas désactiver une protection (validation côté serveur, contrôle d'accès, assainissement du HTML) pour « faire passer » un cas.
- Ne jamais appeler d'API de production depuis les tests ou le développement.
- Rester dans le périmètre demandé : signaler un problème voisin plutôt que de le corriger en passant.
