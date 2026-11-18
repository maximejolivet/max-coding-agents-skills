---
name: maintenance
description: "Prend en charge une demande de maintenance applicative sur une application existante - qualifie la demande en corrective ou évolutive, évalue la gravité et l'impact, fixe le périmètre, oriente vers le bon déroulé, protège l'existant contre les régressions, puis prépare le compte rendu d'intervention. À utiliser quand Maxime reçoit un ticket ou une demande client sur une application déjà livrée, parle de maintenance corrective, de maintenance évolutive ou de TMA, ou invoque /max:maintenance."
argument-hint: "[numéro d'issue, ticket ou demande]"
---

# Maintenance applicative

## Préalables

Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.

1. Lire `<max>/references/regles.md`, une fois par session. Elle donne la branche par défaut (`<défaut>`).
2. Détecter la stack : suivre `<max>/stacks/DETECT.md`, nature **dev**.
3. Lire la demande : l'issue (`gh issue view <n>`) ou le ticket. Sans demande écrite : demander l'intention en une ligne.
4. Lancer `git tag --sort=-v:refname | head -5` et `gh release list --limit 5` : trouver la version livrée.
5. Lancer `gh issue list --search "<mots-clés>" --state all` : chercher un doublon ou un précédent.

## Étapes

1. **Qualifier.** Classer la demande en corrective ou évolutive avec la grille de l'annexe. Annoncer le type et la preuve qui le fonde.
2. **Évaluer la gravité** d'une demande corrective avec la grille de l'annexe. Bloquant en production : passer à `/max:hotfix`, puis reprendre à l'étape 7.
3. **Analyser l'impact.** Relever le code touché, ses appelants, les données, les interfaces exposées et les tests qui couvrent la zone. Sur un gros projet, confier ce relevé à l'agent `max:codebase-surveyor` avec l'outil Agent.
4. **Fixer le périmètre.** Montrer la fiche d'intervention de l'annexe et attendre l'accord de Maxime.
5. **Exécuter**, sur une branche dédiée :
   1. corrective : suivre `/max:debug` ;
   2. évolutive : écrire d'abord les tests de caractérisation de la zone sans tests (`/max:test`), puis suivre `/max:dev` ;
   3. schéma de base touché : concevoir la migration avec `/max:migrate-db`.
6. **Contrôler la non-régression.** Lancer la suite complète, puis vérifier chaque parcours voisin relevé à l'étape 3. Terminer par `/max:review` et `/max:pull-request`, sans les relancer si `/max:dev` vient de le faire.
7. **Préparer le compte rendu** avec le modèle de l'annexe et le montrer à Maxime.

## Points d'arrêt

- Le type reste ambigu : exposer les deux lectures avec leurs preuves. Maxime tranche, car le classement peut engager le contrat.
- Le comportement attendu est introuvable (ni spécification, ni test, ni historique) : lister la question à poser au client et s'arrêter.
- La demande mêle correctif et évolution : proposer deux issues (`/max:issue`) et deux PR, le correctif d'abord.
- Le périmètre grossit en cours de route : s'arrêter, mettre à jour la fiche, obtenir un nouvel accord.
- Le changement casse une compatibilité (API publique, format de données, URL) : attendre l'accord.

## Ce qu'il ne fait pas

- Déployer, ou agir sur la production.
- Envoyer le compte rendu ou écrire au client.
- Annoncer un délai ou un coût sans base réelle.
- Refactorer au passage : `/max:refactor`.
- Traiter la maintenance préventive : `/max:security` pour les dépendances, `/max:perf` pour les lenteurs.

## Annexe

### Qualification

| Type | Critère | Preuves à citer |
| :-- | :-- | :-- |
| Corrective | L'application s'écarte d'un comportement attendu, ou une fonction qui marchait ne marche plus | Spécification, test, issue d'origine, commit qui a introduit l'écart |
| Évolutive | La demande ajoute ou change un comportement qui fonctionne comme prévu | Spécification muette ou contraire, code conforme à ce qui a été livré |

### Gravité

| Gravité | Critère | Suite |
| :-- | :-- | :-- |
| Bloquant | Production arrêtée, perte de données, faille exploitée, fonction vitale inutilisable sans contournement | `/max:hotfix` |
| Majeur | Fonction importante dégradée, contournement possible | Prochaine intervention |
| Mineur | Gêne limitée, sans effet sur les données | À regrouper avec d'autres correctifs |

### Fiche d'intervention

```markdown
**Type :** corrective | évolutive - <preuve>
**Gravité :** bloquant | majeur | mineur | sans objet
**Version livrée :** <tag ou commit>
**Demande :** <besoin ou symptôme en une phrase>
**Périmètre :** <ce qui change>
**Hors périmètre :** <ce qui ne change pas>
**Impact :** <code, données, interfaces>
**Risques :** <régressions possibles>
**Vérification :** <tests et parcours à contrôler>
```

### Compte rendu

Écrire pour un lecteur non technique, dans la langue du client. Ne garder le compte rendu que dans la réponse à Maxime, jamais dans le dépôt.

```markdown
**Demande :** <ce qui a été demandé>
**Type :** corrective | évolutive
**Cause :** <origine du problème, pour une corrective>
**Intervention :** <ce qui a changé pour les utilisateurs>
**Vérifications :** <ce qui a réellement tourné>
**Reste à faire :** <déploiement, recette, points non vérifiés>
```
