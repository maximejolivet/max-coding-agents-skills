---
name: issue
description: Rédige ou affine une issue GitHub exploitable - problème et valeur, critères d'acceptation vérifiables, périmètre et hors-périmètre, découpage en issues plus petites, étiquettes, puis création avec gh sur accord. Indépendant de la stack. À utiliser quand l'utilisateur veut créer, écrire, préciser ou découper une issue, un ticket, une user story ou un bug report avant de développer, ou invoque /max:issue.
---

# Écrire une issue GitHub

Produire une issue que quelqu'un d'autre (ou `/max:symfony`, `/max:debug`, `/max:pull-request`) peut prendre en main sans poser de question. Une bonne issue expose un **problème** et ce qui prouvera sa résolution ; elle ne dicte pas la solution technique.

## Préparer

1. **Type** : bug, fonctionnalité, tâche technique ou question. À défaut d'indication, le déduire de la demande et l'annoncer.
2. **Contexte du dépôt** : `gh repo view`, puis chercher les issues voisines (`gh issue list --search "<mots-clés>" --state all`) pour éviter un doublon. S'il en existe une, proposer de l'enrichir plutôt que d'en ouvrir une autre.
3. **Modèles** : si `.github/ISSUE_TEMPLATE/` existe, l'utiliser tel quel ; sinon, la structure ci-dessous.
4. **Informations manquantes** : poser en une seule fois les questions utiles (comportement attendu, étapes, environnement, urgence). Ne rien inventer : ce qui est inconnu s'écrit « à confirmer ».

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

- Titre court, à l'impératif, sans le type en préfixe (les étiquettes s'en chargent).
- **Critères d'acceptation** : cases à cocher, chacune vérifiable par une personne ou un test (« quand X, alors Y »). Aucun critère vague (« rapide », « propre »).
- Une issue = un résultat livrable en **une PR facile à relire**.

## Découper

Quand l'issue réclame plusieurs PR, plusieurs profils ou plus de quelques jours, proposer des sous-issues indépendantes et ordonnées, rattachées à une issue parente qui en liste les liens (`- [ ] #123`). Découper par valeur livrée plutôt que par couche technique, autant que possible.

## Étiquettes et rattachement

N'employer que les étiquettes existantes (`gh label list`), ainsi que les jalons et projets déjà en place. En créer exige un accord.

## Création

1. Présenter l'issue complète (titre, corps, étiquettes) et **attendre l'accord**.
2. `gh issue create --title "<titre>" --body-file <fichier> [--label ...]`, avec le corps dans un fichier temporaire pour que le markdown multiligne traverse le shell.
3. Donner l'URL et la suite : `/max:switch feat/<slug>` pour démarrer, `Closes #<n>` dans le commit ou la PR.

## Forme de la réponse

1. Type retenu et doublons éventuels.
2. L'issue (titre, corps, étiquettes) ou la liste des issues découpées.
3. Les points « à confirmer ».
4. Après accord : l'URL créée.

## Limites

- Aucune issue n'est créée, modifiée, fermée ni commentée sans accord explicite.
- Pas de plan d'implémentation détaillé : c'est l'affaire des skills de développement.
- Ni planification de sprint ni choix Scrum/Kanban : c'est le rôle de l'agent `agile-planner`, lancé sur demande.
- Aucune étiquette, aucun jalon ni projet créé sans accord.
