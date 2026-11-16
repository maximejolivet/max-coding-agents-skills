---
name: test
description: Écrit, exécute et diagnostique des tests automatisés - unitaires, d'intégration, fonctionnels et de bout en bout - avec un test de non-régression d'abord pour un bug, un mode TDD (rouge, vert, refactor) ou BDD (scénarios Given/When/Then) sur demande, des tests déterministes et isolés, et l'analyse des échecs ou des tests instables. Indépendant de la stack - charge la section test de stacks/<stack>/INDEX.md quand elle existe. À utiliser quand l'utilisateur demande d'ajouter, d'écrire, de corriger ou de lancer des tests, d'augmenter la couverture, de comprendre un test qui échoue ou qui est instable, ou invoque /max:test. Aussi quand il demande de développer en TDD ou en BDD.
---

# Tests

Écrire des tests qui protègent réellement le comportement, les exécuter pour de vrai et comprendre leurs échecs. Un bon test est **déterministe**, **isolé**, **lisible** et **échoue pour la bonne raison**. Le but n'est pas un pourcentage de couverture : c'est de pouvoir modifier le code sans crainte.

## Stack et outillage

Ce skill est indépendant de la stack ; outils et conventions viennent d'une ressource chargée à la demande. Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` :

1. Lancer `stacks/detect.sh` : il donne les frameworks, l'**outil de test** (PHPUnit, Pest, Jest, Vitest, Playwright, pytest, `go test`, RSpec…), le gestionnaire de paquets et le **runner**. Annoncer la stack en une ligne.
2. Lire `stacks/<stack>/INDEX.md` pour la nature **test** (qui inclut `core` + `test`) : outils, types de tests disponibles, base de données de test, fixtures. Pour un framework dérivé, charger la ressource la plus spécifique puis celle de son parent (Nuxt puis Vue, Next.js puis React).
3. **Repli** : sans ressource ou sans section `test`, partir de ce que le projet déclare (scripts de `composer.json` / `package.json`, cibles du `Makefile`, fichiers de configuration), puis des valeurs par défaut et indices de `DETECT.md`, et **le dire** (« pas de resource test pour la stack `<x>` - principes génériques uniquement »). Ne jamais `Read` une ressource inexistante.
4. Exécuter les tests via le **runner** du projet (`make`, puis `docker compose`).

## Lire l'existant avant d'écrire

