---
name: explain
description: Explique un dépôt ou une zone de code inconnue - structure, point d'entrée, flux principaux, conventions, commandes pour lancer et tester, zones à risque - sans rien modifier. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core). À utiliser quand l'utilisateur découvre un projet, veut comprendre comment un module fonctionne, prépare un onboarding, demande « comment ça marche » ou « où est-ce que… », ou invoque /max:explain.
---

# Découvrir un code inconnu

Rendre un projet compréhensible en quelques minutes, **en lecture seule**. L'explication repose sur ce que le code contient, pas sur des suppositions : chaque affirmation renvoie à un `fichier:ligne`.

## Stack

Appliquer `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis lire `stacks/<stack>/INDEX.md` pour la nature **core** : elle donne les conventions de la techno à expliquer. Sans ressource, le préciser. Ne jamais `Read` une ressource inexistante.

## Méthode

1. **Cadrer** la demande : tout le dépôt, un module ou un flux (« que se passe-t-il quand on valide une commande ? »). Sans précision, viser le dépôt entier.
2. **Lire dans cet ordre** : `README`, `CLAUDE.md`, manifestes (`package.json`, `composer.json`…), arborescence (`ls`, `git ls-files | head`), point d'entrée, configuration, puis le chemin visé.
3. **Suivre un flux de bout en bout** : de l'entrée (route, commande, événement) à la sortie (base, API, rendu), en nommant chaque fichier traversé.
4. **Gros projet** : `max:codebase-surveyor` dresse la carte en lecture seule ; la synthèse reste dans la session principale.
5. **Historique** : `git log --oneline -20` et `git log --stat` sur la zone, pour voir ce qui évolue et pourquoi.

## Ce que contient l'explication

- **En une phrase** : ce que fait le projet et pour qui.
- **Carte** : dossiers principaux et leur rôle, avec un schéma simple des flux si utile.
- **Point d'entrée et flux clés**, avec `fichier:ligne`.
- **Conventions** : nommage, structure, outillage (linter, formateur), tests.
- **Lancer et tester** : les vraies commandes lues dans le projet (Makefile, scripts, Compose). Rien n'est exécuté sans demande.
- **Zones à risque** : code fragile, dette, couplages, absence de tests, fichiers générés à laisser tranquilles.
- **Par où commencer** : deux ou trois fichiers à lire d'abord.

## Forme de la réponse

Courte et structurée : la phrase de synthèse, la carte, les flux demandés, les commandes, les risques. Distinguer nettement ce qui est **supposé** de ce qui a été **lu**. Pas de récit fichier par fichier.

## Limites

- Lecture seule stricte : ni modification, ni installation, ni lancement (build, migration, serveur) sans demande.
- Aucun comportement inventé : un code non lu se déclare « non vérifié ».
- Pour passer à l'action, indiquer le bon skill (`/max:debug`, `/max:refactor`, `/max:symfony`…) sans le lancer.
