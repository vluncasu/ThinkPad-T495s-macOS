#!/bin/zsh
set -euo pipefail

LABEL="com.terabitlab.t495s-brightness-overlay"
AGENT="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ ! -f "$AGENT" ]]; then
  echo "Run Install.command first."
  exit 1
fi

launchctl bootout "gui/$UID" "$AGENT" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$AGENT"
launchctl kickstart -k "gui/$UID/$LABEL"
echo "Brightness overlay enabled."