- Où vivent les tests, comment ils sont nommés et organisés (miroir de `src/`, par fonctionnalité…), quelles classes ou helpers de base existent, comment sont fabriquées les données de test (fixtures, factories, builders).
- Ouvrir deux ou trois tests proches de celui à écrire et **reprendre leurs conventions** (style d'assertion, nommage, structure) au lieu d'importer les siennes.
- Lancer d'abord la suite (ou la partie concernée) pour connaître l'état de départ : des tests déjà rouges ne sont pas imputables au changement en cours.

## Quoi tester, à quel niveau

Choisir le niveau le plus bas qui prouve le comportement : il est plus rapide et plus précis.

- **Unitaire** : une classe ou une fonction isolée, de la logique pure, des cas limites. La grande majorité des tests.
- **Intégration** : plusieurs composants réels ensemble (service + base de données, dépôt, file de messages), pour ce qu'un test unitaire ne démontre pas.
- **Fonctionnel / API** : une requête de bout en bout sur l'application (route, contrôleur, réponse, droits).
- **Bout en bout (navigateur)** : quelques parcours critiques seulement ; lents et fragiles, à garder rares.

À tester en priorité : la logique métier, les cas limites et erreurs (valeurs vides, bornes, entrées invalides), les contrôles d'accès, les régressions déjà rencontrées. Inutile de tester : le code du framework, les getters et setters triviaux, les détails d'implémentation.

## Écrire un bon test

- **Structure Arrange / Act / Assert**, une idée par test, un nom qui énonce le comportement et le cas (`doit_refuser_une_commande_vide`) plutôt que la méthode appelée.
- **Déterministe** : aucune dépendance à l'heure réelle, au hasard, à l'ordre d'exécution, au réseau ni à un `sleep`. Figer l'horloge, injecter le générateur aléatoire, remplacer les appels externes.
- **Isolé** : chaque test prépare ses données et ne compte pas sur celles d'un autre ; la base est remise à zéro entre les tests (transaction annulée, base recréée).
- **Doublures avec modération** : ne simuler (`mock`) que les frontières (réseau, e-mail, horloge, service externe), jamais le code qu'on teste. Un test qui ne vérifie que des appels simulés ne prouve rien.
- **Assertions précises** : vérifier le résultat observable, pas l'état interne ; éviter les assertions trop larges (`assertTrue($x !== null)`) qui passent même à tort.
- **Lisibilité** : un test se comprend sans ouvrir trois autres fichiers ; mieux vaut une petite duplication qu'un helper obscur.
- **Données** : factories ou builders aux valeurs par défaut valides, en ne précisant que ce qui compte pour le test.

## Corriger un bug : le test d'abord

1. Écrire un test qui **reproduit** le bug et le lancer : il doit **échouer**, et pour la bonne raison (le message d'échec correspond au symptôme).
2. Corriger le code.
3. Relancer : le test passe, ainsi que le reste de la suite.

Un test jamais vu rouge n'a pas prouvé qu'il détecte le bug. Si c'est impossible (bug non reproductible en test), le dire et fournir des étapes de recette manuelle à la place.

## TDD et BDD (sur demande)

À n'appliquer que si l'utilisateur le demande ou si le projet les pratique déjà (tests écrits avant le code, fichiers `.feature`).

**TDD, boucle rouge / vert / refactor**, un petit comportement à la fois :

1. **Rouge** : écrire **un** test qui décrit le prochain comportement, le lancer, le voir échouer **pour la bonne raison**.
2. **Vert** : écrire le code le plus simple qui le fait passer, le lancer, voir toute la suite verte.
3. **Refactor** : nettoyer le code et le test avec la suite verte, puis la relancer.
4. Recommencer. Annoncer à chaque tour l'étape en cours et le résultat réel de l'exécution ; ne pas écrire plusieurs tests rouges à la fois.

**BDD, le comportement d'abord, en langage métier** :

1. Formuler avec l'utilisateur les scénarios `Given / When / Then` (un scénario = une règle métier observable, vocabulaire du domaine, aucun détail technique) et les faire valider avant de coder.
2. Utiliser l'outil BDD du projet (Behat, Cucumber, behave, pytest-bdd, Playwright BDD…) ; à défaut, exprimer les scénarios en tests nommés par le comportement, sans installer de dépendance sans accord.
3. Implémenter les étapes (`steps`) puis le code, avec la même boucle rouge / vert / refactor.

Garder les scénarios BDD peu nombreux : les cas limites techniques restent des tests unitaires.

## Lancer et lire les résultats

- Commencer par le test ciblé, puis la suite concernée, puis, si c'est raisonnable, toute la suite. Utiliser les filtres de l'outil (`--filter`, `-k`, `-t`) pour itérer vite.
- **Rapporter ce qui a réellement tourné**, avec les vrais nombres (réussis, échoués, ignorés). Ne jamais écrire « les tests passent » sans les avoir lancés ; un outil absent se note « (indispo) ».
- Devant un échec, **lire le message et la trace en entier** avant d'agir : bug du code, test mal écrit, données manquantes ou problème d'environnement ?

## Diagnostiquer un échec ou une instabilité

- **Échoue toujours** : le reproduire seul (`--filter`), isoler l'assertion fautive, vérifier la donnée d'entrée, puis décider : le code est faux, ou la spécification a changé et le test doit suivre (en disant pourquoi).
- **Échoue parfois (instable)** : causes courantes : dépendance à l'heure, au hasard ou à l'ordre des tests ; données partagées ; attente asynchrone par `sleep` au lieu d'une condition ; port ou service pas prêt. Relancer plusieurs fois, changer l'ordre, puis **corriger la cause**, pas relancer la CI jusqu'au vert.
- **Passe en local, échoue en CI** : comparer version du langage et des dépendances, variables d'environnement, fuseau horaire, système de fichiers, services disponibles (base de données), ordre d'exécution.

## Brancher sur GitHub Actions

Si le projet a une CI, les tests y tournent à chaque PR :

- Une étape qui lance les mêmes commandes que le runner local, avec les services nécessaires (`services:` pour la base de données, avec `healthcheck`).
- Cache des dépendances (`actions/cache` ou celui des `setup-*`) ; matrice de versions seulement si le projet en supporte réellement plusieurs.
- Permissions minimales (`contents: read`), actions épinglées sur un SHA de commit complet (ne jamais inventer le SHA : `<sha de la release>` à remplir).
- Publier le rapport (JUnit, couverture) en artefact quand il aide la relecture.

## Couverture et mutation

- La couverture indique ce qui **n'est pas** testé, pas que le reste l'est bien. Ne pas viser un pourcentage pour lui-même ; regarder les lignes non couvertes du code qu'on vient de modifier.
- Les tests de mutation (outil du projet, s'il est installé) mesurent si les tests détectent vraiment une altération du code ; longs, ils se réservent à la logique métier critique et ne se lancent jamais par défaut.

## Forme de la réponse

- Les tests ajoutés ou modifiés, fichier par fichier, avec ce que chacun protège.
- Le résultat réel de l'exécution (nombre de tests, échecs, ignorés) et la commande exacte pour la rejouer.
- Pour un bug : la preuve que le test était rouge avant le correctif et vert après.
- Ce qui n'est pas testé et pourquoi (dette assumée), ainsi que les risques restants.

## Limites

- Ne jamais **supprimer, ignorer (`skip`) ou affaiblir** un test en échec pour « faire passer » la suite, ni baisser un seuil de couverture, sans le dire clairement et obtenir l'accord de l'utilisateur.
- Ne jamais mettre à jour à l'aveugle des fichiers de référence (snapshots, valeurs attendues) : relire chaque différence et vérifier qu'elle est voulue.
- Ne pas modifier le code de production pour une demande de tests, sauf nécessité de le rendre testable, et alors le dire, le garder minimal et le séparer.
- Aucun test contre une base ou un service de production ; utiliser une base de test dédiée.
- Aucun outil de test ou dépendance installés sans demande.
- La revue du diff relève de `/max:review`, l'audit de sécurité de `/max:security`.
