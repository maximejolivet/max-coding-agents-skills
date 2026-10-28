#!/bin/sh
# Réinitialise l'installation locale du plugin max : met le dépôt à jour sur main,
# désinstalle toutes les installations (user, local, project), rafraîchit le
# marketplace puis réinstalle. À lancer hors d'une session Claude Code, puis
# relancer `claude` : une session ouverte garde l'ancienne liste de plugins.
#
# Usage : sh scripts/reinstall-plugin.sh

set -eu

PLUGIN="max@max"
MARKETPLACE="max"
REPO=$(cd "$(dirname "$0")/.." && pwd)
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"

command -v claude >/dev/null 2>&1 || { echo "claude introuvable dans le PATH" >&2; exit 1; }

# Le marketplace pointe vers ce dossier : il doit être sur main, à jour.
echo "==> Mise à jour du dépôt ($REPO)"
if [ -n "$(git -C "$REPO" status --porcelain --untracked-files=no)" ]; then
  echo "Modifications non validées dans $REPO : stash ou commit d'abord." >&2
  exit 1
fi
git -C "$REPO" checkout -q main
git -C "$REPO" pull -q --ff-only

# Désinstallation de chaque installation connue (la portée local/project se
# résout depuis le dossier du projet).
echo "==> Désinstallation de $PLUGIN"
if [ -f "$INSTALLED" ]; then
  python3 - "$INSTALLED" "$PLUGIN" <<'PY' | while IFS="$(printf '\t')" read -r scope dir; do
import json, sys
data = json.load(open(sys.argv[1]))
for e in data.get("plugins", {}).get(sys.argv[2], []):
    print(f"{e['scope']}\t{e.get('projectPath') or ''}")
PY
    if [ -n "$dir" ] && [ -d "$dir" ]; then
      (cd "$dir" && claude plugin uninstall "$PLUGIN" --scope "$scope") || true
    else
      claude plugin uninstall "$PLUGIN" --scope "$scope" || true
    fi
  done
else
  claude plugin uninstall "$PLUGIN" || true
fi

echo "==> Rafraîchissement du marketplace $MARKETPLACE"
claude plugin marketplace update "$MARKETPLACE"

echo "==> Installation de $PLUGIN"
claude plugin install "$PLUGIN"

echo "==> État"
claude plugin list 2>/dev/null | grep -A4 "$PLUGIN" || true
grep '"version"' "$REPO/.claude-plugin/plugin.json"
echo "Terminé. Relance maintenant claude (nouvelle session)."
