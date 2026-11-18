#!/bin/sh
# Contrôle de cohérence du plugin (lecture seule, aucun réseau).
#
# Usage : sh tests/check.sh [-q|--quiet]
#   -q, --quiet   n'affiche que les échecs, les contrôles ignorés et le bilan
# Code de sortie : 0 si tout passe, 1 s'il y a au moins un échec, 2 si l'usage est faux.
#
# Vérifie : fichiers attendus, manifestes et versions, skills, agents, références
# croisées, stacks, scripts, garde-fou git, workflows, hygiène du dépôt, et le script
# de détection de stack sur des projets factices créés dans un dossier temporaire.
#
# Un contrôle dont l'outil manque (python3, shellcheck, git) est compté comme ignoré,
# jamais comme passé.

# Le motif « [ test ]; verdict "message" $? » est voulu dans tout le fichier.
# shellcheck disable=SC2319

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 1

quiet=0
case "${1:-}" in
  '') ;;
  -q|--quiet) quiet=1 ;;
  *) echo "usage : sh tests/check.sh [-q|--quiet]" >&2; exit 2 ;;
esac

tmp=$(mktemp -d) || { echo "impossible de créer un dossier temporaire" >&2; exit 1; }
trap 'rm -rf "$tmp"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

tab=$(printf '\t')
passed=0; failed=0; skipped=0
current=""; shown=1

section() {
  current=$1; shown=0
  [ "$quiet" -eq 1 ] || show_section
}
show_section() {
  [ "$shown" -eq 1 ] && return 0
  printf '\n%s\n' "$current"; shown=1
}
ok()   { passed=$((passed + 1)); [ "$quiet" -eq 1 ] || printf '  ok     %s\n' "$1"; }
ko()   { failed=$((failed + 1)); show_section; printf '  ECHEC  %s\n' "$1"; }
skip() { skipped=$((skipped + 1)); show_section; printf '  IGNORE %s\n' "$1"; }
# verdict <message> <code de retour du test précédent>
verdict() { if [ "$2" -eq 0 ]; then ok "$1"; else ko "$1"; fi; }

have() { command -v "$1" >/dev/null 2>&1; }

# --- Lecture des fichiers Markdown -------------------------------------------

# fm_raw <fichier> <champ> : valeur brute d'un champ du frontmatter
fm_raw() {
  awk -v k="$2" 'NR==1 && $0!="---"{exit} /^---$/{n++; if(n==2) exit; next}
    n==1 && index($0, k":")==1 {sub("^"k":[ ]*",""); print; exit}' "$1"
}
# fm <fichier> <champ> : valeur sans ses guillemets
fm() { fm_raw "$1" "$2" | sed 's/^"//; s/"$//'; }
# fm_closed <fichier> : le frontmatter commence en ligne 1 et se referme
fm_closed() {
  [ "$(sed -n 1p "$1")" = "---" ] && [ "$(grep -c '^---$' "$1")" -ge 2 ]
}
# fm_yaml_ok <fichier> : aucune valeur ne casse le YAML du frontmatter
fm_yaml_ok() {
  awk 'NR==1{next} /^---$/{exit} {print}' "$1" > "$tmp/fm"
  while IFS= read -r line; do
    value=${line#*:}; value=${value# }
    case "$value" in
      \"*\") inner=${value#\"}; inner=${inner%\"}
             case "$inner" in *\"*) return 1 ;; esac ;;
      \"*|*\") return 1 ;;
      *": "*|*" #"*) return 1 ;;
    esac
  done < "$tmp/fm"
  return 0
}
# headings <fichier> : titres de niveau 2 hors blocs de code, sans suffixe « : … »
headings() {
  awk '/^[ ]*```/{c=!c; next} !c && /^## /{sub(/^## /,""); sub(/ :.*/,""); print}' "$1"
}
# body_of <fichier> <titre> : contenu d'une section de niveau 2
body_of() {
  awk -v h="## $2" '/^[ ]*```/{c=!c} !c && /^## /{p=($0==h); next} p' "$1"
}

