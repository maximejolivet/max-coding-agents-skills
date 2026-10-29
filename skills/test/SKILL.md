---
name: test
description: Écrit, exécute et diagnostique des tests automatisés - unitaires, d'intégration, fonctionnels et de bout en bout - avec un test de non-régression d'abord pour un bug, un mode TDD (rouge, vert, refactor) ou BDD (scénarios Given/When/Then) sur demande, des tests déterministes et isolés, et l'analyse des échecs ou des tests instables. Indépendant de la stack - charge la section test de stacks/<stack>/INDEX.md quand elle existe. À utiliser quand l'utilisateur demande d'ajouter, d'écrire, de corriger ou de lancer des tests, d'augmenter la couverture, de comprendre un test qui échoue ou qui est instable, ou invoque /max:test. Aussi quand il demande de développer en TDD ou en BDD.
---

# Tests

Écrire des tests qui protègent vraiment le comportement, les lancer pour de bon, et comprendre pourquoi ils échouent. Un test utile est **déterministe**, **isolé**, **lisible** et **échoue pour la bonne raison**. L'objectif n'est pas un chiffre de couverture, c'est de pouvoir modifier le code sans crainte.

## Détecter la stack et l'outillage

Ce skill reste indépendant de la stack ; les outils et conventions viennent d'une ressource chargée à la demande. Suivre la procédure commune `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` :

1. Lancer `stacks/detect.sh` : il donne les frameworks, l'**outil de test** (PHPUnit, Pest, Jest, Vitest, Playwright, pytest, `go test`, RSpec…), le gestionnaire de paquets et le **runner**. Annoncer la stack en une ligne.
2. Charger `stacks/<stack>/INDEX.md` pour la nature **test** (elle tire `core` + `test`) : outils, types de tests disponibles, base de données de test, fixtures. Pour un framework dérivé, charger la ressource la plus spécifique puis celle de son parent (Nuxt puis Vue, Next.js puis React).
3. **Dégradation propre** - sans ressource ou sans section `test`, utiliser d'abord ce que le projet déclare (scripts de `composer.json` / `package.json`, cibles du `Makefile`, fichiers de configuration), puis les valeurs par défaut et indices de `DETECT.md`, et **le dire** (« pas de resource test pour la stack `<x>` - principes génériques uniquement »). Ne jamais `Read` une ressource inexistante.
4. Lancer les tests à travers le **runner** du projet (`make` → `docker compose`).

## Lire l'existant avant d'écrire

- Où vivent les tests, comment ils sont nommés et organisés (miroir de `src/`, par fonctionnalité…), quelles classes ou helpers de base existent, comment les données de test sont fabriquées (fixtures, factories, builders).
- Ouvrir deux ou trois tests proches de ce que l'on va écrire et **copier leurs conventions** (style d'assertion, nommage, structure) plutôt qu'importer les siennes.
- Lancer d'abord la suite (ou la partie concernée) pour connaître l'état de départ : des tests déjà rouges ne sont pas à mettre sur le dos du changement en cours.

## Que tester, à quel niveau

Choisir le niveau le plus bas qui prouve le comportement - il est plus rapide et plus précis :

- **Unitaire** - une classe ou une fonction isolée, logique pure, cas limites. La majorité des tests.
- **Intégration** - plusieurs composants réels ensemble (service + base de données, dépôt, file de messages). Pour ce qu'un test unitaire ne peut pas prouver.
- **Fonctionnel / API** - une requête de bout en bout contre l'application (route, contrôleur, réponse, droits).
- **Bout en bout (navigateur)** - quelques parcours critiques seulement ; lents et fragiles, à garder rares.

Ce qui mérite un test en priorité : la logique métier, les cas limites et les erreurs (valeurs vides, bornes, entrées invalides), les contrôles d'accès, les régressions déjà vues. Ce qui n'en mérite pas : le code du framework, les getters et setters triviaux, les détails d'implémentation.

## Écrire un bon test

- **Structure Arrange / Act / Assert**, une idée par test, un nom qui dit le comportement et le cas (`doit_refuser_une_commande_vide`) plutôt que la méthode appelée.
- **Déterministe** - jamais de dépendance à l'heure réelle, au hasard, à l'ordre d'exécution, au réseau ou à un `sleep`. Figer l'horloge, injecter le générateur aléatoire, remplacer les appels externes.
- **Isolé** - chaque test prépare ses données et ne compte pas sur celles d'un autre ; la base est remise à zéro entre les tests (transaction annulée, base recréée).
- **Doublures avec modération** - ne simuler (`mock`) que les frontières (réseau, e-mail, horloge, service externe), pas le code que l'on est en train de tester. Un test qui ne vérifie que des appels simulés ne prouve rien.
- **Assertions précises** - vérifier le résultat observable, pas l'état interne ; éviter les assertions trop larges (`assertTrue($x !== null)`) qui passent même quand c'est faux.
- **Lisibilité** - un test se comprend sans ouvrir trois autres fichiers ; une petite duplication vaut mieux qu'un helper obscur.
- **Données** - factories ou builders avec des valeurs par défaut valides, en ne précisant que ce qui compte pour le test.

## Corriger un bug : le test d'abord

