---
name: dev
description: "Développe une fonctionnalité ou un correctif dans la stack du projet, quelle qu'elle soit - lit la demande et le code existant, propose l'approche, implémente par petits pas, vérifie, puis renvoie vers la revue. À utiliser quand Maxime demande d'implémenter, d'ajouter ou de modifier du code (Symfony, Laravel, Django, Nuxt, Vue, React, Next.js ou une stack sans ressource), ou invoque /max:dev."
argument-hint: "[issue, brief ou tâche]"
---

# Développer

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Détecter la stack : suivre `${CLAUDE_SKILL_DIR}/../../stacks/DETECT.md`, nature **dev**. Lire aussi `## security` si la demande touche l'authentification, les droits ou des données privées.
3. Lancer les commandes placées en tête de la ressource de stack : version, gestionnaire de paquets, structure.
4. Lire la demande : l'issue (`gh issue view <n>`) ou le brief. En tirer le comportement attendu, les contraintes, les fichiers à voir en premier. Sans demande écrite : demander l'intention en une ligne.

## Étapes

1. Lire l'existant : configuration, dossiers concernés, éléments à réutiliser, idiomes locaux, ce que le changement va toucher.
2. Résumer en quelques lignes ce qui a été trouvé, puis proposer l'approche la plus simple.
3. Implémenter par petits pas : une unité, son test, puis son branchement.
4. Signaler les cas limites, les points de performance et les tests à ajouter ou à mettre à jour (`/max:test`).
5. Vérifier avec les commandes « Vérifier » de la ressource de stack, lancées par le runner. Rapporter ce qui a réellement tourné.
6. Lancer `/max:review`, puis `/max:pull-request`. Le travail n'est pas fini avant la revue.

Sur un gros projet (plusieurs dizaines de fichiers concernés, ou demande encore floue), confier l'étape 1 à l'agent `max:codebase-surveyor` avec l'outil Agent : racine du projet, tâche en quelques lignes, stack détectée, chemin de la ressource de stack, dossiers à voir en premier. Relire soi-même les fichiers à modifier.

## Points d'arrêt

- L'API voulue n'existe pas dans la version du projet, ou y est dépréciée : ne pas l'écrire, proposer celle de la version.
- Le changement touche le schéma de la base, ajoute une dépendance ou change un réglage global : attendre l'accord.
- Du code existant fait déjà presque la même chose : le signaler avant de coder.
- Aucune ressource pour la stack : suivre les conventions lues dans le projet et le dire.
- Un problème voisin apparaît : le proposer en question séparée, après la tâche.

## Ce qu'il ne fait pas

- Écrire un secret dans le code, un fichier versionné ou une variable lue par le navigateur.
- Désactiver une protection (validation, contrôle d'accès, CSRF, échappement) pour faire passer un cas.
- Appeler une API de production depuis les tests ou le développement.
- Sortir du périmètre demandé.
- Conteneuriser ou déployer : `/max:docker`, `/max:kubernetes`.
