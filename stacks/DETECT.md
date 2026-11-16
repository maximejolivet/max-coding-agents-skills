# Détection de la stack : procédure commune

Les skills qui dépendent de la techno du projet (`review`, `pr-review`, `security`, `test`, `docker`, `kubernetes`, ainsi que `symfony`, `nuxt`, `react` et les autres) suivent tous **cette même démarche** plutôt que d'avoir la leur. Elle vaut pour toute stack (Symfony, Drupal, WordPress, Laravel, Django, Vue, Nuxt, React, Next.js, Angular, Node, Go…), qu'elle ait ou non une ressource dans `stacks/`.

## 1. Détecter

Se placer à la racine du projet (ou du sous-projet, voir « Monorepo ») et lancer :

```bash
sh "${CLAUDE_SKILL_DIR}/../../stacks/detect.sh"            # racine courante
sh "${CLAUDE_SKILL_DIR}/../../stacks/detect.sh" <dossier>  # un dossier précis
```

Le script lit sans exécuter ni installer quoi que ce soit. Chaque constat est une ligne `catégorie<TAB>identifiant<TAB>preuve` :

| Catégorie         | Ce qu'elle contient                                                      |
| ----------------- | ------------------------------------------------------------------------ |
| `language`        | php, node, typescript, python, go, ruby, rust, java, dotnet              |
| `package-manager` | composer, npm, pnpm, yarn, bun, pip, poetry, uv, pipenv, cargo…          |
| `framework`       | symfony, laravel, drupal, wordpress, nextjs, nuxt, vue, react, angular, svelte, nestjs, express, django, fastapi, flask, rails, spring-boot |
| `parent`          | `nuxt vue`, `nextjs react` : le framework dérivé hérite de son parent    |
| `test`            | phpunit, pest, jest, vitest, playwright, cypress, pytest, go-test, rspec |
| `tooling`         | docker, kubernetes, github-actions, dependabot, pr-template, commitlint  |
| `runner`          | make, docker compose (par ordre de priorité)                             |
| `resource`        | pour chaque framework, le chemin de `stacks/<id>/INDEX.md` ou `aucune`  |

Sans `sh`, refaire la détection à la main d'après le tableau « Signaux de détection » plus bas. Dans tous les cas, **annoncer la stack en une ligne** avant de poursuivre, par exemple : « Stack : Symfony 7 (PHP, composer, PHPUnit), Docker, GitHub Actions ».

## 2. Décider quoi charger

- **Framework avant langage.** Un projet Symfony relève des règles Symfony, pas seulement de « PHP ».
- **Spécifique avant parent.** Nuxt : `stacks/nuxt/` puis `stacks/vue/`. Next.js : `stacks/nextjs/` puis `stacks/react/`. La ressource dérivée complète ou corrige celle du parent.
- **Plusieurs frameworks** (un back Symfony et un front Vue, un thème Drupal avec Node…) : les charger tous, mais n'appliquer à un fichier que les règles de sa propre techno. Pour une revue ou des tests, se fier aux fichiers modifiés.
- **Monorepo.** Quand `apps/`, `packages/` ou `services/` regroupent plusieurs projets, lancer le script dans chaque sous-dossier concerné.
- **Runner.** Prendre la première ligne `runner` (`make`, puis `docker compose`) et passer les commandes du projet par elle.

## 3. Charger la ressource pour la bonne nature

Pour chaque framework dont la ligne `resource` donne un chemin (autre que `aucune`), lire `stacks/<id>/INDEX.md` : la section `## core` plus celle de la **nature** attendue.

| Skill                                      | Nature à charger  |
| ------------------------------------------ | ----------------- |
| `review`, `pr-review`                      | `core` + `review` |
| `security`                                 | `core` + `security` |
| `test`                                     | `core` + `test`   |
| `docker`, `kubernetes`                     | `core` + `deploy` |
| skills de développement (`symfony`, etc.)  | `core` + `dev`    |

Ne jamais lire une ressource dont la ligne `resource` indique `aucune`.

## 4. Repli quand il n'y a pas de ressource

Si un framework n'a pas de ressource (`aucune`) ou que la section voulue manque :

1. **Le signaler** : « pas de resource `<nature>` pour la stack `<id>` - règles génériques et indices ci-dessous uniquement ».
2. **Partir du projet lui-même** : `scripts` de `composer.json` et `package.json`, cibles du `Makefile`, fichiers de configuration (`phpunit.xml.dist`, `eslint.config.*`, `pyproject.toml`, `.github/workflows/`). C'est la référence.
3. **Compléter** par les valeurs par défaut du langage et les indices du framework ci-dessous. Elles sont **indicatives** : les confirmer dans le projet avant de les exécuter.
4. **Ne rien installer ni inventer.** Un outil absent se note « (indispo) ».

### Valeurs par défaut par langage

