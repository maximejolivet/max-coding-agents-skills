# Détection de la stack

```bash
sh "<max>/stacks/detect.sh"            # racine courante
sh "<max>/stacks/detect.sh" <dossier>  # sous-projet d'un monorepo
```

Le script lit le projet sans rien exécuter ni installer. Une ligne par constat : `catégorie<TAB>identifiant<TAB>preuve`.

## Étapes

1. Lancer le script à la racine. Dans un monorepo (`apps/`, `packages/`, `services/`), le lancer sur chaque sous-dossier touché par la tâche.
2. Annoncer la stack en une ligne : « Stack : Symfony 7 (PHP, composer, PHPUnit), Docker, GitHub Actions ».
3. Retenir le runner : la première ligne `runner` (`make`, puis `docker compose`). Les commandes du projet passent par lui.
4. Pour chaque ligne `resource` qui donne un chemin, lire `<max>/stacks/<id>/INDEX.md` : la section `## core`, plus celle de la nature du skill (tableau ci-dessous).
5. Pour une ligne `resource` à `aucune`, ou une section absente : appliquer le repli. Ne jamais lire une ressource absente.

Règles de choix :

- Le framework prime sur le langage.
- Le plus spécifique d'abord, puis son parent : `nuxt` puis `vue`, `nextjs` puis `react`.
- Plusieurs frameworks : chaque fichier ne reçoit que les règles de sa techno.
- Sans `sh` : lire `detect.sh` et appliquer ses tests à la main.

## Nature chargée par chaque skill

| Skill | Sections lues |
| :-- | :-- |
| `review`, `pr-review` | `core` + `review` |
| `security` | `core` + `security` |
| `test` | `core` + `test` |
| `docker`, `kubernetes`, `ci` | `core` + `deploy` |
| `dev`, `symfony`, `nuxt`, `react`, `debug`, `refactor`, `perf`, `a11y`, `migrate-db` | `core` + `dev` |
| `explain` | `core` |

## Catégories de sortie

| Catégorie | Valeurs |
| :-- | :-- |
| `language` | php, node, typescript, python, go, ruby, rust, java, dotnet |
| `package-manager` | composer, npm, pnpm, yarn, bun, pip, poetry, uv, pipenv, go-modules, bundler, cargo, maven, gradle |
| `framework` | symfony, laravel, drupal, wordpress, nextjs, nuxt, vue, react, angular, svelte, nestjs, express, django, fastapi, flask, rails, spring-boot |
| `parent` | `nuxt vue`, `nextjs react` |
| `test` | phpunit, pest, jest, vitest, playwright, cypress, pytest, go-test, rspec |
| `tooling` | docker, kubernetes, github-actions, dependabot, pr-template, commitlint |
| `runner` | make, docker compose |
| `resource` | chemin de `stacks/<id>/INDEX.md`, ou `aucune` |

## Repli sans ressource

Les stacks web courantes ont une ressource. Une stack logicielle (Go, Rust, Java, .NET, Python hors web) ou un framework sans dossier passe par ce repli.

1. Le dire : « pas de resource `<nature>` pour la stack `<id>` - règles génériques uniquement ».
2. Partir de ce que le projet déclare : `scripts` de `composer.json` et `package.json`, cibles du `Makefile`, `pyproject.toml`, `.github/workflows/`.
3. Compléter par les deux tableaux ci-dessous, à confirmer dans le projet avant de lancer quoi que ce soit.

### Défauts par langage

| Langage | Tests | Lint et analyse | Audit des dépendances |
| :-- | :-- | :-- | :-- |
| PHP | `phpunit`, `pest` | `phpcs`, `php-cs-fixer`, `phpstan`, `psalm` | `composer audit --locked` |
| Node / TS | `npm test` (jest, vitest), Playwright | `eslint`, `tsc --noEmit`, `prettier --check` | `npm audit`, `pnpm audit`, `yarn npm audit` |
| Python | `pytest`, `python -m unittest` | `ruff`, `flake8`, `mypy` | `pip-audit` |
| Go | `go test ./...` | `go vet`, `golangci-lint` | `govulncheck ./...` |
| Ruby | `rspec`, `rails test` | `rubocop` | `bundler-audit` |
| Java | `mvn test`, `gradle test` | `checkstyle`, `spotbugs` | OWASP `dependency-check` |
| Rust | `cargo test` | `cargo clippy`, `cargo fmt --check` | `cargo audit` |
| .NET | `dotnet test` | `dotnet format --verify-no-changes` | `dotnet list package --vulnerable` |

### Indices pour les frameworks sans ressource

| Framework | Tests | Contrôles | Pièges |
| :-- | :-- | :-- | :-- |
| Drupal | PHPUnit du cœur (`web/core`), Behat | `phpcs --standard=Drupal,DrupalPractice`, `drush` | métadonnées de cache, `t()`, avis de sécurité (SA) hors packagist |
| WordPress | PHPUnit (suite WP), `wp-env`, WP-CLI | `phpcs --standard=WordPress` | nonces, capacités, échappement, `$wpdb->prepare()` |
| Angular | `ng test`, Cypress | `ng lint`, `tsc` | composants autonomes, désabonnements RxJS |
| Rails | `rails test`, RSpec | `rubocop`, `brakeman` | N+1 Active Record, strong parameters |
| Spring Boot | `mvn test`, `gradle test` | `checkstyle`, `spotbugs` | actuator exposé, profils |

## Ajouter une stack

1. Ajouter la ligne `emit framework <id> …` dans `stacks/detect.sh`, et un `case` de parent si elle dérive d'un autre framework.
2. Créer `stacks/<id>/INDEX.md` avec `## core` et les seules natures utiles.
3. Retirer sa ligne du tableau « Indices » ci-dessus : une seule source par techno.
4. Lancer `sh tests/check.sh`. Aucun skill n'est modifié.

Forme d'une ressource :

| Forme | Contenu | Quand |
| :-- | :-- | :-- |
| 1 | Un `INDEX.md` avec les sections `## core`, `## dev`, `## review`, `## security`, `## test`, `## deploy` | Par défaut |
| 2 | `INDEX.md` qui renvoie vers `CORE.md`, `DEV.md`, `REVIEW.md`, `SECURITY.md`, `TEST.md`, `DEPLOY.md` | Quand une section devient trop longue |

`## core` contient ce qui vaut pour toutes les natures et n'est écrit qu'une fois.
