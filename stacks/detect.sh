#!/bin/sh
# Détecte la stack d'un projet à partir de ses fichiers (lecture seule, rien n'est exécuté ni installé).
#
# Usage : sh detect.sh [dossier]      (dossier = racine du projet, "." par défaut)
# Sortie : une ligne par constat, séparée par des tabulations :
#   <catégorie>  <identifiant>  <preuve>
# Catégories : language, framework, package-manager, test, tooling, runner, resource, parent
#
# Pour un monorepo, lancer le script sur chaque sous-dossier (apps/*, packages/*, services/*).

stacks_dir=$(cd "$(dirname "$0")" && pwd)
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "dossier introuvable : $root" >&2; exit 1; }

frameworks=""
emit() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3"
  [ "$1" = framework ] && frameworks="$frameworks $2"
}
# true si le fichier $1 existe et contient l'expression régulière $2
has_dep() { [ -f "$1" ] && grep -qiE "$2" "$1" 2>/dev/null; }
# true si au moins un fichier correspond au motif glob $1
has_glob() { for f in $1; do [ -e "$f" ] && return 0; done; return 1; }

# --- Langages et gestionnaires de paquets -----------------------------------
[ -f composer.json ] && { emit language php composer.json; emit package-manager composer composer.json; }
if [ -f package.json ]; then
  emit language node package.json
  if   [ -f pnpm-lock.yaml ]; then emit package-manager pnpm pnpm-lock.yaml
  elif [ -f yarn.lock ];      then emit package-manager yarn yarn.lock
  elif [ -f bun.lockb ] || [ -f bun.lock ]; then emit package-manager bun bun.lock
  elif [ -f package-lock.json ]; then emit package-manager npm package-lock.json
  else emit package-manager npm package.json; fi
  [ -f tsconfig.json ] && emit language typescript tsconfig.json
fi
py_files=""
for f in pyproject.toml requirements.txt requirements-dev.txt setup.py setup.cfg Pipfile; do [ -f "$f" ] && py_files="$py_files $f"; done
if [ -n "$py_files" ]; then
  emit language python "$(echo $py_files | cut -d' ' -f1)"
  if   [ -f uv.lock ];     then emit package-manager uv uv.lock
  elif [ -f poetry.lock ]; then emit package-manager poetry poetry.lock
  elif [ -f Pipfile ];     then emit package-manager pipenv Pipfile
  else emit package-manager pip "$(echo $py_files | cut -d' ' -f1)"; fi
fi
[ -f go.mod ]     && { emit language go go.mod; emit package-manager go-modules go.mod; }
[ -f Gemfile ]    && { emit language ruby Gemfile; emit package-manager bundler Gemfile; }
[ -f Cargo.toml ] && { emit language rust Cargo.toml; emit package-manager cargo Cargo.toml; }
[ -f pom.xml ]    && { emit language java pom.xml; emit package-manager maven pom.xml; }
if has_glob "build.gradle build.gradle.kts"; then emit language java build.gradle; emit package-manager gradle build.gradle; fi
has_glob "*.csproj *.sln" && emit language dotnet "*.csproj"

# --- Frameworks --------------------------------------------------------------
if has_dep composer.json '"symfony/(framework-bundle|symfony)"' || { [ -f bin/console ] && [ -f config/bundles.php ]; }; then emit framework symfony composer.json; fi
if has_dep composer.json '"laravel/framework"' || [ -f artisan ]; then emit framework laravel composer.json; fi
if has_dep composer.json '"drupal/core' || [ -f core/lib/Drupal.php ] || [ -f web/core/lib/Drupal.php ] || [ -f docroot/core/lib/Drupal.php ]; then emit framework drupal composer.json; fi
if has_dep composer.json '"(johnpbloch/wordpress|roots/wordpress|wpackagist-)' || [ -f wp-config.php ] || [ -d wp-content ]; then emit framework wordpress composer.json; fi

if [ -f package.json ]; then
  has_dep package.json '"next"[[:space:]]*:'         && emit framework nextjs package.json
  has_dep package.json '"nuxt"[[:space:]]*:'         && emit framework nuxt package.json
  has_dep package.json '"vue"[[:space:]]*:'          && emit framework vue package.json
  has_dep package.json '"react"[[:space:]]*:'        && emit framework react package.json
  { has_dep package.json '"@angular/core"' || [ -f angular.json ]; } && emit framework angular package.json
  has_dep package.json '"svelte"[[:space:]]*:'       && emit framework svelte package.json
  has_dep package.json '"@nestjs/core"'              && emit framework nestjs package.json
  has_dep package.json '"express"[[:space:]]*:'      && emit framework express package.json