1. Écrire un test qui **reproduit** le bug et le lancer : il doit **échouer**, et pour la bonne raison (le message d'échec correspond au symptôme).
2. Corriger le code.
3. Relancer : le test passe, et le reste de la suite aussi.

Un test qui n'a jamais été vu rouge n'a pas prouvé qu'il détecte le bug. Le dire quand ce n'est pas possible (bug non reproductible en test) et donner des étapes de recette manuelle à la place.

## TDD et BDD (sur demande)

À n'appliquer que si l'utilisateur le demande ou si le projet le pratique déjà (tests écrits avant le code, fichiers `.feature`).

**TDD - boucle rouge, vert, refactor**, un petit comportement à la fois :

1. **Rouge** - écrire **un** test qui décrit le prochain comportement, le lancer, le voir échouer **pour la bonne raison**.
2. **Vert** - écrire le code le plus simple qui le fait passer, le lancer, voir toute la suite verte.
3. **Refactor** - nettoyer le code et le test avec la suite verte, la relancer ensuite.
4. Répéter. Annoncer à chaque tour l'étape en cours et le résultat réel de l'exécution ; ne pas écrire plusieurs tests rouges d'un coup.

**BDD - le comportement d'abord, en langage métier** :

1. Formuler les scénarios `Given / When / Then` avec l'utilisateur (un scénario = une règle métier observable, vocabulaire du domaine, pas de détail technique) et les faire valider avant de coder.
2. Utiliser l'outil BDD du projet (Behat, Cucumber, behave, pytest-bdd, Playwright BDD…) ; sans outil, exprimer les scénarios en tests nommés par le comportement, sans installer de dépendance sans accord.
3. Implémenter les étapes (`steps`) puis le code, avec la même boucle rouge / vert / refactor.

Les scénarios BDD se gardent peu nombreux : les cas limites techniques restent des tests unitaires.

## Lancer et lire les résultats

- Lancer d'abord le test ciblé, puis la suite concernée, puis, si c'est raisonnable, toute la suite. Utiliser les filtres de l'outil (`--filter`, `-k`, `-t`) pour itérer vite.
- **Rapporter ce qui a réellement tourné**, avec les vrais nombres (passés, échoués, ignorés). Ne jamais écrire « les tests passent » sans les avoir lancés ; un outil absent se note « (indispo) ».
- Face à un échec, **lire le message et la trace en entier** avant de toucher quoi que ce soit : est-ce un bug du code, un test mal écrit, des données manquantes, ou un problème d'environnement ?

## Diagnostiquer un test qui échoue ou qui est instable

- **Échoue toujours** - reproduire seul (`--filter`), isoler l'assertion fautive, vérifier la donnée d'entrée, puis décider : le code est faux, ou la spécification a changé et le test doit suivre (et pourquoi).
- **Échoue parfois (instable)** - causes fréquentes : dépendance à l'heure, au hasard ou à l'ordre des tests ; données partagées entre tests ; attente asynchrone avec un `sleep` au lieu d'une condition ; port ou service pas prêt. Relancer plusieurs fois, lancer dans un ordre différent, puis **corriger la cause**, pas relancer la CI jusqu'au vert.
- **Passe en local, échoue en CI** - comparer version du langage et des dépendances, variables d'environnement, fuseau horaire, système de fichiers, services disponibles (base de données), ordre d'exécution.

## Intégrer à GitHub Actions

Si le projet a une CI, les tests y tournent à chaque PR :

- Une étape qui lance les mêmes commandes que le runner local, avec les services nécessaires (`services:` pour la base de données, avec `healthcheck`).
- Cache des dépendances (`actions/cache` ou le cache intégré de `setup-*`) ; matrice de versions seulement si le projet supporte vraiment plusieurs versions.
- Permissions minimales (`contents: read`), actions épinglées sur un SHA de commit complet (ne jamais inventer le SHA : `<sha de la release>` à remplir).
- Publier le rapport (JUnit, couverture) en artefact quand c'est utile à la relecture.

## Couverture et mutation

- La couverture dit ce qui **n'est pas** testé, pas que le reste est bien testé. Ne pas viser un pourcentage en soi ; regarder les lignes non couvertes du code que l'on vient de changer.
- Les tests de mutation (outil du projet, s'il est installé) mesurent si les tests détectent vraiment une modification du code ; longs, à réserver à la logique métier critique, jamais lancés par défaut.

## Format de la réponse

- Les tests ajoutés ou modifiés, fichier par fichier, avec ce que chacun protège.
- Le résultat réel de l'exécution (nombre de tests, échecs, ignorés) et la commande exacte pour la rejouer.
- Pour un bug : preuve que le test était rouge avant le correctif et vert après.
- Ce qui n'est pas testé et pourquoi (dette assumée), les risques restants.

## Hors périmètre

- Ne jamais **supprimer, ignorer (`skip`) ou affaiblir** un test qui échoue pour « faire passer » la suite, ni baisser un seuil de couverture, sans le dire clairement et obtenir l'accord de l'utilisateur.
- Ne jamais mettre à jour à l'aveugle des fichiers de référence (snapshots, valeurs attendues) : relire chaque différence et vérifier qu'elle est voulue.
- Ne pas modifier le code de production pour une demande de tests, sauf si c'est nécessaire pour le rendre testable - et alors le dire, le garder minimal et le séparer.
- Ne jamais lancer de tests contre une base de données ou un service de production ; utiliser une base de test dédiée.
- Ne pas installer d'outil de test ou de dépendance sans le demander.
- La revue du diff relève de `/max:review`, l'audit de sécurité de `/max:security`.
