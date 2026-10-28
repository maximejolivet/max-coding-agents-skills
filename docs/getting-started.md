# Démarrer avec Max

Du plugin installé à la première pull request relue.

## 1. Installer

```bash
/plugin marketplace add maximejolivet/claude-skills-max
/plugin install max@max
```

Tape `/max:` pour lister les skills. Les skills `pull-request` et `pr-review` demandent la CLI [`gh`](https://cli.github.com) connectée (`gh auth login`).

## 2. Le cycle d'une fonctionnalité

| Étape                | Commande                         | Ce qui se passe                                                         |
| :------------------- | :------------------------------- | :---------------------------------------------------------------------- |
| Développer           | `/max:symfony`, `/max:nuxt`, `/max:react` | Lit le code existant, propose l'approche, implémente, puis renvoie vers `/max:review`. |
| Tester               | `/max:test`                      | Écrit et lance les tests ; test de non-régression d'abord pour un bug.  |
| Brancher             | `/max:switch`                    | Crée `feat/<slug>` ou `fix/<slug>` depuis `main` à jour, sans perdre de travail. |
| Committer            | `/max:commit`                    | Message `type(scope): emoji description`.                               |
| Versionner           | `/max:versioning`                | +0.0.1 par PR, aligné dans `plugin.json`, `marketplace.json` et le badge.       |
| Relire               | `/max:review`                    | Verdict classé par gravité, sous-agents en parallèle sur un gros diff.  |
| Publier              | `/max:pull-request`              | Commit ciblé, push, PR en Draft vers `main`.                            |
| Relire une autre PR  | `/max:pr-review <url ou n°>`     | Prépare une review ; ne la poste que sur accord explicite.              |

Hors cycle : `/max:security` (audit), `/max:docker`, `/max:kubernetes`.

## 3. Branches

Partir de `main` à jour, une branche par changement (`feat/<slug>` ou `fix/<slug>`), PR en Draft vers `main`. `/max:switch` crée la branche depuis `main` à jour et, après le merge, nettoie les branches mergées.

## 4. Et si ma techno n'est pas fournie ?

Les skills génériques fonctionnent quand même : ils détectent la stack et appliquent des valeurs par défaut par langage, en le disant dans leur sortie. Pour ajouter une techno, voir [stacks.md](stacks.md).
