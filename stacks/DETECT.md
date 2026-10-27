# Détection de la stack - procédure commune

Tous les skills qui s'adaptent à la techno du projet (`review`, `pr-review`, `security`, `test`, `docker`, `kubernetes`, et les skills de développement comme `symfony`) suivent **cette procédure**, au lieu d'avoir chacun la leur. Elle s'applique à n'importe quelle stack - Symfony, Drupal, WordPress, Laravel, Django, Vue, Nuxt, React, Next.js, Angular, Node, Go… - qu'elle ait une ressource dans `stacks/` ou non.

## 1. Détecter

Depuis la racine du projet (ou du sous-projet, voir « Monorepo ») :

```bash
sh "${CLAUDE_SKILL_DIR}/../../stacks/detect.sh"          # racine courante
sh "${CLAUDE_SKILL_DIR}/../../stacks/detect.sh" <dossier>
```

Le script est en lecture seule : il ne lance rien et n'installe rien. Il affiche une ligne par constat, `catégorie<TAB>identifiant<TAB>preuve` :

| Catégorie         | Contenu                                                                 |
| ----------------- | ----------------------------------------------------------------------- |
| `language`        | php, node, typescript, python, go, ruby, rust, java, dotnet             |
| `package-manager` | composer, npm, pnpm, yarn, bun, pip, poetry, uv, pipenv, cargo…         |
| `framework`       | symfony, laravel, drupal, wordpress, nextjs, nuxt, vue, react, angular, svelte, nestjs, express, django, fastapi, flask, rails, spring-boot |
| `parent`          | `nuxt vue`, `nextjs react` : le framework dérivé hérite de son parent   |
| `test`            | phpunit, pest, jest, vitest, playwright, cypress, pytest, go-test, rspec |
| `tooling`         | docker, kubernetes, github-actions, dependabot, pr-template, commitlint |
| `runner`          | make, docker compose (dans l'ordre de priorité)                  |
| `resource`        | pour chaque framework : le chemin de `stacks/<id>/INDEX.md`, ou `aucune` |

Si le script ne peut pas tourner (pas de `sh`), faire la même détection à la main avec les fichiers du tableau « Signaux » plus bas. **Annoncer la stack détectée en une ligne** avant de continuer (« Stack : Symfony 7 (PHP, composer, PHPUnit), Docker, GitHub Actions »).

## 2. Choisir quoi charger

- **Le framework prime sur le langage** : un projet Symfony se traite avec les règles Symfony, pas seulement « PHP ».
- **Le plus spécifique d'abord, puis son parent** : pour Nuxt, charger `stacks/nuxt/` puis `stacks/vue/` ; pour Next.js, `stacks/nextjs/` puis `stacks/react/`. La ressource dérivée complète ou corrige celle du parent.
- **Plusieurs frameworks** (ex. un backend Symfony et un front Vue, ou un thème Drupal avec Node) : charger chacun, mais n'appliquer à chaque fichier que les règles de la techno à laquelle il appartient. Pour une revue ou des tests, se guider sur les fichiers modifiés.
- **Monorepo** : si `apps/`, `packages/` ou `services/` contiennent plusieurs projets, lancer le script sur chaque sous-dossier concerné par la tâche.
- **Le runner** est la première ligne `runner` (`make` → `docker compose`) : lancer les commandes du projet à travers lui.

## 3. Charger la ressource, avec la bonne nature

Pour chaque framework, si la ligne `resource` donne un chemin (pas `aucune`), le lire : `stacks/<id>/INDEX.md`. Le fichier lit `## core` plus la section de la **nature** voulue :

| Skill                                    | Nature à charger |
| ---------------------------------------- | ---------------- |
| `review`, `pr-review`                    | `core` + `review` |
| `security`                               | `core` + `security` |
| `test`                                   | `core` + `test`  |
| `docker`, `kubernetes`                   | `core` + `deploy` |
| skills de développement (`symfony`, etc.) | `core` + `dev`   |

Ne jamais `Read` une ressource dont la ligne `resource` dit `aucune`.

## 4. Sans ressource : dégradation propre

Quand un framework n'a pas de ressource (`aucune`) ou que sa section manque :

1. **Le dire** en une phrase : « pas de resource `<nature>` pour la stack `<id>` - règles génériques et indices ci-dessous uniquement ».
2. Utiliser d'abord ce que **le projet déclare lui-même** : `scripts` de `composer.json` et `package.json`, cibles du `Makefile`, fichiers de configuration (`phpunit.xml.dist`, `eslint.config.*`, `pyproject.toml`, `.github/workflows/`). C'est la vérité du projet.
3. Compléter avec les valeurs par défaut du langage et les indices du framework ci-dessous. Elles sont **indicatives** : les confirmer dans le projet avant de les lancer.
4. Ne rien installer, ne rien inventer. Un outil absent se note « (indispo) ».

### Valeurs par défaut par langage

| Langage    | Tests                                  | Lint / analyse statique                   | Audit des dépendances                 |
| ---------- | -------------------------------------- | ----------------------------------------- | ------------------------------------- |
| PHP        | `phpunit`, `pest`                      | `phpcs`, `php-cs-fixer`, `phpstan`, `psalm` | `composer audit`                    |
| Node / TS  | `npm test` (jest, vitest), Playwright  | `eslint`, `tsc --noEmit`, `prettier --check` | `npm audit`, `pnpm audit`, `yarn npm audit` |
| Python     | `pytest`, `python -m unittest`         | `ruff`, `flake8`, `mypy`                  | `pip-audit`                           |
| Go         | `go test ./...`                        | `go vet`, `golangci-lint`                 | `govulncheck ./...`                   |
| Ruby       | `rspec`, `rails test`                  | `rubocop`                                 | `bundler-audit`                       |
| Java       | `mvn test`, `gradle test`              | `checkstyle`, `spotbugs`                  | OWASP `dependency-check`              |
| Rust       | `cargo test`                           | `cargo clippy`, `cargo fmt --check`       | `cargo audit`                         |
| .NET       | `dotnet test`                          | `dotnet format --verify-no-changes`       | `dotnet list package --vulnerable`    |

### Indices par framework (à confirmer dans le projet)

| Framework      | Tests                                        | Lint / contrôles                                  | Particularités                                       |
| -------------- | -------------------------------------------- | ------------------------------------------------- | ---------------------------------------------------- |
| Symfony        | PHPUnit, `WebTestCase`, Panther              | `lint:container`, `phpstan`, `php-cs-fixer`        | a une ressource complète                             |
| Laravel        | `php artisan test` (Pest / PHPUnit)          | `vendor/bin/pint`, `phpstan` (larastan)            | Eloquent N+1, `Gate` / policies, files d'attente     |
| Drupal         | PHPUnit du cœur (`web/core`), Behat          | `phpcs --standard=Drupal,DrupalPractice`, `drush`  | cache metadata, `t()`, avis de sécurité (SA) hors packagist |
| WordPress      | PHPUnit (suite WP), `wp-env`, WP-CLI         | `phpcs --standard=WordPress`                       | nonces, capacités, échappement, `$wpdb->prepare()`    |
| Nuxt           | Vitest + `@nuxt/test-utils`, Playwright      | `nuxt typecheck`, `eslint`                         | a une ressource complète ; parent : Vue              |
| Vue            | Vitest + `@vue/test-utils`                   | `vue-tsc`, `eslint`                                | réactivité, composables, Pinia                       |
| Next.js        | Jest / Vitest + Testing Library, Playwright  | `next lint`, `tsc --noEmit`                        | parent : React ; composants serveur / client         |
| React          | Vitest / Jest + Testing Library              | `eslint` (react-hooks), `tsc --noEmit`             | a une ressource complète                             |
| Angular        | `ng test` (Jasmine / Jest), Cypress          | `ng lint`, `tsc`                                   | modules / composants autonomes, RxJS (désabonnements) |
| Django         | `python manage.py test`, `pytest-django`     | `ruff`, `mypy`, `manage.py check --deploy`         | ORM N+1, migrations, `DEBUG`, `ALLOWED_HOSTS`        |
| Rails          | `rails test`, RSpec                          | `rubocop`, `brakeman`                              | Active Record N+1, strong parameters                 |
| Spring Boot    | `mvn test` / `gradle test`                   | `checkstyle`, `spotbugs`                           | actuator exposé, profils                             |

## Signaux de détection (référence de `detect.sh`)

| Stack      | Signaux                                                                               |
| ---------- | ------------------------------------------------------------------------------------- |
| Symfony    | `symfony/framework-bundle` dans `composer.json`, ou `bin/console` + `config/bundles.php` |
| Laravel    | `laravel/framework` dans `composer.json`, ou `artisan`                                |
| Drupal     | `drupal/core*` dans `composer.json`, ou `core/lib/Drupal.php` (`web/`, `docroot/`)     |
| WordPress  | `johnpbloch/wordpress`, `roots/wordpress`, `wpackagist-*`, `wp-config.php`, `wp-content/` |
| Next.js    | dépendance `next` dans `package.json`                                                 |
| Nuxt       | dépendance `nuxt`                                                                     |
| Vue        | dépendance `vue`                                                                      |
| React      | dépendance `react`                                                                    |
| Angular    | `@angular/core` dans `package.json`, ou `angular.json`                                |
| Svelte / NestJS / Express | dépendances `svelte`, `@nestjs/core`, `express`                       |
| Django     | `manage.py`, ou `django` dans les dépendances Python                                  |
| FastAPI / Flask | `fastapi` / `flask` dans les dépendances Python                                  |
| Rails      | `gem 'rails'` dans `Gemfile`                                                          |
| Spring Boot | `spring-boot` dans `pom.xml` / `build.gradle*`                                       |

## Ajouter une stack

1. **Détection** - ajouter la ligne `emit framework <id> …` correspondante dans `stacks/detect.sh` (et un `case` de parent s'il hérite d'un autre framework), puis la ligne du tableau « Signaux » ci-dessus. Tester sur un dossier d'exemple : `sh stacks/detect.sh <dossier>`.
2. **Ressource** - créer `stacks/<id>/INDEX.md`. Commencer en Forme 1 (un fichier avec `## core`, et seulement les natures utiles parmi `## dev`, `## review`, `## security`, `## test`, `## deploy`). Passer en Forme 2 (un dossier avec un fichier par nature) quand une section grossit. Voir `stacks/symfony/INDEX.md` comme modèle.
3. **Indices** - retirer la ligne du tableau « Indices par framework » une fois la ressource complète, pour garder une seule source de vérité.

Les skills n'ont **rien à modifier** : ils découvrent la nouvelle stack grâce au script et à la ligne `resource`.
