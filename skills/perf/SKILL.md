---
name: perf
description: "Améliore les performances en mesurant - métrique et budget, profilage du vrai goulot (requêtes N+1, rendu, bundle, entrées-sorties), un changement à la fois, gain prouvé par une mesure avant et après. À utiliser quand Maxime signale une lenteur, veut optimiser une page, une requête, un build ou un bundle, améliorer un score Lighthouse ou les Core Web Vitals, ou invoque /max:perf."
argument-hint: "[page, requête ou commande lente]"
---

# Optimiser en mesurant

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session.
2. Détecter la stack : suivre `<max>/stacks/DETECT.md`, nature **dev**.
3. Pour une page web : lire `<max>/references/core-web-vitals-checklist.md`.

## Étapes

1. Fixer la métrique (temps de réponse p95, LCP, poids du bundle, durée du build, mémoire), le chemin concerné et le budget. Sans budget : en proposer un et le faire valider.
2. Mesurer l'état de départ : mêmes données, même machine, plusieurs passes, médiane retenue. Noter l'environnement.
3. Chercher le goulot, du plus fréquent au plus rare :

   | Famille | À chercher |
   | :-- | :-- |
   | Requêtes | N+1, index absent, `SELECT *`, pas de pagination, appel dans une boucle |
   | Réseau et entrées-sorties | appels séquentiels, cache absent, charge utile trop lourde |
   | Rendu | rendus inutiles, image mal dimensionnée, JavaScript bloquant, bundle, polices |
   | CPU et mémoire | algorithme en O(n²), copies superflues, fuite |

4. Appliquer un seul changement, sur le goulot prouvé.
5. Remesurer dans les mêmes conditions. Garder si le gain dépasse le bruit, sinon annuler.
6. Lancer la suite de tests : le résultat ne doit pas avoir changé.
7. Rendre compte : métrique, mesure de départ, preuve du goulot (profil, plan d'exécution), chaque changement avec son avant et son après, résultat face au budget.

Outils selon le cas : Lighthouse et DevTools, profileur de la stack, `EXPLAIN`, journal des requêtes lentes, analyseur de bundle, `time`. Sur un gros projet, l'agent `max:codebase-surveyor` cartographie le chemin chaud.

## Points d'arrêt

- Aucune mesure reproductible n'est possible : s'arrêter, dire ce qui manque.
- Le goulot n'est pas prouvé : ne rien changer.
- Un outil de profilage manque : le proposer, ne pas l'installer.
- La mesure devrait se faire en production : attendre l'accord.

## Ce qu'il ne fait pas

- Ajouter un cache, une mémoïsation ou une dénormalisation pour un gain non mesuré.
- Affaiblir une validation, une protection ou un test pour gagner du temps.
- Empiler plusieurs changements avant de remesurer.