# --- Fichiers attendus -------------------------------------------------------

section "Fichiers attendus"
for f in README.md CLAUDE.md CONTRIBUTING.md LICENSE \
         .claude-plugin/plugin.json .claude-plugin/marketplace.json \
         .github/workflows/check.yml .github/pull_request_template.md \
         docs/skill-anatomy.md docs/agents.md references/regles.md \
         hooks/hooks.json scripts/guard-git.sh \
         stacks/DETECT.md stacks/detect.sh tests/SCENARIOS.md; do
  if [ -s "$f" ]; then ok "$f"; else ko "$f : absent ou vide"; fi
done

# --- Manifestes --------------------------------------------------------------

section "JSON valides"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json renovate.json; do
  [ -f "$f" ] || { ko "$f : absent"; continue; }
  if have python3; then
    python3 -c 'import json,sys; json.load(open(sys.argv[1],encoding="utf-8"))' "$f" 2>/dev/null
    verdict "$f" $?
  elif have jq; then
    jq empty "$f" >/dev/null 2>&1
    verdict "$f" $?
  else
    skip "$f : ni python3 ni jq"
  fi
done

section "Identité du plugin"
n1=$(grep -m1 '"name"' .claude-plugin/plugin.json | sed 's/.*: *"\(.*\)".*/\1/')
[ "$n1" = "max" ]; verdict "plugin.json : name = max" $?
grep -q '"name": "max"' .claude-plugin/marketplace.json; verdict "marketplace.json : name = max" $?
grep -q '"source": "./"' .claude-plugin/marketplace.json; verdict "marketplace.json : source = ./" $?

section "Versions alignées"
v_plugin=$(grep -m1 '"version"' .claude-plugin/plugin.json | sed 's/.*: *"\(.*\)".*/\1/')
v_market=$(grep -m1 '"version"' .claude-plugin/marketplace.json | sed 's/.*: *"\(.*\)".*/\1/')
v_badge=$(sed -n 's/.*badge\/version-\([0-9][0-9.]*\)-.*/\1/p' README.md | head -1)
v_claude=$(sed -n 's/.*Version courante : `\([^`]*\)`.*/\1/p' CLAUDE.md | head -1)
if printf '%s\n' "$v_plugin" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then ok "format x.y.z : $v_plugin"
else ko "plugin.json : version '$v_plugin' hors du format x.y.z"; fi
[ "$v_market" = "$v_plugin" ]; verdict "marketplace.json = $v_market" $?
[ "$v_badge" = "$v_plugin" ];  verdict "badge du README = $v_badge" $?
[ "$v_claude" = "$v_plugin" ]; verdict "CLAUDE.md = $v_claude" $?

