---
name: agent-workflow
description: "Conçoit un workflow agentique - découpe une tâche en étapes, choisit entre skill, sous-agent, hook, commande, CLAUDE.md ou serveur MCP, fixe l'orchestration, la boucle de vérification et les garde-fous, puis propose les fichiers à écrire. À utiliser quand Maxime veut concevoir, structurer ou améliorer un workflow avec un assistant de code, répartir une grosse tâche entre plusieurs agents, ajouter une boucle de vérification, versionner des règles de projet, brancher un MCP, ou invoque /max:agent-workflow."
argument-hint: "[tâche ou workflow à concevoir]"
---

# Concevoir un workflow agentique

## Préalables

1. Lire `${CLAUDE_SKILL_DIR}/../../references/regles.md`, une fois par session.
2. Lire ce que le projet a déjà : `CLAUDE.md`, `.claude/`, `skills/`, `agents/`, scripts, CI. Étendre l'existant plutôt que le doubler.
3. Fixer en une ligne chacun : l'objectif (un résultat observable), le critère de réussite vérifiable, le périmètre, la fréquence, le coût d'une erreur.

## Étapes

1. Découper la tâche en étapes d'une seule responsabilité, chacune avec une entrée et une sortie. Une migration se découpe en lots de taille égale, annulables un à un.
2. Marquer ce qui peut tourner en parallèle (aucune dépendance, aucun fichier écrit en commun) et ce qui reste séquentiel.
3. Choisir un mécanisme par étape :

   | Besoin | Mécanisme |
   | :-- | :-- |
   | Savoir-faire répété, déclenché à la demande | Skill (`skills/<nom>/SKILL.md`) |
   | Lecture lourde, ou travail parallélisable | Sous-agent en lecture seule (`agents/<nom>.md`) |
   | Comportement qui doit se produire à coup sûr | Hook, exécuté par le harnais |
   | Règle valable pour tout le projet | `CLAUDE.md` |
   | Donnée ou action sur un service externe | Serveur MCP |
   | Raccourci d'un prompt fréquent | Commande |

4. Fixer l'orchestration : un orchestrateur qui décide et assemble, des agents qui font une tâche étroite et rendent un résumé court, un seul écrivain par fichier.
5. Écrire la boucle de vérification de chaque étape : produire, vérifier par une commande ou un agent indépendant, corriger avec une limite de deux ou trois essais, s'arrêter au-delà.
6. Écrire les garde-fous : outils en lecture seule pour l'analyse, confirmation avant toute action sortante ou irréversible, travail sur une branche, conditions d'arrêt, journal de ce que chaque étape a fait.
7. Rendre la proposition : objectif et critère, schéma des étapes avec leur mécanisme, boucle de vérification, garde-fous, fichiers à créer avec leur contenu, manière de tester.
8. Attendre l'accord, puis écrire les fichiers.

Le contexte se ménage : déléguer ce qui lit beaucoup, charger les connaissances à la demande, écrire les décisions durables dans un fichier, tenir un plan en cases à cocher pour une tâche longue.

## Points d'arrêt

- Aucun critère de réussite vérifiable : le dire et en proposer un. Sans lui, pas de boucle.
- Le vérificateur serait le producteur lui-même : choisir une commande déterministe, ou un agent distinct (`/max:review`).
- Le workflow demande plus de trois agents : justifier chacun, chaque agent coûte du contexte.
- Un gain est annoncé : il se mesure contre une référence (temps par tâche, rejets en revue, régressions). Sans mesure, c'est une impression.

## Ce qu'il ne fait pas

- Écrire dans le projet avant l'accord.
- Modifier `settings.json` : c'est le rôle du skill `update-config`.
- Créer un agent qui en lance d'autres.
- Contourner un garde-fou existant pour fluidifier le workflow.
- Placer un secret dans une instruction ou un prompt versionné.
