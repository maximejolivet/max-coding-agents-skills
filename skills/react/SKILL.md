---
name: react
description: Guide le développement React (18 et 19) - composants, hooks, état, effets, données serveur, formulaires, routage, accessibilité, performances et tests. Lit d'abord le code existant du projet, propose l'approche, implémente, puis renvoie vers /max:review. À utiliser quand l'utilisateur implémente ou modifie du code React, ajoute un composant, un hook, une page ou un formulaire, ou demande de l'aide sur React, ou invoque /max:react.
---

# Développer avec React

Entrée du développement React. Ce skill décrit le **déroulé du travail** ; la connaissance de React est centralisée dans `stacks/react/`, afin que `/max:review`, `/max:pr-review`, `/max:security`, `/max:test`, `/max:docker` et `/max:kubernetes` partagent la même source.

## Charger la connaissance React

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), puis lire `${CLAUDE_SKILL_DIR}/../../stacks/react/INDEX.md` pour la nature **dev** : elle inclut `## core` (détection, composants purs, règles des hooks, immutabilité, versions) et `## dev` (composition, état, effets, données serveur, formulaires, routage, performances, accessibilité). Si le projet est Next.js, lire d'abord `stacks/nextjs/INDEX.md` s'il existe, puis celle-ci (le framework dérivé complète son parent). Garder cette discipline tout au long du travail.

**`dev` est un socle, pas toujours suffisant.** Quand la demande dépasse le développement courant, charger aussi la nature adaptée, pour construire avec le bon réflexe dès le départ :

- Demande liée à la **sécurité, aux accès ou à l'exposition de données** (authentification, jetons, HTML venant d'un utilisateur, variables d'environnement) : lire aussi `## security`.
- Intervention sur du **code existant à ne pas casser**, ou où effets, performances et accessibilité sont l'enjeu : lire aussi `## review`.
- **Tests** : `/max:test` charge `## test`. **Conteneurisation ou déploiement** : `/max:docker` ou `/max:kubernetes` chargent `## deploy`.

Ne charger que le pertinent, sans tout lire par réflexe. Si le projet n'utilise pas React (la détection ne remonte pas `react`), le dire et orienter vers le skill de la bonne techno.

## Partir de la demande

Si l'utilisateur fournit une issue ou un brief, le lire d'abord et en tirer : le comportement attendu, les contraintes et risques, les fichiers ou composants à examiner en premier. Sans cela, demander l'intention en une ligne avant de coder. Ces contraintes déterminent aussi les natures supplémentaires à charger.

## Identifier la version et le contexte

Avant de choisir une API, savoir sur quoi on travaille :

```bash
grep -E '"(react|react-dom|typescript|vite|next|react-router|@tanstack/react-query)"' package.json
ls vite.config.* next.config.* tsconfig.json src app 2>/dev/null
```

- La **version de React** (voir « Versions » dans la ressource) dicte les API disponibles : les Actions et `use` n'existent qu'en React 19. Aucun code qui suppose une API absente de la version du projet.
- L'**outil de build** (Vite, Next.js, Webpack…), le **gestionnaire de paquets** d'après le lockfile (jamais un autre) et le **runner** du projet.
- Les **bibliothèques déjà retenues** pour le routage, les données serveur, les formulaires, l'état et les styles : s'y tenir plutôt qu'en ajouter une.

## Lire l'existant avant d'écrire

Pour ne rien réinventer ni dupliquer, **lire le code en place** (sauf si c'est déjà fait dans la session) :

- Lire `package.json` (scripts, dépendances), la configuration du build et de TypeScript, et parcourir `src/` (ou `app/`) : composants, hooks, pages, API, utilitaires, types.
- Repérer les **composants, hooks, utilitaires et types** à réutiliser, ainsi que les **idiomes locaux** (organisation par fonctionnalité ou par type, nommage, appels d'API, gestion d'état, tests), pour que le nouveau code ressemble au projet.
- Noter ce que le changement va toucher ou remplacer, et signaler les conflits **avant** de coder.

**Sur un gros projet** (plusieurs dizaines de fichiers concernés, ou demande encore floue), confier cette exploration à l'agent **`max:codebase-surveyor`** via l'outil Agent plutôt que d'encombrer le contexte : lui passer la racine du projet, la tâche en quelques lignes, la stack détectée, le chemin de `stacks/<stack>/INDEX.md` et les dossiers à voir en premier. Il rend un résumé de 40 lignes maximum ; relire soi-même les fichiers qu'on va vraiment modifier. Sur un petit projet, lire directement.

Résumer en quelques lignes ce qui a été trouvé (ou confirmer qu'il n'y a rien à réutiliser) avant de proposer une approche.

## Démarche

1. **Classer** le problème : présentation (composant), logique réutilisable (hook), données (requête, cache) ou structure (routage, organisation).
2. **Proposer** l'approche la plus simple qui respecte `## dev` : où vit l'état, ce qui se calcule au lieu de se stocker, quel mécanisme de données.
3. **Implémenter** par petits pas : le hook ou la fonction pure, le composant, puis le branchement dans la page.
4. **Signaler** les cas limites : états de chargement, d'erreur et vide, liste vide ou très longue, utilisateur non connecté, double clic.
5. **Signaler** performance et accessibilité : rendus inutiles *mesurés*, chargement différé d'une route lourde, éléments sémantiques, clavier, focus.
6. **Signaler** les tests à ajouter ou mettre à jour (voir `/max:test`) et les écrire quand c'est raisonnable.
7. **Vérifier avant de conclure** : exécuter ce qui peut l'être via le gestionnaire du projet et rapporter ce qui a réellement tourné.

```bash
<gestionnaire> run lint            # ou le script équivalent du projet, avec react-hooks
npx tsc --noEmit                   # types, si le projet utilise TypeScript
<gestionnaire> run test            # la partie liée au changement
<gestionnaire> run build           # quand le changement touche la configuration ou les dépendances
```

Un outil ou script absent se note « (indispo) » : rien n'est installé pour l'occasion, et aucun contrôle n'est déclaré passé s'il n'a pas tourné.

8. **Faire relire** : le changement terminé, lancer **`/max:review`** pour un verdict classé par gravité avant d'ouvrir la pull request, puis `/max:pull-request`. Le travail n'est pas fini tant que cette revue n'a pas tourné.

## Garde-fous

- Jamais de mutation de l'état ni des props ; jamais de hook dans une condition ou une boucle ; jamais de `react-hooks/exhaustive-deps` désactivé pour « faire taire » un avertissement : traiter la cause.
- `useEffect` sert uniquement à se synchroniser avec un système extérieur à React ; l'état dérivé se calcule pendant le rendu.
- Pas de `memo`, `useMemo` ni `useCallback` sans mesure ou sans besoin de stabilité de référence.
- Aucun secret dans une variable d'environnement lue par le client (`VITE_*`, `REACT_APP_*`, `NEXT_PUBLIC_*`) ni dans le code : tout ce qui part au navigateur est public.
- Pas de `dangerouslySetInnerHTML` avec une donnée non assainie.
- Aucune bibliothèque ajoutée sans l'avoir demandée et justifiée ; vérifier qu'elle est maintenue et compatible avec la version de React du projet.
- Jamais d'appel à une API de production depuis les tests ou le développement.
- Rester dans le périmètre demandé : signaler un problème voisin plutôt que de le corriger en passant.