section "Inventaire annoncé par le README"
nb_skills=$(find skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
nb_agents=$(find agents -mindepth 1 -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
a_skills=$(sed -n 's/.*réunit \([0-9][0-9]*\) skills.*/\1/p' README.md | head -1)
a_agents=$(sed -n 's/.*réunit [0-9][0-9]* skills, \([0-9][0-9]*\) sous-agents.*/\1/p' README.md | head -1)
[ "$a_skills" = "$nb_skills" ]; verdict "skills : README '$a_skills', dépôt $nb_skills" $?
[ "$a_agents" = "$nb_agents" ]; verdict "sous-agents : README '$a_agents', dépôt $nb_agents" $?

# --- Skills ------------------------------------------------------------------

expected_plan="Préalables|Étapes|Points d'arrêt|Ce qu'il ne fait pas|"
resolve_line='Racine de Max, notée `<max>` : lancer `(cd -P "<dossier de ce SKILL.md>/../.." && pwd)`.'

section "Skills : frontmatter"
for d in skills/*/; do
  dir=$(basename "$d"); f="${d}SKILL.md"
  [ -f "$f" ] || { ko "$dir : SKILL.md absent"; continue; }
  errs=""
  fm_closed "$f" || errs="$errs, frontmatter absent ou non refermé"
  fm_yaml_ok "$f" || errs="$errs, valeur YAML à mettre entre guillemets"
  name=$(fm "$f" name); desc=$(fm "$f" description)
  [ "$name" = "$dir" ] || errs="$errs, name '$name' différent du dossier"
  printf '%s\n' "$dir" | grep -Eq '^[a-z][a-z0-9-]*$' || errs="$errs, nom de dossier invalide"
  [ -n "$desc" ] || errs="$errs, description vide"
  case "$desc" in *"<"*|*">"*) errs="$errs, chevrons dans la description" ;; esac
  case "$desc" in *"/max:$dir"*) ;; *) errs="$errs, description sans /max:$dir" ;; esac
  case "$desc" in *"À utiliser"*) ;; *) errs="$errs, description sans « À utiliser »" ;; esac
  [ "$(printf '%s' "$desc" | wc -m)" -le 1536 ] || errs="$errs, description de plus de 1536 caractères"
  if [ -z "$errs" ]; then ok "$dir"; else ko "$dir :${errs#,}"; fi
done

section "Skills : plan du corps"
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  errs=""
  plan=$(headings "$f" | tr '\n' '|')
  case "$plan" in
    "$expected_plan"|"${expected_plan}Annexe|") ;;
    *) errs="$errs, plan '$plan'" ;;
  esac
  h1=$(awk '/^[ ]*```/{c=!c; next} !c && /^# /{n++} END{print n+0}' "$f")
  [ "$h1" -eq 1 ] || errs="$errs, $h1 titres de niveau 1"
  body_of "$f" "Étapes" | grep -q '^1\. ' || errs="$errs, Étapes non numérotées"
  body_of "$f" "Points d'arrêt" | grep -q '^- ' || errs="$errs, Points d'arrêt vides"
  body_of "$f" "Ce qu'il ne fait pas" | grep -q '^- ' || errs="$errs, section Ce qu'il ne fait pas vide"
  if [ -z "$errs" ]; then ok "$dir"; else ko "$dir :${errs#,}"; fi
done

section "Skills : chemins portables et règles communes"
for f in skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  errs=""
  grep -q 'CLAUDE_SKILL_DIR' "$f" && errs="$errs, CLAUDE_SKILL_DIR ne fonctionne pas sur Codex"
  first=$(body_of "$f" "Préalables" | grep -v '^[[:space:]]*$' | head -1)
  [ "$first" = "$resolve_line" ] || errs="$errs, la première ligne des préalables ne résout pas <max>"
  body_of "$f" "Préalables" | grep -qF '<max>/references/regles.md' || errs="$errs, regles.md non lu dans les préalables"
  if [ -z "$errs" ]; then ok "$dir"; else ko "$dir :${errs#,}"; fi
done

section "Skills : déclarés partout"
for d in skills/*/; do
  n=$(basename "$d"); errs=""
  for target in .claude-plugin/marketplace.json README.md tests/SCENARIOS.md; do
    grep -Eq "/max:$n([^a-z0-9-]|$)" "$target" || errs="$errs, absent de $target"
  done
  if [ -z "$errs" ]; then ok "$n"; else ko "/max:$n :${errs#,}"; fi
done

# --- Agents ------------------------------------------------------------------

section "Agents : frontmatter et lecture seule"
for f in agents/*.md; do
  base=$(basename "$f" .md); errs=""
  fm_closed "$f" || errs="$errs, frontmatter absent ou non refermé"
  fm_yaml_ok "$f" || errs="$errs, valeur YAML à mettre entre guillemets"
  name=$(fm "$f" name); desc=$(fm "$f" description); tools=$(fm "$f" tools); model=$(fm "$f" model)
  [ "$name" = "$base" ] || errs="$errs, name '$name' différent du fichier"
  [ -n "$desc" ] || errs="$errs, description vide"
  [ -n "$tools" ] || errs="$errs, tools vide"
  for tool in $(printf '%s' "$tools" | tr ',' ' '); do
    case "$tool" in
      Read|Grep|Glob|Bash|WebFetch|WebSearch) ;;
      *) errs="$errs, outil '$tool' interdit à un agent en lecture seule" ;;
    esac
  done
  case "$model" in ''|sonnet|opus|haiku|fable|inherit) ;; *) errs="$errs, model '$model' inconnu" ;; esac
  if [ -z "$errs" ]; then ok "$base"; else ko "$base :${errs#,}"; fi
done

section "Agents : plan du corps et déclaration"
for f in agents/*.md; do
  base=$(basename "$f" .md); errs=""
  plan=$(headings "$f" | tr '\n' '|')
  case "$plan" in
    "Entrée|Étapes|Contrôles|Sortie|Limites|"|"Entrée|Étapes|Sortie|Limites|") ;;
    *) errs="$errs, plan '$plan'" ;;
  esac
  grep -Eq 'max:[a-z]' "$f" && errs="$errs, un agent n'en lance aucun autre"
  grep -q "$base" docs/agents.md || errs="$errs, absent de docs/agents.md"
  grep -q "$base" README.md || errs="$errs, absent du README"
  if [ -z "$errs" ]; then ok "$base"; else ko "$base :${errs#,}"; fi
done

# --- Références croisées -----------------------------------------------------

doc_sources="skills agents stacks references docs README.md CLAUDE.md CONTRIBUTING.md tests/SCENARIOS.md .claude-plugin .github"

section "Références max:<nom>"
known=$( { ls skills; for f in agents/*.md; do basename "$f" .md; done; } | sort -u)
# shellcheck disable=SC2086
refs=$(grep -rhoE 'max:[a-z][a-z0-9-]*' $doc_sources 2>/dev/null | sed 's/^max://' | sort -u)
for r in $refs; do
  if printf '%s\n' "$known" | grep -qx "$r"; then ok "max:$r"
  else ko "max:$r est cité mais n'existe ni comme skill ni comme agent"; fi
done

section "Références <max>/chemin"
# shellcheck disable=SC2086
grep -rhoE '<max>/[A-Za-z0-9_./-]+' $doc_sources 2>/dev/null | sed 's/^<max>\///; s/[./]*$//' | sort -u > "$tmp/paths"
while IFS= read -r p; do
  [ -n "$p" ] || continue
  if [ -e "$p" ]; then ok "<max>/$p"; else ko "<max>/$p est cité mais absent"; fi
done < "$tmp/paths"

section "Références stacks/<id>/INDEX.md"
# shellcheck disable=SC2086
for p in $(grep -rhoE 'stacks/[a-z][a-z0-9-]*/INDEX\.md' $doc_sources 2>/dev/null | sort -u); do
  if [ -s "$p" ]; then ok "$p"; else ko "$p est cité mais absent ou vide"; fi
done

section "Références : fichiers de references/ utilisés"
for f in references/*.md; do
  n=$(basename "$f")
  if grep -rqF "references/$n" skills agents; then ok "$n"; else ko "$f n'est cité par aucun skill ni agent"; fi
done

section "Liens Markdown relatifs"
: > "$tmp/links"
for f in README.md CLAUDE.md CONTRIBUTING.md docs/*.md tests/SCENARIOS.md .github/pull_request_template.md; do
  [ -f "$f" ] || continue
  awk '/^[ ]*```/{c=!c; next} !c' "$f" | grep -oE '\]\([^)[:space:]]+' | sed 's/^](//; s/#.*$//' \
    | grep -vE '^($|https?:|mailto:|<)' | sed "s|^|$f$tab|" >> "$tmp/links"
done
if [ -s "$tmp/links" ]; then
  while IFS="$tab" read -r src link; do
    if [ -e "$(dirname "$src")/$link" ]; then ok "$src -> $link"; else ko "$src : lien cassé vers $link"; fi
  done < "$tmp/links"
else
  ok "aucun lien relatif"
fi

# --- Stacks ------------------------------------------------------------------

section "Stacks : ressources"
for d in stacks/*/; do
  id=$(basename "$d"); f="${d}INDEX.md"; errs=""
  [ -s "$f" ] || { ko "$id : INDEX.md absent ou vide"; continue; }
  plan=$(headings "$f")
  if ! printf '%s\n' "$plan" | grep -qx 'core' && [ ! -s "${d}CORE.md" ]; then errs="$errs, ni ## core ni CORE.md"; fi
  for h in $plan; do
    case "$h" in core|dev|review|security|test|deploy) ;; *) errs="$errs, section '$h' inconnue" ;; esac
  done
  grep -Eq "emit framework $id( |$)" stacks/detect.sh || errs="$errs, jamais détecté par detect.sh"
  grep -iq "^| $id |" stacks/DETECT.md && errs="$errs, encore listé dans les indices de DETECT.md"
  if [ -z "$errs" ]; then ok "$id"; else ko "$id :${errs#,}"; fi
