#!/bin/zsh
set -u

CGSESSION="/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"
previous=""

while true; do
  current=$(/usr/sbin/ioreg -r -k AppleClamshellState -d 4 2>/dev/null | /usr/bin/awk '/AppleClamshellState/ {print $NF; exit}')
  if [[ -n "$current" && "$current" != "$previous" ]]; then
    if [[ "$current" == "Yes" ]]; then
      [[ -x "$CGSESSION" ]] && "$CGSESSION" -suspend >/dev/null 2>&1 || true
      /usr/bin/pmset displaysleepnow >/dev/null 2>&1 || true
      echo "$(date -u +%FT%TZ) lid=closed"
    else
      /usr/bin/caffeinate -u -t 2 >/dev/null 2>&1 || true
      echo "$(date -u +%FT%TZ) lid=open"
    fi
    previous="$current"
  fi
  /bin/sleep 0.5
done
