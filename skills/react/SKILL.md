---
name: react
description: Guide le développement React (18 et 19) - composants, hooks, état, effets, données serveur, formulaires, routage, accessibilité, performances et tests. Lit d'abord le code existant du projet, propose l'approche, implémente, puis renvoie vers /max:review. À utiliser quand l'utilisateur implémente ou modifie du code React, ajoute un composant, un hook, une page ou un formulaire, ou demande de l'aide sur React, ou invoque /max:react.
---

# Développement React

Point d'entrée du développement React. Ce skill porte le **workflow** ; le savoir React lui-même vit dans la ressource partagée `stacks/react/`, pour que `/max:review`, `/max:pr-review`, `/max:security`, `/max:test`, `/max:docker` et `/max:kubernetes` puisent à la même source.

## Charger le savoir React

Suivre la procédure commune `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), puis charger `${CLAUDE_SKILL_DIR}/../../stacks/react/INDEX.md` pour la nature **dev** : elle tire `## core` (détection, composants purs, règles des hooks, immutabilité, versions) et `## dev` (composition, état, effets, données serveur, formulaires, routage, performances, accessibilité). Si le projet est un projet Next.js, lire d'abord `stacks/nextjs/INDEX.md` s'il existe, puis celle-ci (le framework dérivé complète son parent). Appliquer cette discipline pendant tout le travail ci-dessous.

**`dev` est la base, pas toujours assez.** Quand la demande dépasse du développement courant, charger aussi la nature concernée pour construire avec le bon regard dès le départ :

- Demande touchant la **sécurité, les accès ou l'exposition de données** (authentification, jetons, HTML venant d'un utilisateur, variables d'environnement) → lire aussi `## security`.
- Travail sur du **code existant à ne pas casser**, ou où les effets, les performances et l'accessibilité sont le cœur du sujet → lire aussi `## review`.
- Demande de **tests** → `/max:test` charge `## test`. De **conteneurisation ou déploiement** → `/max:docker` ou `/max:kubernetes` chargent `## deploy`.

Charger ce qui est pertinent, ignorer le reste - ne pas tout lire par réflexe. Si le projet n'utilise pas React (la détection ne remonte pas `react`), le dire et orienter vers le skill de la bonne techno.

## Partir de la demande

Si l'utilisateur donne une issue ou un brief, le lire d'abord et en extraire : le comportement attendu, les contraintes et risques, et les fichiers ou composants à examiner en premier. S'il n'y en a pas, demander l'intention en une ligne avant de coder. Ces contraintes décident aussi quelles natures supplémentaires charger.

## Repérer la version et le contexte

Avant de choisir une API, savoir sur quoi on travaille :

```bash
grep -E '"(react|react-dom|typescript|vite|next|react-router|@tanstack/react-query)"' package.json
ls vite.config.* next.config.* tsconfig.json src app 2>/dev/null
```

- La **version de React** (voir « Versions » dans la ressource) décide des API disponibles : les Actions et `use` sont propres à React 19. Ne pas écrire de code qui suppose une API absente de la version du projet.
- L'**outil de build** (Vite, Next.js, Webpack…), le **gestionnaire de paquets** d'après le lockfile (jamais un autre) et le **runner** du projet.
- Les **bibliothèques déjà choisies** pour le routage, les données serveur, les formulaires, l'état et les styles : s'y tenir plutôt qu'en ajouter une de plus.

## Explorer le code existant d'abord

Avant d'écrire du code, **lire l'existant** pour ne pas réinventer ni dupliquer. Sauf si cela a déjà été fait dans la session :

- Lire `package.json` (scripts, dépendances), la configuration de l'outil de build et de TypeScript, et lister `src/` (ou `app/`) : composants, hooks, pages, API, utilitaires, types.
- Repérer les **composants, hooks, utilitaires et types** à réutiliser plutôt qu'à refaire, et les **idiomes locaux** (organisation par fonctionnalité ou par type, nommage, façon d'appeler l'API, gestion d'état, tests) pour que le nouveau code s'accorde au style du projet.
- Relever ce que le changement va toucher ou remplacer, et signaler les conflits **avant** de coder.

**Sur un gros projet** (plusieurs dizaines de fichiers pertinents, ou une demande encore floue), déléguer cette exploration à l'agent **`max:codebase-surveyor`** avec l'outil Agent plutôt que de remplir le contexte : lui donner la racine du projet, la tâche en quelques lignes, la stack détectée, le chemin de la ressource `stacks/<stack>/INDEX.md` et les dossiers à regarder en premier. Il rend un résumé de 40 lignes au plus ; relire lui-même les fichiers qu'on va réellement modifier. Sur un petit projet, lire directement.

Résumer en quelques lignes ce qui a été trouvé (ou confirmer qu'il n'y a rien de réutilisable) avant de proposer une approche.

## Démarche

1. **Classer** le problème : présentation (composant), logique réutilisable (hook), données (requête, cache), ou structure (routage, organisation).
2. **Proposer** l'approche la plus simple qui respecte la section `## dev` : où vit l'état, ce qui est calculé plutôt que stocké, quel mécanisme de données.
3. **Puis** implémenter, par petits pas : le hook ou la fonction pure, le composant, puis le branchement dans la page.
4. **Mentionner** les cas limites : états de chargement, d'erreur et vide, liste vide ou très longue, utilisateur non connecté, double clic.
5. **Mentionner** les points de performance et d'accessibilité : rendus inutiles *mesurés*, chargement paresseux d'une route lourde, éléments sémantiques, clavier, focus.
6. **Mentionner** les tests à ajouter ou mettre à jour (voir `/max:test`), et les écrire quand c'est raisonnable.
7. **Vérifier avant de conclure** : lancer ce qui peut l'être via le gestionnaire du projet et rapporter ce qui a réellement tourné.

```bash
<gestionnaire> run lint            # ou le script équivalent du projet, avec react-hooks
npx tsc --noEmit                   # types, si le projet utilise TypeScript
<gestionnaire> run test            # la partie liée au changement
<gestionnaire> run build           # quand le changement touche la configuration ou les dépendances
```

Les outils ou scripts absents se notent « (indispo) » : ne rien installer pour l'occasion, et ne jamais affirmer qu'un contrôle est passé s'il n'a pas tourné.

8. **Relire avant de finir** - une fois le changement terminé, lancer **`/max:review`** pour obtenir un verdict classé par gravité avant d'ouvrir la pull request, puis `/max:pull-request`. Ne pas considérer le travail comme fini tant que cette revue n'a pas tourné.

## Garde-fous

- Ne jamais muter l'état ni les props ; ne jamais appeler un hook dans une condition ou une boucle ; ne jamais désactiver `react-hooks/exhaustive-deps` pour « faire taire » un avertissement - corriger la cause.
- N'utiliser `useEffect` que pour se synchroniser avec un système extérieur à React ; calculer l'état dérivé pendant le rendu.
- Ne pas ajouter `memo`, `useMemo` ou `useCallback` sans mesure ou sans raison de stabilité de référence.
- Ne jamais mettre de secret dans une variable d'environnement lue par le client (`VITE_*`, `REACT_APP_*`, `NEXT_PUBLIC_*`) ni dans le code : tout ce qui est livré au navigateur est public.
- Ne pas utiliser `dangerouslySetInnerHTML` avec une donnée non assainie.
- Ne pas installer de bibliothèque sans le demander et le justifier ; vérifier qu'elle est maintenue et compatible avec la version de React du projet.
- Ne jamais appeler d'API de production depuis les tests ou le développement.
- Rester dans le périmètre demandé : signaler un problème voisin plutôt que de le corriger en passant.
