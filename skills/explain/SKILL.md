---
name: explain
description: Explique un dépôt ou une zone de code inconnue - structure, point d'entrée, flux principaux, conventions, commandes pour lancer et tester, zones à risque - sans rien modifier. Indépendant de la stack - charge stacks/<stack>/INDEX.md (core). À utiliser quand l'utilisateur découvre un projet, veut comprendre comment un module fonctionne, prépare un onboarding, demande « comment ça marche » ou « où est-ce que… », ou invoque /max:explain.
---

# Comprendre un code inconnu

Rendre un projet lisible en quelques minutes, **en lecture seule**. L'explication s'appuie sur ce qui est dans le code, pas sur ce qu'on devine : chaque affirmation cite un `fichier:ligne`.

## Détecter la stack

Suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md` (lancer `stacks/detect.sh`), annoncer la stack, puis charger `stacks/<stack>/INDEX.md` pour la nature **core** afin d'expliquer les conventions de la techno. Sans ressource, le dire. Ne jamais `Read` une ressource inexistante.

## Méthode

1. **Cadrer la question** : le dépôt entier, un module, un flux (« que se passe-t-il quand on valide une commande ? »). Sans précision, partir du dépôt entier.
2. **Lire dans l'ordre** : `README`, `CLAUDE.md`, manifestes (`package.json`, `composer.json`…), arborescence (`ls`, `git ls-files | head`), point d'entrée, configuration, puis le chemin demandé.
3. **Suivre un flux de bout en bout** : de l'entrée (route, commande, événement) jusqu'à la sortie (base, API, rendu), en nommant chaque fichier traversé.
4. **Gros projet** : `max:codebase-surveyor` cartographie en lecture seule ; la synthèse reste dans la session principale.
5. **Historique** : `git log --oneline -20` et `git log --stat` sur la zone pour comprendre ce qui bouge et pourquoi.

## Contenu de l'explication

- **En une phrase** : ce que fait le projet et pour qui.
- **Carte** : dossiers principaux, rôle de chacun, schéma simple des flux si utile.
- **Point d'entrée et flux clés** : avec `fichier:ligne`.
- **Conventions** : nommage, structure, outils (linter, formateur), tests.
- **Lancer et tester** : les vraies commandes lues dans le projet (Makefile, scripts, Compose). Ne rien lancer sans que l'utilisateur le demande.
- **Zones à risque** : code fragile, dette, couplages, absence de tests, fichiers générés à ne pas toucher.
- **Par où commencer** : 2 ou 3 fichiers à lire en premier.

## Format de la réponse

Court et structuré : la phrase de synthèse, la carte, les flux demandés, les commandes, les risques. Marquer clairement ce qui est **supposé** et ce qui est **lu**. Pas de long récit fichier par fichier.

## Hors périmètre

- Strictement lecture seule : ne modifie, n'installe ni ne lance rien (pas de build, de migration ni de serveur) sans demande.
- Ne pas inventer un comportement : si le code n'est pas lu, dire « non vérifié ».
- Proposer ensuite le bon skill pour agir (`/max:debug`, `/max:refactor`, `/max:symfony`…), sans le lancer.
