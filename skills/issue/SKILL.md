---
name: issue
description: Rédige ou affine une issue GitHub exploitable - problème et valeur, critères d'acceptation vérifiables, périmètre et hors-périmètre, découpage en issues plus petites, étiquettes, puis création avec gh sur accord. Indépendant de la stack. À utiliser quand l'utilisateur veut créer, écrire, préciser ou découper une issue, un ticket, une user story ou un bug report avant de développer, ou invoque /max:issue.
---

# Rédiger une issue GitHub

Produire une issue qu'une autre personne (ou `/max:symfony`, `/max:debug`, `/max:pull-request`) peut prendre sans poser de question. Une bonne issue décrit un **problème** et ce qui prouvera qu'il est résolu, pas une solution technique.

## Cadrer

1. **Type** - bug, fonctionnalité, tâche technique ou question. Sans précision, le déduire de la demande et l'annoncer.
2. **Contexte du dépôt** - `gh repo view`, issues proches (`gh issue list --search "<mots-clés>" --state all`) pour éviter un doublon. S'il existe, proposer d'enrichir l'issue existante plutôt qu'en créer une autre.
3. **Modèles** - si `.github/ISSUE_TEMPLATE/` existe, l'utiliser tel quel. Sinon, la structure ci-dessous.
4. **Pièces manquantes** - poser les questions utiles en une seule fois (comportement attendu, étapes, environnement, urgence). Ne pas inventer ce qui n'est pas connu : l'écrire « à confirmer ».

## Structure

**Bug**

```markdown
## Comportement observé
## Comportement attendu
## Étapes pour reproduire
## Environnement (version, navigateur, stack)
## Logs ou captures
## Critères d'acceptation
```

**Fonctionnalité ou tâche**

```markdown
## Contexte et valeur (pour qui, pourquoi)
## Description
## Critères d'acceptation
## Hors-périmètre
## Notes techniques (facultatif : pistes, contraintes, liens)
```

- Titre court à l'impératif, sans le type en préfixe (les étiquettes servent à ça).
- **Critères d'acceptation** : une liste de cases à cocher, chacune vérifiable par une personne ou un test (« quand X, alors Y »). Pas de critère flou (« rapide », « propre »).
- Une issue = un résultat livrable en **une PR relisible**.

## Découper

Si l'issue demande plusieurs PR, plusieurs profils ou plus de quelques jours : proposer des sous-issues indépendantes, ordonnées, avec une issue parente listant les liens (`- [ ] #123`). Découper par valeur livrée, pas par couche technique quand c'est possible.

## Étiquettes et rattachement

Utiliser uniquement les étiquettes qui existent (`gh label list`), les jalons et projets déjà en place. Ne pas en créer sans accord.

## Création

1. Montrer l'issue complète (titre, corps, étiquettes) et **attendre l'accord**.
2. `gh issue create --title "<titre>" --body-file <fichier> [--label ...]`, avec le corps dans un fichier temporaire pour que le markdown multiligne survive au shell.
3. Renvoyer l'URL et la suite : `/max:switch feat/<slug>` pour démarrer, `Closes #<n>` dans le commit ou la PR.

## Format de la réponse

1. Type retenu et doublons éventuels.
2. L'issue (titre, corps, étiquettes) ou la liste d'issues découpées.
3. Les points « à confirmer ».
4. Après accord : l'URL créée.

## Hors périmètre

- Ne jamais créer, modifier, fermer ni commenter une issue sans accord explicite.
- Ne pas proposer d'implémentation détaillée : relève des skills de développement.
- Ne pas planifier de sprint ni choisir Scrum ou Kanban : relève de l'agent `agile-planner`, lancé sur demande.
- Pas d'étiquette, de jalon ou de projet créé sans accord.
