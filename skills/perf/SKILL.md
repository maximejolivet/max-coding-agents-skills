---
name: perf
description: Améliore les performances en mesurant - définit une métrique et un budget, profile pour trouver le vrai goulot (requêtes N+1, rendu, bundle, E/S), applique un seul changement à la fois et prouve le gain par une mesure avant/après. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur signale une lenteur, veut optimiser une page, une requête, un build ou un bundle, améliorer un score Lighthouse ou les Core Web Vitals, ou invoque /max:perf.
---

# Optimiser avec des mesures

Sans mesure, pas d'optimisation. On s'attaque au **vrai goulot**, pas à celui qu'on imagine, et un changement n'est conservé que si les chiffres le justifient.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis lire `stacks/<stack>/INDEX.md` pour la nature **dev** (qui inclut `core`) : outils de profilage et pièges de la techno. Sans ressource, s'appuyer sur les conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## 1. Fixer l'objectif

- Définir la **métrique** (temps de réponse p95, LCP, poids du bundle, durée du build, mémoire), le **chemin** concerné et le **budget** visé. Faute de budget, en proposer un réaliste et le faire valider.
- Pour le web, se reporter à `${CLAUDE_SKILL_DIR}/../../references/core-web-vitals-checklist.md`.

## 2. Mesurer le point de départ

- Une mesure **reproductible** : mêmes données, même machine, plusieurs passes (la médiane, pas un essai unique). Consigner l'environnement.
- Outils selon le cas : Lighthouse / DevTools (front), profileur du langage ou de la stack, `EXPLAIN` ou journal des requêtes lentes (base), analyseur de bundle, `time` pour un build.

## 3. Localiser le goulot

Des causes les plus fréquentes aux plus rares :

1. **Requêtes** : N+1, index absent, `SELECT *`, pas de pagination, appels répétés dans une boucle.
2. **Réseau et E/S** : appels séquentiels qui pourraient être parallèles, cache absent, charges utiles trop lourdes.
3. **Rendu / front** : rendus inutiles, image mal dimensionnée, JavaScript bloquant, bundle trop gros, polices.
4. **CPU / mémoire** : algorithme en O(n²), copies superflues, fuites.

Sur un gros projet, `max:codebase-surveyor` (lecture seule) peut cartographier le chemin chaud ; les modifications restent dans la session principale.

## 4. Corriger, un changement à la fois

1. Un seul changement, visant le goulot identifié.
2. **Remesurer** dans les mêmes conditions. Garder si le gain est net et dépasse le bruit de mesure, sinon annuler.
3. Vérifier que le comportement n'a pas bougé (suite de tests, `/max:test`) : optimiser ne modifie pas le résultat.
4. Chiffrer le gain : avant, après, écart.

## Forme de la réponse

1. Métrique, budget et conditions de mesure.
2. Point de départ et goulot identifié, avec la preuve (profil, plan d'exécution).
3. Changements, chacun avec sa mesure avant/après.
4. Résultat final face au budget, et ce qu'il reste à faire.

## Limites

- Pas d'optimisation prématurée ni de complexité ajoutée pour un gain non mesuré (cache, mémoïsation, dénormalisation).
- Ne jamais affaiblir une validation, une protection ou un test pour gagner du temps.
- Pas d'outil de profilage ou de dépendance installés sans accord, ni de mesure en production sans accord.
- La relecture relève de `/max:review`, les tests de `/max:test`.