done

section "Stacks : DETECT.md et detect.sh alignés"
fw_line=$(grep -m1 '^| `framework` |' stacks/DETECT.md)
for id in $(grep -oE 'emit framework [a-z-]+' stacks/detect.sh | awk '{print $3}' | sort -u); do
  case "$fw_line" in
    *" $id,"*|*" $id |"*) ok "framework $id" ;;
    *) ko "framework $id : émis par detect.sh mais absent de DETECT.md" ;;
  esac
done

section "Stacks : natures chargées par les skills"
body_of stacks/DETECT.md "Nature chargée par chaque skill" | grep '^| `' > "$tmp/natures"
for n in $(cut -d'|' -f2 "$tmp/natures" | grep -oE '`[a-z0-9-]+`' | tr -d '`'); do
  if [ -f "skills/$n/SKILL.md" ]; then ok "tableau : $n"; else ko "DETECT.md cite le skill '$n', qui n'existe pas"; fi
done
for f in skills/*/SKILL.md; do
  n=$(basename "$(dirname "$f")")
  for nature in $(grep -oE 'nature \*\*[a-z]+\*\*' "$f" | sed 's/.*\*\*\([a-z]*\)\*\*/\1/' | sort -u); do
    row=$(grep -F "\`$n\`" "$tmp/natures" | cut -d'|' -f3)
    case "$row" in
      *"\`$nature\`"*) ok "$n : nature $nature" ;;
      *) ko "$n : nature '$nature' absente de sa ligne dans DETECT.md" ;;
    esac
  done