fi

if [ -n "$py_files" ]; then
  # shellcheck disable=SC2086
  if [ -f manage.py ] || grep -qiE '^[[:space:]"]*django([^a-z-]|$)' $py_files 2>/dev/null;  then emit framework django $py_files; fi
  if grep -qiE '^[[:space:]"]*fastapi([^a-z-]|$)' $py_files 2>/dev/null; then emit framework fastapi $py_files; fi
  if grep -qiE '^[[:space:]"]*flask([^a-z-]|$)'   $py_files 2>/dev/null; then emit framework flask $py_files; fi
fi
has_dep Gemfile '^[[:space:]]*gem[[:space:]]+.rails.' && emit framework rails Gemfile
if has_dep pom.xml 'spring-boot' || has_dep build.gradle 'spring-boot' || has_dep build.gradle.kts 'spring-boot'; then emit framework spring-boot pom.xml; fi

# --- Outils de test ----------------------------------------------------------
has_glob "phpunit.xml phpunit.xml.dist" && emit test phpunit phpunit.xml
has_dep composer.json '"pestphp/pest"' && emit test pest composer.json
has_glob "jest.config.js jest.config.ts jest.config.mjs jest.config.cjs" && emit test jest jest.config.*
has_dep package.json '"jest"[[:space:]]*:' && emit test jest package.json
has_glob "vitest.config.ts vitest.config.js vitest.config.mts" && emit test vitest vitest.config.*
has_dep package.json '"vitest"[[:space:]]*:' && emit test vitest package.json
has_dep package.json '"@playwright/test"' && emit test playwright package.json
has_dep package.json '"cypress"[[:space:]]*:' && emit test cypress package.json
if [ -f pytest.ini ] || has_dep pyproject.toml 'pytest' || has_dep requirements.txt 'pytest' || has_dep requirements-dev.txt 'pytest'; then emit test pytest pytest.ini; fi
has_glob "*_test.go" && emit test go-test "*_test.go"
[ -d spec ] && [ -f Gemfile ] && emit test rspec spec/

# --- Outillage, CI et déploiement -------------------------------------------
has_glob "Dockerfile Dockerfile.* docker-compose.yml docker-compose.yaml compose.yml compose.yaml" && emit tooling docker Dockerfile
has_glob "Chart.yaml kustomization.yaml kustomization.yml" && emit tooling kubernetes Chart.yaml
for d in k8s kubernetes helm charts deploy manifests; do [ -d "$d" ] && { emit tooling kubernetes "$d/"; break; }; done
[ -d .github/workflows ] && emit tooling github-actions .github/workflows
[ -f .github/dependabot.yml ] && emit tooling dependabot .github/dependabot.yml
[ -f .github/pull_request_template.md ] && emit tooling pr-template .github/pull_request_template.md
[ -f commitlint.config.js ] && emit tooling commitlint commitlint.config.js

# --- Runner (ordre de priorité : make, docker compose) ----------------
[ -f Makefile ] && emit runner make Makefile
has_glob "docker-compose.yml docker-compose.yaml compose.yml compose.yaml" && emit runner "docker compose" compose

# --- Parents : un framework dérivé hérite des règles de son parent ------------
# (ex. Nuxt s'appuie sur Vue, Next.js sur React) : on charge le plus spécifique, puis son parent.
for id in $frameworks; do
  case "$id" in
    nuxt)   printf 'parent\tnuxt\tvue\n' ;;
    nextjs) printf 'parent\tnextjs\treact\n' ;;
  esac
done

# --- Ressources de stack disponibles dans le plugin -------------------------
# Pour chaque framework détecté, indique si stacks/<id>/INDEX.md existe.
all_ids="$frameworks"
for id in $frameworks; do
  case "$id" in nuxt) all_ids="$all_ids vue" ;; nextjs) all_ids="$all_ids react" ;; esac
done
seen=""
for id in $all_ids; do
  case " $seen " in *" $id "*) continue ;; esac
  seen="$seen $id"
  if [ -f "$stacks_dir/$id/INDEX.md" ] && [ -s "$stacks_dir/$id/INDEX.md" ]; then
    emit resource "$id" "$stacks_dir/$id/INDEX.md"
  else
    emit resource "$id" "aucune"
  fi
done
