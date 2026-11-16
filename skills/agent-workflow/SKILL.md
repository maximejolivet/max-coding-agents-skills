---
name: agent-workflow
description: Conçoit et pilote un workflow agentique - découpe une tâche en étapes, choisit entre skill, sous-agent, hook, commande ou serveur MCP, définit l'orchestration (séquentielle ou parallèle), la boucle de vérification, les garde-fous et la gestion du contexte, puis écrit le résultat dans les fichiers du projet (CLAUDE.md, skills, agents, hooks). À utiliser quand l'utilisateur veut concevoir, structurer ou améliorer un workflow avec un assistant IA de code, découper une grosse tâche entre plusieurs agents, ajouter une boucle de vérification, versionner des instructions ou des règles projet, brancher un MCP, ou invoque /max:agent-workflow.
---

# Concevoir un workflow agentique

Bâtir un enchaînement qu'un agent peut dérouler **sans être surveillé de près** : étapes courtes, preuve objective à chaque étape, garde-fous explicites, contexte sous contrôle. Un bon workflow tient en une phrase : *qui fait quoi, avec quelles entrées, à quoi on reconnaît le succès, et ce qui arrête tout*.

## Cadrer d'abord

Établir (ou déduire du projet) ces points, une ligne chacun :

1. **Objectif** : le résultat observable attendu, pas la méthode.
2. **Critère de réussite vérifiable** : une commande, un test, une checklist. Sans critère vérifiable, aucune boucle n'est possible : le dire et en proposer un.
3. **Périmètre** : fichiers, dépôts, environnements concernés ; ce qui est exclu.
4. **Fréquence** : tâche ponctuelle (un prompt suffit) ou répétée (elle justifie un skill, un agent ou un hook).
5. **Coût d'une erreur** : réversible (branche, brouillon) ou non (envoi, suppression, déploiement). C'est lui qui règle le niveau de garde-fous.

Lire l'existant avant de proposer : `CLAUDE.md`, `.claude/`, `skills/`, `agents/`, scripts et CI du projet. Prolonger ce qui existe au lieu de le dupliquer.

## Découper

- Des étapes **aussi indépendantes que possible** : chacune testable seule, avec entrée et sortie claires.
- Une étape, une responsabilité. Si sa description contient « et », la scinder.
- Distinguer ce qui peut tourner **en parallèle** (aucune dépendance, aucun fichier écrit en commun) de ce qui reste **séquentiel** (la sortie de l'une alimente l'autre).
- Pour une migration ou un refactoring d'ampleur, découper **en lots** de taille égale, chacun vérifiable et annulable seul.

## Choisir le mécanisme

| Besoin | Mécanisme |
|---|---|
| Savoir-faire répété, déclenché à la demande, qui s'enchaîne avec d'autres | **Skill** (`skills/<nom>/SKILL.md`) |
| Tâche lourde en lecture, qui encombrerait le contexte ou se parallélise | **Sous-agent** en lecture seule (`agents/<nom>.md`) |
| Comportement qui doit se produire **à coup sûr** (avant un outil, en fin de session) | **Hook** (exécuté par le harnais, pas par le modèle) |
| Règle valable pour tout le projet | **`CLAUDE.md`** |
| Donnée ou action sur un service externe (tickets, base, navigateur) | **Serveur MCP** |
| Raccourci pour un prompt fréquent | **Commande** |

Principes : ce qui doit être garanti va dans un hook, pas dans une consigne ; un sous-agent ne lance jamais d'autres agents ; un MCP ouvre l'accès à un service sans remplacer le skill qui dit quand s'en servir.

## Orchestrer

- **Un orchestrateur, des exécutants.** Le skill (ou la session principale) décide, lance et assemble ; les sous-agents accomplissent une tâche étroite et renvoient un résumé court.
- **Briefer chaque agent comme s'il arrivait sans contexte** : objectif, entrées exactes (chemins, diff), exclusions, format de sortie attendu.
- **Un seul écrivain par fichier.** Les agents parallèles lisent ; l'orchestrateur applique les écritures, ou chaque agent travaille dans son propre worktree.
- **Fusionner les retours** : dédoublonner, classer par gravité, arbitrer les contradictions, sans empiler les rapports.
- Ne pas multiplier les agents : trois bien ciblés valent mieux que dix, chacun coûtant du contexte et des jetons.