done

# --- Scripts -----------------------------------------------------------------

section "Scripts shell"
for f in scripts/*.sh stacks/detect.sh tests/check.sh; do
  errs=""
  [ "$(sed -n 1p "$f")" = "#!/bin/sh" ] || errs="$errs, shebang différent de #!/bin/sh"
  sh -n "$f" 2>/dev/null || errs="$errs, erreur de syntaxe"
  if [ -z "$errs" ]; then ok "$f"; else ko "$f :${errs#,}"; fi
done
if have shellcheck; then
  for f in scripts/*.sh stacks/detect.sh tests/check.sh; do
    shellcheck -S warning "$f" >/dev/null 2>&1
    verdict "shellcheck : $f" $?
  done
else
  skip "shellcheck non installé"
fi

section "Hooks"
hook_cmds=$(sed -n 's/.*"command": *"\${CLAUDE_PLUGIN_ROOT}\/\([^"]*\)".*/\1/p' hooks/hooks.json)
if [ -n "$hook_cmds" ]; then
  for c in $hook_cmds; do
    if [ -x "$c" ]; then ok "$c existe et est exécutable"; else ko "$c : absent ou non exécutable"; fi
  done
else
  ko "hooks/hooks.json ne déclare aucune commande sous \${CLAUDE_PLUGIN_ROOT}"
fi

