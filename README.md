<div align="center">

<img src="https://www.maxime.bzh/maxime-black.svg" alt="Maxime" height="80" align="middle">
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://github.com/maximejolivet"><img src="https://wsrv.nl/?url=github.com/maximejolivet.png&w=160&h=160&fit=cover&mask=circle" alt="maximejolivet" width="80" height="80" align="middle"></a>

<br>

# Max

**L'atelier Claude Code d'un développeur freelance qui travaille seul sur les dépôts GitHub de plusieurs clients.**

[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-D97757?logo=anthropic&logoColor=white)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/version-1.0.15-lightgrey)](.claude-plugin/plugin.json)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-green)](LICENSE)
[![Check](https://img.shields.io/github/actions/workflow/status/maximejolivet/claude-skills-max/check.yml?label=check)](https://github.com/maximejolivet/claude-skills-max/actions/workflows/check.yml)

</div>

```bash
/plugin marketplace add maximejolivet/claude-skills-max
/plugin install max@max
```

Taper `/max:` pour lister les 26 skills. Mise à jour : `/plugin marketplace update max`, puis `/plugin install max@max`. Prérequis : la CLI [`gh`](https://cli.github.com), connectée par `gh auth login`.

## Ce que Max applique partout

Chaque skill lit d'abord [`references/regles.md`](references/regles.md).

- **Le dépôt du client décide.** Ses conventions (`CLAUDE.md`, `CONTRIBUTING.md`, historique git, CI) passent avant les défauts de Max.
- **Rien ne fuit.** Aucun nom de client, secret ni donnée réelle dans un commit, une PR, une issue ou un exemple.
- **Rien d'irréversible sans accord.** PR en Draft, revue postée sur accord, cluster en lecture seule, aucun contrôle déclaré passé sans avoir tourné.
- **Des réponses qui se suivent.** La prochaine action en première ligne, l'état rappelé à chaque tour, une seule action pour finir.

Défauts quand le dépôt ne dit rien : commits, PR et issues en anglais ; branches `feat/<slug>` ou `fix/<slug>` ; commits `type(scope): emoji description`.

## Les skills

### Git et GitHub

| Commande | Rôle |
| :-- | :-- |
| `/max:switch` | Bascule, crée, supprime ou nettoie une branche sans perdre de travail. |
| `/max:commit` | Écrit le message dans la convention du dépôt, sinon au format sémantique. |
| `/max:pull-request` | Index ciblé, commit, push, PR en Draft liée à l'issue. |
| `/max:rebase` | Rebase ou fusion avec sauvegarde ; `--force-with-lease` sur accord. |
| `/max:issue` | Rédige ou découpe une issue aux critères vérifiables ; création sur accord. |

| Commande | Rôle |
| :-- | :-- |
| `/max:release` | Version d'après les commits, notes, tag et GitHub Release sur accord. |
| `/max:hotfix` | Correctif urgent depuis la version déployée, test d'abord, backport. |
| `/max:versioning` | Monte la version de ce plugin. S'arrête sur tout autre dépôt. |

### Vérification

| Commande | Rôle |
| :-- | :-- |
| `/max:review` | Relit un diff et rend un verdict classé par gravité. Dernière vérification avant livraison. |
| `/max:security` | Audite dépendances, Docker et workflows selon le risque réel dans le projet. |
| `/max:test` | Écrit, lance et diagnostique les tests ; TDD ou BDD sur demande. |
| `/max:pr-review` | Prépare la revue de la PR d'un tiers ; rien n'est posté sans accord. |

### Développement

| Commande | Rôle |
| :-- | :-- |
| `/max:dev` | Développe dans la stack détectée, quelle qu'elle soit, puis renvoie vers la revue. |
| `/max:symfony` | `/max:dev` avec la stack fixée à Symfony 6.4, 7.x, 8.x. |
| `/max:nuxt` | `/max:dev` avec la stack fixée à Nuxt 3 et 4. |
| `/max:react` | `/max:dev` avec la stack fixée à React 18 et 19. |
| `/max:debug` | Remonte à la cause racine : reproduction, hypothèses, bisect, test rouge puis vert. |

| Commande | Rôle |
| :-- | :-- |
| `/max:refactor` | Refactoring ou migration par lots vérifiés et annulables. |
| `/max:perf` | Optimise le goulot prouvé, un changement à la fois, gain mesuré. |
| `/max:a11y` | Audit et corrections RGAA et WCAG. |
| `/max:migrate-db` | Migration réversible, sans verrou long, en expand/contract. |
| `/max:explain` | Explique un dépôt inconnu, en lecture seule. |

### Infrastructure et méthode

| Commande | Rôle |
| :-- | :-- |
| `/max:docker` | Dockerfile, Compose et Makefile reproductibles, minimaux, sûrs. |
| `/max:kubernetes` | Manifestes, Kustomize et Helm ; cluster en lecture seule. |
| `/max:ci` | Écrit, accélère et répare les workflows GitHub Actions. |
| `/max:agent-workflow` | Conçoit un workflow agentique avec sa boucle de vérification. |

## Un cycle sur un dépôt client

```text
/max:explain         # découvrir le dépôt
/max:switch feat/…   # branche depuis la branche par défaut à jour
/max:dev …           # développer
/max:test            # tests
/max:review          # verdict avant livraison
/max:pull-request    # commit, push, PR en Draft
/max:switch delete   # après le merge
```

Le passage en « Ready for review » et le merge reviennent à Maxime.

## Sous le capot

| Couche | Dossier | Rôle |
| :-- | :-- | :-- |
| Skill | `skills/<nom>/SKILL.md` | Porte le déroulé : préalables, étapes, points d'arrêt, limites. |
| Agent | `agents/<nom>.md` | Fait la lecture, en lecture seule, et porte les listes de contrôle. |
| Stack | `stacks/<techno>/INDEX.md` | Apporte le savoir de la techno, chargé à la demande. |

- **Stacks.** `stacks/detect.sh` repère la techno sans rien exécuter. Ressources web livrées : Symfony, Laravel, Django, Nuxt, Vue, React, Next.js. Les autres stacks, web ou logicielles, passent par le repli de [`stacks/DETECT.md`](stacks/DETECT.md).
- **Agents.** Quatre relecteurs pour `/max:review`, trois auditeurs pour `/max:security`, un explorateur de code, et `docs-updater` pour ce dépôt. Détail : [`docs/agents.md`](docs/agents.md).
- **Garde-fou git.** Un hook `PreToolUse` (`scripts/guard-git.sh`) refuse `git push --force` et tout push direct vers `main` ou `master`. Sans `python3`, il laisse passer.
- **Contrôles.** `sh tests/check.sh` vérifie la cohérence du dépôt, en CI à chaque PR. [`tests/SCENARIOS.md`](tests/SCENARIOS.md) liste les scénarios à rejouer à la main.

## Modifier le plugin

- [CONTRIBUTING.md](CONTRIBUTING.md) : le flux, et quel fichier toucher pour quelle tâche.
- [docs/skill-anatomy.md](docs/skill-anatomy.md) : frontmatter, plan uniforme et règles d'écriture d'un skill.
- [docs/agents.md](docs/agents.md) : appelant, outils et modèle de chaque agent.

## Licence

[MIT](LICENSE) © 2026 Maxime
