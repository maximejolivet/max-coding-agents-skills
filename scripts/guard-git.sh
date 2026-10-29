#!/bin/sh
# Hook PreToolUse (Bash) : bloque les push git dangereux.
# - force push (--force, -f ; --force-with-lease reste permis)
# - push direct vers main ou master
# Lit le JSON de l'évènement sur stdin ; sans python3, laisse passer.
# Sortie 2 = commande refusée, le message va sur stderr.

command -v python3 >/dev/null 2>&1 || exit 0

cmd=$(python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))
except Exception:
    pass' 2>/dev/null)

case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

if printf '%s' "$cmd" | grep -Eq 'git push([^;&|]*) (--force([^-]|$)|-[a-zA-Z]*f[a-zA-Z]*([[:space:]]|$))'; then
  echo "max: git push --force refusé. Utiliser --force-with-lease avec l'accord explicite de l'utilisateur." >&2
  exit 2
fi

if printf '%s' "$cmd" | grep -Eq 'git push([^;&|]*)[[:space:]:](main|master)([[:space:]]|$)'; then
  echo "max: push direct vers main/master refusé. Passer par une branche et une pull request." >&2
  exit 2
fi

exit 0