## Boucle de vérification

Chaque étape se termine par une **preuve**, pas par une affirmation :

1. **Produire** : l'agent fait le changement.
2. **Vérifier objectivement** : tests, linter, build, `tests/check.sh`, diff relu par un agent indépendant. Jamais « ça devrait marcher ».
3. **Corriger ou s'arrêter** : en cas d'échec, une correction ciblée à partir du message d'erreur réel, avec une **limite de tentatives** (2 ou 3). Au-delà, stopper et remonter le blocage plutôt que tourner en rond.
4. **Rapporter ce qui a réellement tourné**, résultats réels à l'appui.

Le vérificateur doit être **indépendant du producteur** : un agent qui relit son propre travail valide ses propres erreurs. Préférer une commande déterministe, à défaut un agent de revue distinct (`/max:review`).

## Garde-fous

- **Moindre privilège** : un agent d'analyse n'a que des outils en lecture ; aucun outil d'écriture sans besoin.
- **Actions irréversibles ou sortantes** (push, envoi, suppression, déploiement, publication sur un service) : confirmation explicite, jamais par défaut.
- **Travailler sur une branche ou un brouillon**, jamais sur `main`.
- **Aucun secret dans les instructions** ni dans les prompts versionnés.
- **Arrêts francs** : conditions qui interrompent le workflow (test rouge après N essais, périmètre dépassé, donnée inattendue).
- **Journal** : consigner ce que chaque étape a fait, pour annuler et relire.

## Maîtriser le contexte

- Le contexte est une ressource limitée : **déléguer à un sous-agent** tout ce qui lit beaucoup pour n'en rapporter qu'une conclusion.
- Charger les connaissances **à la demande** (comme `stacks/<techno>/INDEX.md`), pas toutes d'avance.
- Écrire les décisions durables dans un fichier (`CLAUDE.md`, plan, note) plutôt que de compter sur la conversation, qui sera résumée.
- Pour une longue tâche : un plan à cases à cocher, mis à jour à chaque étape, permet de reprendre après une coupure.
- Repartir d'un contexte propre entre deux tâches sans lien.

## Industrialiser

- **Versionner** les instructions : `CLAUDE.md`, skills, agents et hooks vivent dans le dépôt, passent en PR et se relisent comme du code.
- **Tester** le workflow : un contrôle de cohérence automatique (`tests/check.sh`) et des scénarios manuels pour le comportement réel.
- **Rédiger des règles projet** courtes et vérifiables (une règle = un comportement observable), classées par sujet.
- **Mesurer** avant de conclure à un gain : temps par tâche, taux de rejet en revue, régressions après merge, comparés à une référence. Sans mesure, on parle d'impression, pas de gain.

## Forme de la réponse

1. **Objectif et critère de réussite** en deux lignes.
2. **Schéma du workflow** : étapes, enchaînement (séquentiel / parallèle), mécanisme retenu pour chacune.
3. **Boucle de vérification** : commande ou agent de contrôle, limite de tentatives, condition d'arrêt.
4. **Garde-fous** retenus et actions soumises à confirmation.
5. **Fichiers à créer ou modifier**, avec le contenu proposé.
6. **Comment tester** le workflow, et ce qui reste non vérifié.

Proposer d'abord ; n'écrire dans le projet qu'après l'accord de l'utilisateur.

## Limites

- Aucun agent, hook ni serveur MCP créé sans accord ; `settings.json` n'est pas modifié (voir le skill `update-config`).
- Ne pas contourner un garde-fou existant du projet pour « fluidifier » le workflow.
- Aucun outil ou dépendance installé sans demande.
- L'écriture d'un skill de développement revient aux skills de stack, la relecture du résultat à `/max:review`, les tests à `/max:test`.
