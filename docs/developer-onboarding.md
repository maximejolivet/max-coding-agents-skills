# Onboarding développeur

Ce guide s'adresse à qui travaille **sur** ce dépôt : ajouter un skill, un agent ou une techno, corriger la doc. Pour **utiliser** les skills dans ses projets, voir [getting-started.md](getting-started.md).

Les règles détaillées sont ailleurs : [skill-anatomy.md](skill-anatomy.md) (format d'un skill), [agents.md](agents.md) (sous-agents), [stacks.md](stacks.md) (technos) et `CLAUDE.md` (conventions du dépôt). Ce document dit dans quel ordre les lire.

## 1. Le modèle mental

Trois couches composables :

| Couche  | Emplacement                      | Rôle                                              | En un mot  |
| :------ | :------------------------------- | :------------------------------------------------ | :--------- |
| Skills  | `skills/<nom>/SKILL.md`          | Le workflow, l'orchestration et le format de sortie | *Comment* |
| Agents  | `agents/<nom>.md`                | Relecteurs et auditeurs en lecture seule          | *Qui*      |
| Stacks  | `stacks/<techno>/INDEX.md`       | Les connaissances propres à une techno            | *Quoi vérifier* |

Quatre règles à intégrer tôt :

- **Le skill orchestre.** Un agent n'en lance jamais d'autres : seul schéma admis, le lancement en parallèle par le skill, puis la fusion des constats.
- **Aucune techno en dur** dans un skill générique (`review`, `security`, `pr-review`, `test`, `docker`, `kubernetes`). Tout passe par `stacks/`.
- **Le `core` d'une techno n'existe qu'une fois.** Ne pas le recopier dans `review`, `security` ou `pr-review` : on le référence.
- **Ne pas dupliquer, renvoyer.** Même règle pour la doc.

`CLAUDE.md` configure Claude Code pour travailler sur ce dépôt ; ce n'est pas un fichier à copier dans d'autres projets. Ce qui se réutilise, ce sont les skills.

## 2. Mise en route

```bash
git clone git@github.com:maximejolivet/claude-skills-max.git
cd claude-skills-max
```

Pas de build ni de dépendances : `tests/check.sh` est un script `sh`. Il faut Claude Code, et la CLI `gh` pour les skills `pull-request` et `pr-review`.

Pour essayer le plugin sur ton clone sans réinstaller :

```bash
claude --plugin-dir ~/Sites/claude-skills-max
/reload-plugins   # après chaque modification
```

## 3. La boucle de vérification

Deux niveaux, comme pour les skills eux-mêmes : on vérifie avant de dire que c'est fini.

```bash
sh tests/check.sh
```

Contrôle la cohérence : frontmatter des skills et agents, références `max:<nom>` et `stacks/<id>/INDEX.md`, versions alignées, détection de stack sur des projets factices. Il tourne aussi en CI (`.github/workflows/check.yml`) sur chaque PR. À lancer avant chaque commit.

Pour un changement de **comportement** important d'un skill ou d'un agent, suivre les scénarios de `tests/SCENARIOS.md` dans une vraie session (`claude --plugin-dir …`) : `check.sh` ne voit pas ce qu'un skill fait réellement.

## 4. Quelle tâche, quel fichier

| Je veux…                         | Je touche                                              | Je mets aussi à jour                                    |
| :------------------------------- | :----------------------------------------------------- | :------------------------------------------------------ |
| Ajouter un skill                 | `skills/<nom>/SKILL.md`                                | Tableau du `README.md`, `description` de `marketplace.json` |
| Ajouter un agent                 | `agents/<nom>.md` + le skill qui le lance              | `docs/agents.md`, `README.md`                           |
| Ajouter une techno               | `stacks/detect.sh` + `stacks/<techno>/INDEX.md`        | Aucun skill ne change                                   |
| Changer une règle propre à une techno | la section concernée de `stacks/<techno>/INDEX.md` | Le `core` reste écrit une seule fois                    |
| Publier une nouvelle version     | `version` dans `marketplace.json` **et** `plugin.json` | Le badge de version du `README.md`                      |

## 5. Flux de contribution

1. Créer `feat/<slug>` ou `fix/<slug>` depuis `main` à jour (`/max:switch`).
2. Modifier, puis `sh tests/check.sh`.
3. Committer au format `type(scope): emoji description` (`/max:commit`).
4. Incrémenter la version (`/max:versioning`).
5. `/max:review`, puis `/max:pull-request` : PR en Draft vers `main`.
6. Après le merge : nettoyer les branches mergées (`/max:switch`).

## 6. Pièges fréquents

- Un skill générique qui nomme une techno : déplacer le contenu dans `stacks/`.
- Un `core` recopié dans `review` ou `security` : le référencer à la place.
- `version` différente entre `marketplace.json` et `plugin.json` : `check.sh` échoue.
- Une `description` qui ne dit pas **quand** utiliser le skill : il ne se déclenchera pas à la bonne demande.
- Un agent qui modifie des fichiers ou en lance d'autres : ils sont en lecture seule et ne délèguent pas.
