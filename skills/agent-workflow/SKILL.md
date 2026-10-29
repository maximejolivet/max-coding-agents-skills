---
name: agent-workflow
description: Conçoit et pilote un workflow agentique - découpe une tâche en étapes, choisit entre skill, sous-agent, hook, commande ou serveur MCP, définit l'orchestration (séquentielle ou parallèle), la boucle de vérification, les garde-fous et la gestion du contexte, puis écrit le résultat dans les fichiers du projet (CLAUDE.md, skills, agents, hooks). À utiliser quand l'utilisateur veut concevoir, structurer ou améliorer un workflow avec un assistant IA de code, découper une grosse tâche entre plusieurs agents, ajouter une boucle de vérification, versionner des instructions ou des règles projet, brancher un MCP, ou invoque /max:agent-workflow.
---

# Workflow agentique

Concevoir un workflow qu'un agent peut exécuter **sans surveillance rapprochée** : des étapes courtes, une vérification objective à chaque étape, des garde-fous explicites et un contexte maîtrisé. Un bon workflow se résume à : *qui fait quoi, avec quelles entrées, comment on sait que c'est réussi, et ce qui arrête tout*.

## Cadrer avant de concevoir

Poser (ou déduire du projet) ces points, en une ligne chacun :

1. **Objectif** - le résultat observable attendu, pas la méthode.
2. **Critère de réussite vérifiable** - une commande, un test, une checklist. Sans critère vérifiable, pas de boucle possible : le dire et en proposer un.
3. **Périmètre** - fichiers, dépôts, environnements touchés ; ce qui est hors limites.
4. **Récurrence** - tâche ponctuelle (un prompt suffit) ou répétée (elle mérite un skill, un agent ou un hook).
5. **Coût d'une erreur** - réversible (branche, brouillon) ou non (envoi, suppression, déploiement) ; il fixe le niveau de garde-fous.

Lire l'existant avant de proposer : `CLAUDE.md`, `.claude/`, `skills/`, `agents/`, scripts et CI du projet. Étendre ce qui existe plutôt que de dupliquer.

## Découper la tâche

- Des étapes **indépendantes entre elles** quand c'est possible : chacune testable seule, avec une entrée et une sortie claires.
- Une étape = une responsabilité. Si la description de l'étape contient « et », la couper.
- Marquer ce qui peut tourner **en parallèle** (aucune dépendance, aucun fichier écrit en commun) et ce qui doit rester **séquentiel** (la sortie de l'une nourrit l'autre).
- Pour une migration ou un refactoring de grande ampleur, découper **par lots** de taille égale, chacun vérifiable et annulable seul.

## Choisir le bon mécanisme

