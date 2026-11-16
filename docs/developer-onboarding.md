# Onboarding développeur

Ce guide est pour toi si tu veux **modifier** ce dépôt : créer un skill, un agent, brancher une techno ou corriger la documentation. Pour simplement **utiliser** le plugin, va plutôt voir [getting-started.md](getting-started.md).

Ordre de lecture conseillé : cette page, puis [skill-anatomy.md](skill-anatomy.md), [agents.md](agents.md), [stacks.md](stacks.md), et enfin `CLAUDE.md` à la racine.

## 1. Trois couches

| Couche | Dossier | Responsabilité |
| :----- | :------ | :------------- |
| Skills | `skills/<nom>/SKILL.md` | Le *comment* : déroulé, orchestration, forme de la sortie. |
| Agents | `agents/<nom>.md` | Le *qui* : relecteurs et auditeurs en lecture seule. |
| Stacks | `stacks/<techno>/INDEX.md` | Le *quoi vérifier* : savoir propre à une techno. |

Quatre règles à garder en tête :

1. **Le skill orchestre.** Il lance les agents ensemble et fusionne leurs retours ; un agent ne lance jamais d'autre agent.
2. **Pas de techno dans un skill transverse** (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`). Elle va dans `stacks/`.
3. **Un `core` unique par techno.** On le référence depuis les autres sections, on ne le recopie pas.
4. **Renvoyer plutôt que dupliquer**, y compris dans la documentation.

`CLAUDE.md` règle le comportement de Claude Code sur ce dépôt ; il n'est pas destiné à être copié ailleurs. Ce qui se réutilise, ce sont les skills.

## 2. Poser l'environnement

```bash
git clone git@github.com:maximejolivet/claude-skills-max.git
cd claude-skills-max
```

Rien à compiler ni à installer : `tests/check.sh` est un script shell. Il te faut Claude Code, et `gh` pour tester `pull-request` et `pr-review`.

Pour essayer tes modifications sans réinstaller le plugin :

```bash
claude --plugin-dir ~/Sites/claude-skills-max
/reload-plugins    # à relancer après chaque édition
```

## 3. Vérifier ton travail

Deux niveaux complémentaires :

- **Automatique.** `sh tests/check.sh` contrôle frontmatter, références `max:<nom>` et `stacks/<id>/INDEX.md`, versions identiques, détection sur projets factices. La CI l'exécute à chaque PR (`.github/workflows/check.yml`) ; lance-le avant chaque commit.
- **Manuel.** Quand le comportement d'un skill ou d'un agent change vraiment, déroule les scénarios de `tests/SCENARIOS.md` dans une session réelle. Le script ne voit pas ce qu'un skill fait en pratique.

## 4. Quel fichier pour quelle tâche

| Je veux…                               | Je modifie                                         | Je n'oublie pas |
| :------------------------------------- | :------------------------------------------------- | :-------------- |
| Créer un skill                         | `skills/<nom>/SKILL.md`                            | Tableau du `README.md` + `description` de `marketplace.json`. |
| Créer un agent                         | `agents/<nom>.md` et le skill appelant             | `docs/agents.md`, `docs/agents-tools.md`, `README.md`. |
| Supporter une techno                   | `stacks/detect.sh`, `stacks/<techno>/INDEX.md`     | Aucun skill à toucher. |
| Ajuster une règle d'une techno         | La section concernée de son `INDEX.md`             | Le `core` reste écrit une seule fois. |
| Sortir une version                     | `version` dans `marketplace.json` et `plugin.json` | Badge du `README.md`. |

## 5. Du changement à la PR

1. `/max:switch` : branche `feat/<slug>` ou `fix/<slug>` depuis `main`.
2. Modifier, puis `sh tests/check.sh`.
3. `/max:commit` : `type(scope): emoji description`.
4. `/max:versioning` : +0.0.1.
5. `/max:review`, puis `/max:pull-request` : PR en Draft vers `main`.
6. Après le merge : `/max:switch delete` ou `/max:switch clean`.

## 6. Erreurs courantes

| Symptôme | Cause probable |
| :------- | :------------- |
| Un skill transverse mentionne une techno | Déplacer ce contenu dans `stacks/`. |
| Le même `core` apparaît dans `review` et `security` | Garder une version, référencer l'autre. |
| `check.sh` échoue sur les versions | `marketplace.json` et `plugin.json` ne portent pas le même numéro. |
| Le skill ne se déclenche pas quand il le devrait | Sa `description` ne précise pas *quand* l'utiliser. |
| Un agent modifie des fichiers ou en appelle d'autres | Retirer `Edit`/`Write`/`Agent` : un agent lit seulement. |