section "Garde-fou git"
# guard <code attendu> <commande>
guard() {
  got=$(CMD="$2" python3 -c 'import json,os; print(json.dumps({"tool_input":{"command":os.environ["CMD"]}}))' \
    | sh scripts/guard-git.sh >/dev/null 2>&1; echo $?)
  if [ "$got" = "$1" ]; then ok "[$1] $2"; else ko "'$2' : sortie $got, attendu $1"; fi
}
if have python3; then
  guard 2 'git push --force'
  guard 2 'git push -f origin feat/essai'
  guard 2 'git push origin feat/essai --force'
  guard 2 'git push -uf origin feat/essai'
  guard 2 'git push origin main'
  guard 2 'git push origin master'
  guard 2 'git push origin HEAD:main'
  guard 2 'git add . && git push origin main'
  guard 0 'git push --force-with-lease origin feat/essai'
  guard 0 'git push origin feat/essai'
  guard 0 'git push -u origin feat/main'
  guard 0 'git push origin fix/master-page'
  guard 0 'git push origin feat/essai && git log -f'
  guard 0 'git status'
  guard 0 'ls -f main'
  got=$(printf 'pas du json' | sh scripts/guard-git.sh >/dev/null 2>&1; echo $?)
  [ "$got" = "0" ]; verdict "[0] entrée illisible : laisse passer" $?
else
  skip "python3 absent : le garde-fou n'est pas exercé"
fi

# --- Workflows ---------------------------------------------------------------