| Besoin | Mécanisme |
|---|---|
| Savoir-faire répété, déclenché à la demande, qui s'enchaîne avec d'autres | **Skill** (`skills/<nom>/SKILL.md`) |
| Tâche lourde en lecture, qui encombrerait le contexte, ou qui se parallélise | **Sous-agent** en lecture seule (`agents/<nom>.md`) |
| Comportement qui doit avoir lieu **à coup sûr** (avant un outil, à la fin d'une session) | **Hook** (exécuté par le harnais, pas par le modèle) |
| Règle valable pour tout le projet | **`CLAUDE.md`** |
| Donnée ou action sur un service externe (tickets, base, navigateur) | **Serveur MCP** |
| Raccourci d'un prompt fréquent | **Commande** |

Règles : ce qui doit être garanti va dans un hook, pas dans une consigne ; un sous-agent ne lance jamais d'autres agents ; un MCP donne accès à un service, il ne remplace pas le savoir-faire (skill) qui dit quand s'en servir.

## Orchestrer

- **Un orchestrateur, des exécutants.** Le skill (ou la session principale) décide, lance, assemble ; les sous-agents font une tâche étroite et rendent un résumé court.
- **Briefer chaque agent comme s'il arrivait sans contexte** : objectif, entrées exactes (chemins, diff), ce qui est exclu, format de sortie attendu.
- **Un seul écrivain par fichier.** Les agents en parallèle lisent ; l'orchestrateur applique les écritures, ou chaque agent travaille dans son propre worktree.
- **Fusionner les retours** : dédoublonner, classer par gravité, trancher les contradictions - ne pas empiler les rapports.
- Ne pas multiplier les agents : trois agents ciblés valent mieux que dix. Chaque agent a un coût en contexte et en jetons.

## Boucle de vérification

Chaque étape finit par une **preuve**, pas par une affirmation :

1. **Produire** - l'agent fait le changement.
2. **Vérifier objectivement** - tests, linter, build, `tests/check.sh`, diff relu par un agent indépendant. Jamais « ça devrait marcher ».
3. **Corriger ou arrêter** - en cas d'échec, une correction ciblée à partir du message d'erreur réel, avec une **limite de tentatives** (2 ou 3). Au-delà, s'arrêter et remonter le blocage plutôt que tourner en rond.
4. **Rapporter ce qui a réellement tourné**, avec les vrais résultats.

Le vérificateur doit être **indépendant du producteur** : un agent qui relit son propre travail valide ses propres erreurs. Préférer une commande déterministe, sinon un agent de revue distinct (`/max:review`).

## Garde-fous

- **Moindre privilège** : un agent d'analyse reçoit des outils en lecture seule ; pas d'outil d'écriture sans besoin.
- **Actions irréversibles ou sortantes** (push, envoi, suppression, déploiement, post sur un service) : confirmation explicite, jamais par défaut.
- **Travailler sur une branche ou un brouillon**, jamais sur `main`.
- **Pas de secret dans les instructions** ni dans les prompts versionnés.
- **Arrêts francs** : conditions qui interrompent le workflow (test rouge après N essais, périmètre dépassé, donnée inattendue).
- **Journal** : garder la trace de ce que chaque étape a fait, pour pouvoir annuler et relire.

## Gérer le contexte

- Le contexte est une ressource limitée : **déléguer à un sous-agent** tout ce qui lit beaucoup pour ne rendre qu'une conclusion.
- Charger les connaissances **à la demande** (comme `stacks/<techno>/INDEX.md`), pas toutes d'avance.
- Écrire les décisions durables dans un fichier (`CLAUDE.md`, plan, note) plutôt que de compter sur la conversation, qui sera résumée.
- Pour une longue tâche : un fichier de plan avec cases à cocher, mis à jour à chaque étape, qui permet de reprendre après une coupure.
- Repartir d'un contexte propre entre deux tâches sans rapport.

## Industrialiser

- **Versionner** les instructions : `CLAUDE.md`, skills, agents et hooks vivent dans le dépôt, passent en PR et sont relus comme du code.
- **Tester** le workflow : un contrôle de cohérence automatique (`tests/check.sh`) et des scénarios manuels pour le comportement réel.
- **Écrire les règles projet** courtes et vérifiables (une règle = un comportement observable), classées par sujet.
- **Mesurer** avant de conclure à un gain : temps par tâche, taux de rejet en revue, régressions après merge, comparés à une référence. Sans mesure, parler d'impression, pas de gain.

## Format de la réponse

1. **Objectif et critère de réussite** en deux lignes.
2. **Schéma du workflow** : les étapes, leur enchaînement (séquentiel / parallèle), le mécanisme choisi pour chacune.
3. **Boucle de vérification** : la commande ou l'agent de contrôle, la limite de tentatives, la condition d'arrêt.
4. **Garde-fous** retenus et ce qui demande une confirmation.
5. **Fichiers à créer ou modifier**, avec leur contenu proposé.
6. **Comment tester** le workflow, et ce qui reste non vérifié.

Proposer d'abord, n'écrire dans le projet qu'après accord de l'utilisateur.

## Hors périmètre

- Ne pas créer d'agent, de hook ou de serveur MCP sans accord ; ne pas modifier `settings.json` (voir le skill `update-config`).
- Ne pas contourner un garde-fou existant du projet pour « fluidifier » le workflow.
- Ne pas installer d'outil ou de dépendance sans le demander.
- L'écriture d'un skill de développement relève des skills de stack, la relecture du résultat de `/max:review`, les tests de `/max:test`.
