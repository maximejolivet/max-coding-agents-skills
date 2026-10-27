#!/bin/sh
# Contrôle de cohérence du plugin (lecture seule, aucun réseau).
#
# Usage : sh tests/check.sh
# Code de sortie : 0 si tout passe, 1 s'il y a au moins un échec.
#
# Vérifie : frontmatter des skills et des agents, références croisées (max:<nom>,
# stacks/<id>/INDEX.md), versions alignées, mots interdits, et le script de
# détection de stack sur des projets factices créés dans un dossier temporaire.

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 1

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
ko()  { printf '  ECHEC %s\n' "$1"; fail=1; }
section() { printf '\n%s\n' "$1"; }

# valeur d'un champ de frontmatter (première occurrence, entre les deux ---)
fm() { awk -v k="$2" 'NR==1&&$0!="---"{exit} /^---$/{n++; next} n==1 && $0 ~ "^"k":"{sub("^"k":[ ]*",""); gsub(/^"|"$/,""); print; exit}' "$1"; }

section "Skills : frontmatter"
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(fm "$f" name); desc=$(fm "$f" description)
  [ "$name" = "$dir" ] && [ -n "$desc" ] && ok "$dir" || ko "$f : name '$name' != dossier '$dir' ou description vide"
done

section "Agents : frontmatter"
for f in agents/*.md; do
  base=$(basename "$f" .md)
  name=$(fm "$f" name); desc=$(fm "$f" description); tools=$(fm "$f" tools)
  if [ "$name" = "$base" ] && [ -n "$desc" ] && [ -n "$tools" ]; then ok "$base"; else ko "$f : name, description ou tools invalide"; fi
  case "$tools" in *Write*|*Edit*|*NotebookEdit*) ko "$base : un agent doit rester en lecture seule (outil d'écriture déclaré)";; esac
done

section "Références max:<nom>"
known=$( { ls skills; for f in agents/*.md; do basename "$f" .md; done; } | sort -u)
refs=$(grep -rhoE 'max:[a-z][a-z-]*' skills agents stacks README.md CLAUDE.md .claude-plugin 2>/dev/null | sort -u | sed 's/^max://')
for r in $refs; do
  case "$r" in review|pr-review|security|test|docker|kubernetes|commit|pull-request|symfony|nuxt|react) ;; esac
  echo "$known" | grep -qx "$r" && ok "max:$r" || ko "max:$r est référencé mais n'existe ni comme skill ni comme agent"
done

section "Références stacks/<id>/INDEX.md"
# Parents facultatifs, cités avec « s'il existe » : leur absence n'est pas une erreur.
optional_stacks="nextjs vue"
for p in $(grep -rhoE 'stacks/[a-z][a-z0-9-]*/INDEX\.md' skills agents stacks README.md CLAUDE.md 2>/dev/null | sort -u); do
  id=$(echo "$p" | cut -d/ -f2)
  if [ -s "$p" ]; then ok "$p"
  elif echo " $optional_stacks " | grep -q " $id "; then ok "$p (parent facultatif, absent)"
  else ko "$p est référencé mais absent ou vide"; fi
done

section "Versions alignées"
v1=$(grep -m1 '"version"' .claude-plugin/plugin.json | sed 's/.*: *"\(.*\)".*/\1/')
v2=$(grep -m1 '"version"' .claude-plugin/marketplace.json | sed 's/.*: *"\(.*\)".*/\1/')
[ "$v1" = "$v2" ] && ok "plugin.json = marketplace.json = $v1" || ko "plugin.json ($v1) != marketplace.json ($v2)"

section "Skills déclarés dans marketplace.json et README"
for d in skills/*/; do
  n=$(basename "$d")
  grep -q "/max:$n" .claude-plugin/marketplace.json && ok "marketplace : $n" || ko "marketplace.json ne cite pas /max:$n"
  grep -q "/max:$n" README.md && ok "README : $n" || ko "README.md ne cite pas /max:$n"
done

section "Mots interdits (traces d'anciens contextes)"
hits=$(grep -rniE 'lando|gingerminds|gitlab|glab|mantis' skills agents stacks README.md CLAUDE.md .claude-plugin .github 2>/dev/null | grep -v '^tests/' | head -5)
[ -z "$hits" ] && ok "aucune occurrence" || { ko "mots interdits trouvés :"; echo "$hits"; }

section "Détection de stack (projets factices)"
tmp=$(mktemp -d 2>/dev/null || echo "/tmp/check-$$"); mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT
mk() { mkdir -p "$tmp/$1"; }
expect() { # expect <dossier> <catégorie> <id>
  out=$(sh stacks/detect.sh "$tmp/$1")
  printf '%s\n' "$out" | grep -q "^$2	$3	" && ok "$1 -> $2 $3" || ko "$1 : '$2 $3' non détecté"
}
mk sym/bin; mk sym/config
printf '{"require":{"symfony/framework-bundle":"^7.4"}}' > "$tmp/sym/composer.json"; : > "$tmp/sym/bin/console"; : > "$tmp/sym/config/bundles.php"; : > "$tmp/sym/phpunit.xml.dist"
expect sym language php; expect sym framework symfony; expect sym test phpunit; expect sym resource symfony
mk nuxt; printf '{"dependencies":{"nuxt":"4","vue":"3"}}' > "$tmp/nuxt/package.json"
expect nuxt framework nuxt; expect nuxt parent nuxt; expect nuxt resource nuxt
mk react; printf '{"dependencies":{"react":"19"},"devDependencies":{"vitest":"2"}}' > "$tmp/react/package.json"; : > "$tmp/react/pnpm-lock.yaml"
expect react framework react; expect react package-manager pnpm; expect react test vitest; expect react resource react
mk next; printf '{"dependencies":{"next":"15","react":"19"}}' > "$tmp/next/package.json"
expect next framework nextjs; expect next parent nextjs
mk dj; printf 'django>=5\npytest\n' > "$tmp/dj/requirements.txt"; : > "$tmp/dj/manage.py"
expect dj framework django; expect dj test pytest
mk wp; : > "$tmp/wp/wp-config.php"; expect wp framework wordpress
mk dr/web/core/lib; : > "$tmp/dr/web/core/lib/Drupal.php"; expect dr framework drupal
mk ng; printf '{"dependencies":{"@angular/core":"19"}}' > "$tmp/ng/package.json"; expect ng framework angular
mk empty
[ -z "$(sh stacks/detect.sh "$tmp/empty")" ] && ok "dossier vide -> aucune détection" || ko "dossier vide : détection inattendue"

printf '\n'
if [ "$fail" -eq 0 ]; then echo "Tout est cohérent."; else echo "Des contrôles ont échoué."; fi
exit "$fail"
