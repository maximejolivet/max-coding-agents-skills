---
name: debug
description: Diagnostique et corrige un bug en remontant à sa cause racine - reproduction fiable d'abord, hypothèses classées et testées une par une, bisect git pour trouver le commit fautif, test de non-régression vu rouge puis vert, correctif minimal. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core + dev). À utiliser quand l'utilisateur signale un bug, une erreur, une exception, un test qui échoue, un comportement inattendu, une régression, ou invoque /max:debug.
---

# Chasser un bug jusqu'à sa cause

Comprendre **pourquoi** le bug existe avant de le corriger. Un correctif posé sur un symptôme, sans cause établie, resurgit autrement. On ne tâtonne pas : chaque action sert à valider ou réfuter une hypothèse.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack en une ligne, puis lire `stacks/<stack>/INDEX.md` pour la nature **dev** (qui inclut `core`) : pièges de la techno et de sa version. Sans ressource, le dire et suivre les conventions lues dans le projet. Ne jamais `Read` une ressource inexistante.

## 1. Poser le symptôme

- Comportement **observé** face au comportement **attendu**, une phrase chacun.
- Message d'erreur et trace complets, versions, environnement, fréquence (toujours, parfois, depuis quand).
- Lire l'issue liée si elle existe (`gh issue view`). Ne rien supposer d'implicite : réclamer la pièce manquante au lieu de l'inventer.

## 2. Reproduire

- Viser une reproduction **minimale et déterministe** : une commande, un test ou une requête qui échoue à chaque fois.
- Bug intermittent : repérer ce qui varie (ordre, temps, concurrence, données, état partagé) et le figer ; relancer plusieurs fois pour estimer le taux d'échec.
- Reproduction impossible : le dire, énumérer ce qui manque (logs, données, configuration) et s'arrêter. Aucun correctif à l'aveugle.

## 3. Isoler

Rétrécir le champ, du moins coûteux au plus coûteux :

1. **Lire la trace** de bas en haut jusqu'au premier code du projet, et lire le code autour, pas seulement la ligne fautive.
2. **Régression ?** Si cela fonctionnait avant, `git bisect run <commande de repro>` désigne le commit en cause ; sinon `git log -S` ou `git blame` sur la zone. Faire le bisect sur une branche jetable et terminer par `git bisect reset`.
3. **Réduire l'entrée** ou le code jusqu'à ce que le bug s'évanouisse : ce qu'on vient d'enlever est la cause, ou y conduit.
4. **Observer** plutôt que supposer : logs temporaires, débogueur, `dump` de valeurs réelles aux frontières. Retirer cette instrumentation avant de conclure.

Sur un gros projet, `max:codebase-surveyor` peut cartographier la zone en lecture seule ; les modifications restent dans la session principale.

## 4. Hypothèses

- Formuler 2 ou 3 hypothèses **classées par vraisemblance**, chacune avec le test qui la confirme ou l'écarte.
- N'en tester **qu'une à la fois** et consigner le résultat. Une hypothèse écartée est une information, pas un échec.
- La cause racine est établie lorsqu'on sait **expliquer tout le symptôme**, y compris son absence ailleurs. Sinon, poursuivre.
- Trois hypothèses réfutées : retour à l'étape 1, le cadrage est sans doute faux.

## 5. Corriger

1. **Test de non-régression d'abord** (`/max:test`) : il reproduit le bug et on le **voit rouge** pour la bonne raison.
2. **Correctif minimal** sur la cause, pas sur le symptôme : pas de `try/catch` qui engloutit l'erreur, pas de valeur par défaut qui masque, pas de `sleep`.
3. Voir le test **vert**, puis relancer suite complète, linter et types.
4. Chercher les **cas jumeaux** (`grep` du même motif ailleurs) ; les signaler ou les traiter dans un commit séparé.

## Forme de la réponse

1. Symptôme : observé contre attendu.
2. Reproduction : commande ou test, et son résultat.
3. Cause racine : ce qui se passe, `fichier:ligne`, et le commit d'origine s'il est retrouvé.
4. Correctif : ce qui change, test ajouté, vérification réelle (chiffres).
5. Risques, cas jumeaux et points non vérifiés.

## Limites

- Pas de refactoring au passage : c'est le rôle de `/max:refactor`.
- Un test ne se supprime, ne s'ignore ni ne s'affaiblit pour passer.
- Une erreur ne se masque pas (catch vide, retry en boucle, délai rallongé) en guise de correctif.
- Aucun `git push`, merge, `git reset --hard` ni modification de données de production sans accord explicite ; bisect et essais se font sur une branche, jamais sur `main`.
- Retirer le code d'instrumentation (logs, `dump`, `debugger`) avant de rendre la main.
- La relecture relève de `/max:review`, les tests de `/max:test`, la PR de `/max:pull-request`.
