#!/bin/zsh
set -u

previous=""
while true; do
  current=$(/usr/sbin/ioreg -r -k AppleClamshellState -d 4 2>/dev/null | /usr/bin/awk '/AppleClamshellState/ {print $NF; exit}')
  if [[ -n "$current" && "$current" != "$previous" ]]; then
    if [[ "$current" == "Yes" ]]; then
      /usr/bin/pmset -b lowpowermode 1 >/dev/null 2>&1 || true
    else
      /usr/bin/pmset -b lowpowermode 0 >/dev/null 2>&1 || true
    fi
    previous="$current"
  fi
  /bin/sleep 1
done