section "Workflows GitHub Actions"
for f in .github/workflows/*.yml; do
  errs=""
  grep -Eq '^permissions:' "$f" || errs="$errs, permissions non déclarées"
  grep -E '^[[:space:]]*(- )?uses:' "$f" | sed 's/.*uses:[[:space:]]*//' > "$tmp/uses"
  while IFS= read -r u; do
    case "$u" in ./*) continue ;; esac
    printf '%s\n' "$u" | grep -Eq '@[0-9a-f]{40}([[:space:]]|$)' || errs="$errs, action non épinglée : $u"
  done < "$tmp/uses"
  if [ -z "$errs" ]; then ok "$f"; else ko "$f :${errs#,}"; fi
done
grep -q 'sh tests/check.sh' .github/workflows/check.yml; verdict "la CI lance tests/check.sh" $?

# --- Hygiène du dépôt --------------------------------------------------------

section "Hygiène des fichiers suivis"
if have git && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git ls-files > "$tmp/tracked"
  : > "$tmp/bad_names"; : > "$tmp/crlf"; : > "$tmp/conflicts"; : > "$tmp/secrets"; : > "$tmp/fences"; : > "$tmp/utf8"
  cr=$(printf '\r')
  secret_re='ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{10,}|sk-[A-Za-z0-9]{32,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY'
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in
      .DS_Store|Thumbs.db|.env|.env.*|*.pem|*.key|*.orig|*.rej|*.swp) echo "$f" >> "$tmp/bad_names" ;;
    esac
    grep -q "$cr" "$f" 2>/dev/null && echo "$f" >> "$tmp/crlf"
    grep -nE '^(<<<<<<<|>>>>>>>) |^=======$' "$f" 2>/dev/null | cut -d: -f1 | sed "s|^|$f:|" >> "$tmp/conflicts"
    # Seuls le fichier et la ligne sont relevés : la valeur d'un secret n'est jamais affichée.
    grep -nE "$secret_re" "$f" 2>/dev/null | cut -d: -f1 | sed "s|^|$f:|" >> "$tmp/secrets"
    if have iconv; then iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1 || echo "$f" >> "$tmp/utf8"; fi
    case "$f" in
      *.md) [ $(($(grep -c '^[ ]*```' "$f") % 2)) -eq 0 ] || echo "$f" >> "$tmp/fences" ;;
    esac
  done < "$tmp/tracked"
  report() { # report <fichier de constats> <libellé>
    if [ -s "$1" ]; then ko "$2 : $(head -5 "$1" | tr '\n' ' ')"; else ok "$2 : aucun"; fi
  }
  report "$tmp/bad_names" "fichiers à ne pas versionner"
  report "$tmp/crlf"      "fins de ligne CRLF"
  report "$tmp/conflicts" "marqueurs de conflit"
  report "$tmp/secrets"   "secrets probables"
  report "$tmp/fences"    "blocs de code non refermés"
  if have iconv; then report "$tmp/utf8" "fichiers hors UTF-8"; else skip "iconv absent : encodage non contrôlé"; fi
else
  skip "git indisponible : hygiène des fichiers non contrôlée"
fi

# --- Détection de stack ------------------------------------------------------

section "Détection de stack (projets factices)"
mk()  { mkdir -p "$tmp/p/$1"; }
put() { mkdir -p "$(dirname "$tmp/p/$1")"; printf '%s' "$2" > "$tmp/p/$1"; }
expect() { # expect <dossier> <catégorie> <id>
  if sh stacks/detect.sh "$tmp/p/$1" | grep -q "^$2$tab$3$tab"; then ok "$1 -> $2 $3"
  else ko "$1 : '$2 $3' non détecté"; fi
}
refute() { # refute <dossier> <catégorie> <id>
  if sh stacks/detect.sh "$tmp/p/$1" | grep -q "^$2$tab$3$tab"; then ko "$1 : '$2 $3' détecté à tort"
  else ok "$1 -> pas de $2 $3"; fi
}

# PHP
put sym/composer.json '{"require":{"symfony/framework-bundle":"^7.4"}}'; put sym/bin/console ''; put sym/config/bundles.php ''; put sym/phpunit.xml.dist ''
expect sym language php; expect sym package-manager composer; expect sym framework symfony; expect sym test phpunit; expect sym resource symfony; refute sym framework laravel
put lar/composer.json '{"require":{"laravel/framework":"^11"},"require-dev":{"pestphp/pest":"^3"}}'; put lar/artisan ''
expect lar framework laravel; expect lar test pest; expect lar resource laravel; refute lar framework symfony
put wp/wp-config.php ''; expect wp framework wordpress
put dr/web/core/lib/Drupal.php ''; expect dr framework drupal

# Node : frameworks
put nuxt/package.json '{"dependencies":{"nuxt":"4","vue":"3"}}'
expect nuxt framework nuxt; expect nuxt framework vue; expect nuxt parent nuxt; expect nuxt resource nuxt; expect nuxt resource vue
put next/package.json '{"dependencies":{"next":"15","react":"19"}}'
expect next framework nextjs; expect next parent nextjs; expect next resource nextjs; expect next resource react
put react/package.json '{"dependencies":{"react":"19"},"devDependencies":{"vitest":"2"}}'; put react/pnpm-lock.yaml ''; put react/tsconfig.json '{}'
expect react language node; expect react language typescript; expect react framework react; expect react package-manager pnpm; expect react test vitest; expect react resource react; refute react framework nextjs
put rdom/package.json '{"dependencies":{"react-dom":"19"}}'; refute rdom framework react
put ng/package.json '{"dependencies":{"@angular/core":"19"}}'; expect ng framework angular
put sv/package.json '{"dependencies":{"svelte":"5"}}'; expect sv framework svelte
put nest/package.json '{"dependencies":{"@nestjs/core":"11","express":"5"}}'; expect nest framework nestjs; expect nest framework express

# Node : gestionnaires de paquets et tests
put npm0/package.json '{}'; expect npm0 package-manager npm
put npm1/package.json '{}'; put npm1/package-lock.json '{}'; expect npm1 package-manager npm
put yarn/package.json '{}'; put yarn/yarn.lock ''; expect yarn package-manager yarn; refute yarn package-manager npm
put bun/package.json '{}'; put bun/bun.lock ''; expect bun package-manager bun
put js1/package.json '{"devDependencies":{"jest":"30","cypress":"14","@playwright/test":"1"}}'
expect js1 test jest; expect js1 test cypress; expect js1 test playwright
put js2/package.json '{}'; put js2/jest.config.ts ''; expect js2 test jest

# Python
put dj/requirements.txt 'django>=5
pytest
'; put dj/manage.py ''
expect dj language python; expect dj package-manager pip; expect dj framework django; expect dj test pytest; expect dj resource django
put drf/requirements.txt 'djangorestframework
'; refute drf framework django
put fa/pyproject.toml '[project]
dependencies = [
  "fastapi>=0.110",
]
'; put fa/uv.lock ''; expect fa framework fastapi; expect fa package-manager uv
put fl/requirements.txt 'flask
'; put fl/poetry.lock ''; expect fl framework flask; expect fl package-manager poetry
put pe/Pipfile ''; expect pe package-manager pipenv

# Autres langages
put go/go.mod 'module essai'; put go/main_test.go ''; expect go language go; expect go package-manager go-modules; expect go test go-test
put rb/Gemfile "gem 'rails'"; mk rb/spec; expect rb language ruby; expect rb package-manager bundler; expect rb framework rails; expect rb test rspec
put rs/Cargo.toml ''; expect rs language rust; expect rs package-manager cargo
put mvn/pom.xml '<artifactId>spring-boot-starter</artifactId>'; expect mvn language java; expect mvn package-manager maven; expect mvn framework spring-boot
put gr/build.gradle "id 'org.springframework.boot' // spring-boot"; expect gr package-manager gradle; expect gr framework spring-boot
put cs/app.csproj ''; expect cs language dotnet

# Outillage et runners
put ops/Dockerfile ''; put ops/compose.yaml ''; put ops/Makefile ''; mk ops/k8s; mk ops/.github/workflows
put ops/.github/dependabot.yml ''; put ops/.github/pull_request_template.md ''; put ops/commitlint.config.js ''
expect ops tooling docker; expect ops tooling kubernetes; expect ops tooling github-actions; expect ops tooling dependabot
expect ops tooling pr-template; expect ops tooling commitlint; expect ops runner make; expect ops runner "docker compose"
put helm/Chart.yaml ''; expect helm tooling kubernetes

# Contrat de sortie
mk empty
[ -z "$(sh stacks/detect.sh "$tmp/p/empty")" ]; verdict "dossier vide -> aucune détection" $?
sh stacks/detect.sh "$tmp/p/absent" >/dev/null 2>&1; [ $? -eq 1 ]; verdict "dossier absent -> sortie 1" $?
bad=$(sh stacks/detect.sh "$tmp/p/sym" | awk -F'\t' 'NF!=3' | wc -l | tr -d ' ')
[ "$bad" -eq 0 ]; verdict "sortie en trois colonnes" $?
sh stacks/detect.sh "$tmp/p/nuxt" | grep -q "^parent${tab}nuxt${tab}vue$"; verdict "parent de nuxt = vue" $?
sh stacks/detect.sh "$tmp/p/next" | grep -q "^parent${tab}nextjs${tab}react$"; verdict "parent de nextjs = react" $?
sh stacks/detect.sh "$tmp/p/sym" | grep -Fxq "resource${tab}symfony${tab}$root/stacks/symfony/INDEX.md"; verdict "ressource : chemin absolu de INDEX.md" $?
sh stacks/detect.sh "$tmp/p/ng" | grep -q "^resource${tab}angular${tab}aucune$"; verdict "framework sans ressource -> aucune" $?
(cd "$tmp/p" && find . | sort) > "$tmp/before"
for d in "$tmp"/p/*/; do sh stacks/detect.sh "$d" >/dev/null 2>&1; done
(cd "$tmp/p" && find . | sort) > "$tmp/after"
cmp -s "$tmp/before" "$tmp/after"; verdict "aucun fichier créé dans le projet analysé" $?

# --- Bilan -------------------------------------------------------------------

printf '\n%s passés, %s échecs, %s ignorés\n' "$passed" "$failed" "$skipped"
if [ "$failed" -eq 0 ]; then echo "Tout est cohérent."; exit 0; fi
echo "Des contrôles ont échoué."
exit 1
