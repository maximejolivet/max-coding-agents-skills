---
name: nuxt
description: Guide le développement Nuxt (3 et 4) - pages et routage, composants, composables, chargement de données (useFetch, useAsyncData), état, routes serveur Nitro, rendu SSR/statique, configuration et tests. Lit d'abord le code existant du projet, propose l'approche, implémente, puis renvoie vers /max:review. À utiliser quand l'utilisateur implémente ou modifie du code Nuxt, ajoute une page, un composant, un composable, une route d'API serveur ou un module, ou demande de l'aide sur Nuxt, ou invoque /max:nuxt.
---

# Développer avec Nuxt

Entrée du développement Nuxt. Ce skill décrit le **déroulé du travail** ; la connaissance de Nuxt est centralisée dans `stacks/nuxt/`, afin que `/max:review`, `/max:pr-review`, `/max:security`, `/max:test`, `/max:docker` et `/max:kubernetes` partagent la même source.

## Charger la connaissance Nuxt

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), puis lire `${CLAUDE_SKILL_DIR}/../../stacks/nuxt/INDEX.md` pour la nature **dev** : elle inclut `## core` (détection, structure, auto-imports, Nitro, modes de rendu, versions) et `## dev` (composants, chargement de données, état, routage, API serveur, code propre au client, SEO, modules). Nuxt repose sur Vue : lire aussi `stacks/vue/INDEX.md` s'il existe (le parent). Garder cette discipline tout au long du travail.

**`dev` est un socle, pas toujours suffisant.** Quand la demande dépasse le développement courant, charger aussi la nature adaptée, pour construire avec le bon réflexe dès le départ :

- Demande liée à la **sécurité, aux accès ou à l'exposition de données** (authentification, secrets, routes d'API, données privées) : lire aussi `## security`.
- Intervention sur du **code existant à ne pas casser**, ou où hydratation, performances et standards sont l'enjeu : lire aussi `## review`.
- **Tests** : `/max:test` charge `## test`. **Conteneurisation ou déploiement** : `/max:docker` ou `/max:kubernetes` chargent `## deploy`.

Ne charger que le pertinent, sans tout lire par réflexe. Si le projet n'est pas Nuxt (la détection ne remonte pas `nuxt`), le dire et orienter vers le skill de la bonne techno au lieu d'appliquer des règles Nuxt à autre chose.

## Partir de la demande

Si l'utilisateur fournit une issue ou un brief, le lire d'abord et en tirer : le comportement attendu, les contraintes et risques, les fichiers ou composants à examiner en premier. Sans cela, demander l'intention en une ligne avant de coder. Ces contraintes déterminent aussi les natures supplémentaires à charger.

## Identifier la version et le contexte

Avant de choisir une API, savoir sur quoi on travaille :

```bash
grep -E '"(nuxt|vue|nitropack|typescript)"' package.json
ls nuxt.config.* app pages components composables server 2>/dev/null
```

- La **version de Nuxt** (voir « Versions » dans la ressource) dicte la structure (`app/` en Nuxt 4, racine en Nuxt 3) et certains comportements de chargement de données. Aucun code qui suppose une API ou une structure absente de la version du projet.
- Le **gestionnaire de paquets** (`pnpm`, `npm`, `yarn`, `bun`, d'après le lockfile) et le **runner** du projet : passer par eux, jamais par un autre gestionnaire que celui du lockfile.
- Le **mode de rendu** du projet (`ssr`, `routeRules`, `nuxt generate`) : il conditionne ce qui est permis côté serveur et côté client.

## Lire l'existant avant d'écrire

Pour ne rien réinventer ni dupliquer, **lire le code en place** (sauf si c'est déjà fait dans la session) :

- Lire `nuxt.config.ts` (modules, `runtimeConfig`, `routeRules`, `nitro`), `package.json` (scripts, dépendances) et parcourir `pages/`, `components/`, `composables/`, `server/`, `middleware/`, `layouts/`, `plugins/` (sous `app/` en Nuxt 4).
- Repérer les **composants, composables, utilitaires et types** à réutiliser, ainsi que les **idiomes locaux** (organisation par domaine ou par type, nommage, bibliothèque de composants, état Pinia ou `useState`, appels d'API), pour que le nouveau code ressemble au projet.
- Noter ce que le changement va toucher ou remplacer, et signaler les conflits **avant** de coder.

**Sur un gros projet** (plusieurs dizaines de fichiers concernés, ou demande encore floue), confier cette exploration à l'agent **`max:codebase-surveyor`** via l'outil Agent plutôt que d'encombrer le contexte : lui passer la racine du projet, la tâche en quelques lignes, la stack détectée, le chemin de `stacks/<stack>/INDEX.md` et les dossiers à voir en premier. Il rend un résumé de 40 lignes maximum ; relire soi-même les fichiers qu'on va vraiment modifier. Sur un petit projet, lire directement.

Résumer en quelques lignes ce qui a été trouvé (ou confirmer qu'il n'y a rien à réutiliser) avant de proposer une approche.

## Démarche

1. **Classer** le problème : présentation (composant, page), logique réutilisable (composable), données (chargement, API serveur) ou configuration (module, rendu).
2. **Proposer** l'approche la plus simple qui respecte `## dev` : où va le code, quelle API de données, quel état, quel mode de rendu pour cette route.
3. **Implémenter** par petits pas : le composable ou la route serveur, le composant, la page, puis le branchement.
4. **Signaler** les cas limites : états de chargement et d'erreur, données vides, route inexistante, utilisateur non connecté.
5. **Signaler** hydratation et performances : code dépendant du navigateur, requêtes en cascade, composants lourds à charger paresseusement, images.
6. **Signaler** les tests à ajouter ou mettre à jour (voir `/max:test`) et les écrire quand c'est raisonnable.
7. **Vérifier avant de conclure** : exécuter ce qui peut l'être via le gestionnaire du projet et rapporter ce qui a réellement tourné.

```bash
<gestionnaire> run lint            # ou le script équivalent du projet
npx nuxt typecheck                 # types (nuxt ou nuxi selon la version)
<gestionnaire> run test            # la partie liée au changement
<gestionnaire> run build           # quand le changement touche la configuration, les modules ou le rendu
```

Un outil ou script absent se note « (indispo) » : rien n'est installé pour l'occasion, et aucun contrôle n'est déclaré passé s'il n'a pas tourné.

8. **Faire relire** : le changement terminé, lancer **`/max:review`** pour un verdict classé par gravité avant d'ouvrir la pull request, puis `/max:pull-request`. Le travail n'est pas fini tant que cette revue n'a pas tourné.

## Garde-fous

- Aucun secret dans `runtimeConfig.public`, `app.config.ts`, un composant ou un fichier versionné ; les secrets vont dans `runtimeConfig` (privé), alimenté par les variables `NUXT_*`.
- Aucun module ni dépendance ajouté sans l'avoir demandé et justifié ; vérifier qu'il est maintenu et compatible avec la version de Nuxt du projet.
- Ne pas changer le mode de rendu global (`ssr`, preset Nitro, `nuxt generate`) pour un cas isolé : utiliser `routeRules` sur la route concernée.
- Jamais d'état global au niveau d'un module (il fuit d'une requête serveur à l'autre) : `useState` ou Pinia.
- Ne pas désactiver une protection (validation côté serveur, contrôle d'accès, assainissement du HTML) pour « faire passer » un cas.
- Jamais d'appel à une API de production depuis les tests ou le développement.
- Rester dans le périmètre demandé : signaler un problème voisin plutôt que de le corriger en passant.
