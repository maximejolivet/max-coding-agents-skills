---
name: explain
description: "Explique un dépôt ou une zone de code inconnue, en lecture seule - ce que fait le projet, sa carte, ses flux, ses conventions, les commandes pour le lancer et le tester, ses zones à risque. À utiliser quand Maxime découvre le dépôt d'un client, veut comprendre un module ou un flux, demande « comment ça marche » ou « où est-ce que », ou invoque /max:explain."
argument-hint: "[dépôt, module ou flux]"
---

# Expliquer un code inconnu

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session. Ce skill en est l'exception prévue : l'explication est complète, avec des titres, sans préambule ni formule finale.
2. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **core**.
3. Fixer la question : le dépôt entier, un module ou un flux. Sans précision : le dépôt entier.

## Étapes

1. Lire dans cet ordre : `README`, `CLAUDE.md`, manifestes, arborescence (`git ls-files | head -100`), point d'entrée, configuration, puis la zone demandée.
2. Suivre un flux de bout en bout, de l'entrée (route, commande, événement) à la sortie (base, API, rendu), en nommant chaque fichier traversé.
3. Lire l'historique de la zone : `git log --oneline -20`, `git log --stat`.
4. Rédiger l'explication dans le plan de l'annexe. Chaque affirmation cite un `fichier:ligne`.
5. Proposer le skill qui permet d'agir ensuite (`/max:debug`, `/max:refactor`, `/max:dev`), sans le lancer.

Sur un gros projet, l'agent `max:codebase-surveyor` dresse la carte ; la synthèse reste dans la session.

## Points d'arrêt

- Un comportement n'a pas été lu dans le code : l'écrire « non vérifié ».
- Une commande de lancement ou de test est citée : la donner, ne pas la lancer sans demande.
- Aucune ressource pour la stack : le dire.

## Ce qu'il ne fait pas

- Modifier, installer ou lancer quoi que ce soit : ni build, ni migration, ni serveur.
- Raconter le dépôt fichier par fichier.
- Recopier un secret, un nom de client ou une donnée réelle rencontrés à la lecture.

## Annexe : plan de l'explication

| Section | Contenu |
| :-- | :-- |
| En une phrase | Ce que fait le projet, et pour qui |
| Carte | Dossiers principaux, rôle de chacun, schéma des flux si utile |
| Flux | Point d'entrée et flux demandés, avec `fichier:ligne` |
| Conventions et commandes | Nommage, structure, outils, tests ; commandes lues dans le Makefile, les scripts ou Compose |
| Risques et départ | Code fragile, dette, couplages, zones sans tests, fichiers générés ; deux ou trois fichiers à lire en premier |

Distinguer partout ce qui est lu de ce qui est supposé.
