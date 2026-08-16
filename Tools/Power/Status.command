#!/bin/zsh
set -u

echo "Power settings:"
pmset -g custom

echo "\nSleep assertions:"
pmset -g assertions

echo "\nClamshell state:"
ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState || true

echo "\nContinuity agents:"
launchctl print "gui/$UID/com.terabitlab.t495s-lid-continuity" 2>&1 | sed -n '1,80p' || true
sudo launchctl print system/com.terabitlab.t495s-lid-power 2>&1 | sed -n '1,80p' || true

echo "\nRecent logs:"
tail -50 "$HOME/Library/Logs/T495sLidContinuity.log" 2>/dev/null || true
sudo tail -50 /var/log/T495sLidPower.log 2>/dev/null || true
