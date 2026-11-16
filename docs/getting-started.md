# Démarrer

Objectif : passer de « plugin installé » à « première PR relue » en quelques minutes.

## Avant de commencer

```bash
/plugin marketplace add maximejolivet/claude-skills-max
/plugin install max@max
```

Vérifie en tapant `/max:` : les skills doivent apparaître. Pour ouvrir ou relire des PR, connecte la CLI GitHub avec `gh auth login`.

## Parcours d'une modification

Voici l'enchaînement habituel, du premier geste à la PR.

| # | Je veux…                    | Je lance                                       | Résultat attendu |
| :-: | :------------------------ | :--------------------------------------------- | :--------------- |
| 1 | Une branche propre          | `/max:switch`                                  | `feat/<slug>` ou `fix/<slug>` créée depuis `main` à jour, travail en cours préservé. |
| 2 | Écrire le code              | `/max:symfony`, `/max:nuxt` ou `/max:react`    | Le skill lit le projet, propose une approche, implémente, puis t'oriente vers la relecture. |
| 3 | Valider par des tests       | `/max:test`                                    | Tests ajoutés et exécutés ; pour un bug, le test qui échoue vient en premier. |
| 4 | Enregistrer                 | `/max:commit`                                  | Un message `type(scope): emoji description`. |
| 5 | Marquer la version          | `/max:versioning`                              | +0.0.1 propagé aux trois endroits concernés. |
| 6 | Un regard critique          | `/max:review`                                  | Verdict trié par gravité ; sous-agents en parallèle si le diff est gros. |
| 7 | Publier                     | `/max:pull-request`                            | Push de la branche, PR en Draft vers `main`. |

Pour examiner la PR d'une autre personne : `/max:pr-review 42` (numéro ou URL). Tu obtiens un brouillon ; rien n'est posté sans ton accord.

## Les branches

Une branche par changement, toujours issue de `main`. Après le merge :

- `/max:switch delete` retire la branche liée à ta PR (ajoute `--remote` pour la distante, `--force` si elle n'est pas fusionnée) ;
- `/max:switch clean` supprime d'un coup toutes les branches déjà mergées.

## Au-delà du cycle

Ces skills s'utilisent à part, selon le besoin : `/max:debug` pour un bug, `/max:refactor` pour un chantier large, `/max:security` pour un audit, `/max:docker` et `/max:kubernetes` pour l'infrastructure, `/max:ci` pour les workflows, `/max:explain` pour découvrir un dépôt, `/max:agent-workflow` pour structurer un travail agentique. La liste complète est dans le [README](../README.md).

## Ma techno n'est pas livrée

Pas de blocage : le skill détecte la stack, applique des règles par défaut pour le langage et te l'indique. Pour ajouter la techno durablement, suis [stacks.md](stacks.md).
