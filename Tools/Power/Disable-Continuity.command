#!/bin/zsh
set -euo pipefail

AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-lid-continuity.plist"
launchctl bootout "gui/$UID" "$AGENT" 2>/dev/null || true
rm -f "$AGENT" "$HOME/Library/Application Support/T495s/lid-continuity.sh"
sudo launchctl bootout system /Library/LaunchDaemons/com.terabitlab.t495s-lid-power.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/com.terabitlab.t495s-lid-power.plist "/Library/Application Support/T495s/lid-power-policy.sh"
sudo /usr/bin/pmset -b lowpowermode 0
sudo /usr/bin/pmset -a disablesleep 0 sleep 10 standby 1 autopoweroff 1 hibernatemode 3 \
  powernap 0 tcpkeepalive 0 proximitywake 0 ttyskeepawake 1

echo "Lid continuity disabled. Standard macOS sleep settings were restored."
