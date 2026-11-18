---
name: test
description: "Écrit, lance et diagnostique des tests automatisés - unitaires, d'intégration, fonctionnels, de bout en bout - avec le test de non-régression vu rouge avant tout correctif, et un mode TDD ou BDD sur demande. À utiliser quand Maxime demande d'ajouter, d'écrire, de corriger ou de lancer des tests, de comprendre un test qui échoue ou qui est instable, de développer en TDD ou en BDD, ou invoque /max:test."
---

# Tests

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session.
2. Détecter la stack : suivre `<max>/stacks/DETECT.md`, nature **test**. Elle donne l'outil de test et le runner.
3. Ouvrir deux ou trois tests proches de celui à écrire et reprendre leurs conventions : emplacement, nommage, assertions, fabrication des données.
4. Lancer la suite, ou la partie concernée, pour connaître l'état de départ. Un test déjà rouge n'est pas dû au changement en cours.

## Étapes

Choisir le déroulé selon la demande.

### Écrire un test

1. Choisir le niveau le plus bas qui prouve le comportement : unitaire, sinon intégration, sinon fonctionnel. Le navigateur reste réservé à quelques parcours critiques.
2. Écrire un test par comportement, nommé d'après le comportement et le cas.
3. Le rendre déterministe : horloge figée, aléatoire injecté, réseau remplacé, aucun `sleep`.
4. L'isoler : il prépare ses données, la base repart de zéro entre deux tests.
5. Le lancer seul (`--filter`, `-k`, `-t`), puis la suite concernée.

### Corriger un bug

1. Écrire le test qui reproduit le bug.
2. Le lancer et le voir rouge, avec un message qui correspond au symptôme.
3. Corriger le code.
4. Voir le test vert, puis le reste de la suite.

### TDD (sur demande)

1. Rouge : un seul test pour le prochain comportement, vu échouer pour la bonne raison.
2. Vert : le code le plus simple qui le fait passer, suite entière verte.
3. Refactor : nettoyer avec la suite verte, puis la relancer.
4. Annoncer à chaque tour l'étape et le résultat réel.

### BDD (sur demande)

1. Écrire les scénarios `Given / When / Then` avec Maxime, dans le vocabulaire du domaine, et les faire valider avant de coder.
2. Utiliser l'outil BDD du projet (Behat, Cucumber, behave, pytest-bdd). Sans outil : des tests nommés par le comportement.
3. Implémenter les étapes, puis le code, en rouge, vert, refactor.

### Diagnostiquer un échec

1. Lire le message et la trace en entier.
2. Classer : bug du code, test mal écrit, données manquantes, environnement.
3. Agir selon le cas :

   | Symptôme | Piste |
   | :-- | :-- |
   | Échoue toujours | Le reproduire seul, isoler l'assertion, décider si le code est faux ou si la spécification a changé |
   | Échoue parfois | Heure, aléatoire, ordre des tests, données partagées, `sleep` à la place d'une condition, service pas prêt |
   | Passe en local, échoue en CI | Versions, variables d'environnement, fuseau horaire, services, ordre d'exécution |

4. Corriger la cause. Relancer la CI jusqu'au vert n'est pas une correction.

Dans tous les cas : rapporter les vrais nombres (réussis, échoués, ignorés) et la commande exacte pour rejouer.

## Points d'arrêt

- Le test de non-régression n'a jamais été vu rouge : il ne prouve rien. Si le bug ne se reproduit pas en test, le dire et donner des étapes de recette manuelle.
- Aucune ressource ni section `test` pour la stack : partir des scripts du projet et le dire.
- Le projet n'a aucune infrastructure de tests : la proposer, ne pas l'installer.
- Un snapshot ou une valeur attendue change : relire chaque différence avant de la valider.
- Rendre le code testable demande de le modifier : le dire, garder le changement minimal et séparé.

## Ce qu'il ne fait pas

- Supprimer, ignorer (`skip`) ou affaiblir un test, ni baisser un seuil de couverture, sans accord.
- Simuler le code testé : les doublures s'arrêtent aux frontières (réseau, horloge, service externe).
- Lancer des tests contre une base ou un service de production.
- Lancer des tests de mutation par défaut.
- Écrire le workflow de CI des tests : `/max:ci`.
