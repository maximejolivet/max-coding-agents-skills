---
name: issue
description: "Rédige ou affine une issue GitHub exploitable - problème et valeur, critères d'acceptation vérifiables, périmètre, découpage en issues plus petites, étiquettes, puis création avec gh sur accord. À utiliser quand Maxime veut créer, écrire, préciser ou découper une issue, un ticket ou un rapport de bug avant de développer, ou invoque /max:issue."
argument-hint: "[demande ou numéro d'issue à affiner]"
---

# Rédiger une issue

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session. Elle donne la langue et les modèles du dépôt.
2. Lancer `gh issue list --search "<mots-clés>" --state all` : chercher un doublon.
3. Lancer `ls .github/ISSUE_TEMPLATE 2>/dev/null; gh label list` : modèles et étiquettes existants.

## Étapes

1. Annoncer le type : bug, fonctionnalité, tâche technique ou question.
2. Poser en une fois les questions utiles. Ce qui reste inconnu s'écrit « to be confirmed ».
3. Rédiger avec le modèle du dépôt, sinon celui de l'annexe. Le titre est court, à l'impératif, sans le type en préfixe.
4. Écrire les critères d'acceptation en cases à cocher, chacune vérifiable : « when X, then Y ».
5. Montrer l'issue complète (titre, corps, étiquettes) et attendre l'accord.
6. Créer : `gh issue create --title "<titre>" --body-file <fichier> [--label ...]`, le corps dans un fichier temporaire hors du dépôt.
7. Donner l'URL et la suite : `/max:switch feat/<slug>`, puis `Closes #<n>` dans le commit.

Une issue décrit un problème et ce qui prouvera sa résolution, pas la solution. Elle tient en une PR relisible.

## Points d'arrêt

- Un doublon existe : proposer d'enrichir l'issue existante.
- L'issue demande plusieurs PR ou plus de quelques jours : proposer des sous-issues ordonnées, découpées par valeur livrée, sous une issue parente (`- [ ] #123`).
- Un critère est vague (« fast », « clean ») : le reformuler ou le retirer.
- L'issue cite un client, un secret ou une donnée réelle : les retirer avant de montrer.

## Ce qu'il ne fait pas

- Créer, modifier, fermer ou commenter une issue sans accord.
- Créer une étiquette, un jalon ou un projet.
- Détailler l'implémentation : les skills de développement s'en chargent.

## Annexe : modèles par défaut

Bug :

```markdown
## Observed behavior
## Expected behavior
## Steps to reproduce
## Environment (version, browser, stack)
## Logs or screenshots
## Acceptance criteria
```

Fonctionnalité ou tâche :

```markdown
## Context and value (who, why)
## Description
## Acceptance criteria
## Out of scope
## Technical notes (optional)
```