| Langage   | Tests                                 | Lint / analyse statique                      | Audit des dépendances                       |
| --------- | ------------------------------------- | -------------------------------------------- | ------------------------------------------- |
| PHP       | `phpunit`, `pest`                     | `phpcs`, `php-cs-fixer`, `phpstan`, `psalm`  | `composer audit`                            |
| Node / TS | `npm test` (jest, vitest), Playwright | `eslint`, `tsc --noEmit`, `prettier --check` | `npm audit`, `pnpm audit`, `yarn npm audit` |
| Python    | `pytest`, `python -m unittest`        | `ruff`, `flake8`, `mypy`                     | `pip-audit`                                 |
| Go        | `go test ./...`                       | `go vet`, `golangci-lint`                    | `govulncheck ./...`                         |
| Ruby      | `rspec`, `rails test`                 | `rubocop`                                    | `bundler-audit`                             |
| Java      | `mvn test`, `gradle test`             | `checkstyle`, `spotbugs`                     | OWASP `dependency-check`                    |
| Rust      | `cargo test`                          | `cargo clippy`, `cargo fmt --check`          | `cargo audit`                               |
| .NET      | `dotnet test`                         | `dotnet format --verify-no-changes`          | `dotnet list package --vulnerable`          |

### Indices par framework (à confirmer dans le projet)

| Framework   | Tests                                       | Lint / contrôles                                  | Particularités                                              |
| ----------- | ------------------------------------------- | ------------------------------------------------- | ----------------------------------------------------------- |
| Symfony     | PHPUnit, `WebTestCase`, Panther             | `lint:container`, `phpstan`, `php-cs-fixer`       | ressource complète disponible                               |
| Laravel     | `php artisan test` (Pest / PHPUnit)         | `vendor/bin/pint`, `phpstan` (larastan)           | N+1 Eloquent, `Gate` / policies, files d'attente            |
| Drupal      | PHPUnit du cœur (`web/core`), Behat         | `phpcs --standard=Drupal,DrupalPractice`, `drush` | métadonnées de cache, `t()`, avis de sécurité (SA) hors packagist |
| WordPress   | PHPUnit (suite WP), `wp-env`, WP-CLI        | `phpcs --standard=WordPress`                      | nonces, capacités, échappement, `$wpdb->prepare()`          |
| Nuxt        | Vitest + `@nuxt/test-utils`, Playwright     | `nuxt typecheck`, `eslint`                        | ressource complète ; parent : Vue                           |
| Vue         | Vitest + `@vue/test-utils`                  | `vue-tsc`, `eslint`                               | réactivité, composables, Pinia                              |
| Next.js     | Jest / Vitest + Testing Library, Playwright | `next lint`, `tsc --noEmit`                       | parent : React ; composants serveur / client                |
| React       | Vitest / Jest + Testing Library             | `eslint` (react-hooks), `tsc --noEmit`            | ressource complète disponible                               |
| Angular     | `ng test` (Jasmine / Jest), Cypress         | `ng lint`, `tsc`                                  | composants autonomes, RxJS (désabonnements)                 |
| Django      | `python manage.py test`, `pytest-django`    | `ruff`, `mypy`, `manage.py check --deploy`        | N+1 de l'ORM, migrations, `DEBUG`, `ALLOWED_HOSTS`          |
| Rails       | `rails test`, RSpec                         | `rubocop`, `brakeman`                             | N+1 Active Record, strong parameters                        |
| Spring Boot | `mvn test` / `gradle test`                  | `checkstyle`, `spotbugs`                          | actuator exposé, profils                                    |

## Signaux de détection (ce que cherche `detect.sh`)

| Stack                     | Signaux                                                                                  |
| ------------------------- | ---------------------------------------------------------------------------------------- |
| Symfony                   | `symfony/framework-bundle` dans `composer.json`, ou `bin/console` + `config/bundles.php` |
| Laravel                   | `laravel/framework` dans `composer.json`, ou `artisan`                                   |
| Drupal                    | `drupal/core*` dans `composer.json`, ou `core/lib/Drupal.php` (`web/`, `docroot/`)       |
| WordPress                 | `johnpbloch/wordpress`, `roots/wordpress`, `wpackagist-*`, `wp-config.php`, `wp-content/` |
| Next.js                   | dépendance `next` dans `package.json`                                                    |
| Nuxt                      | dépendance `nuxt`                                                                        |
| Vue                       | dépendance `vue`                                                                         |
| React                     | dépendance `react`                                                                       |
| Angular                   | `@angular/core` dans `package.json`, ou `angular.json`                                   |
| Svelte / NestJS / Express | dépendances `svelte`, `@nestjs/core`, `express`                                          |
| Django                    | `manage.py`, ou `django` dans les dépendances Python                                     |
| FastAPI / Flask           | `fastapi` / `flask` dans les dépendances Python                                          |
| Rails                     | `gem 'rails'` dans `Gemfile`                                                             |
| Spring Boot               | `spring-boot` dans `pom.xml` / `build.gradle*`                                           |

## Ajouter une stack

1. **Détection.** Ajouter dans `stacks/detect.sh` la ligne `emit framework <id> …` (et un `case` de parent si elle dérive d'un autre framework), puis la ligne correspondante du tableau « Signaux ». Essayer avec `sh stacks/detect.sh <dossier>`.
2. **Ressource.** Créer `stacks/<id>/INDEX.md`. Démarrer en Forme 1 : un fichier avec `## core` et uniquement les natures utiles (`## dev`, `## review`, `## security`, `## test`, `## deploy`). Passer en Forme 2, un fichier par nature, quand une section devient trop grosse. `stacks/symfony/INDEX.md` sert de modèle.
3. **Indices.** Supprimer la ligne du tableau « Indices par framework » une fois la ressource complète, afin de garder une seule source de vérité.

Aucun skill n'est à modifier : le script et la ligne `resource` leur font découvrir la nouvelle stack.
