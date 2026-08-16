#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h}"
APP_DIR="$HOME/Library/Application Support/T495s"
SCRIPT="$APP_DIR/lid-continuity.sh"
AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-lid-continuity.plist"
LOG_DIR="$HOME/Library/Logs"
SYSTEM_DIR="/Library/Application Support/T495s"
SYSTEM_SCRIPT="$SYSTEM_DIR/lid-power-policy.sh"
SYSTEM_AGENT="/Library/LaunchDaemons/com.terabitlab.t495s-lid-power.plist"

mkdir -p "$APP_DIR" "$HOME/Library/LaunchAgents" "$LOG_DIR"
/usr/bin/pmset -g custom > "$APP_DIR/pmset-before-continuity.txt" 2>&1 || true
cp "$ROOT/lid-continuity.sh" "$SCRIPT"
chmod 755 "$SCRIPT"

sudo /usr/bin/pmset -a disablesleep 1 sleep 0 standby 0 autopoweroff 0 hibernatemode 0 \
  powernap 0 tcpkeepalive 0 proximitywake 0 ttyskeepawake 0 womp 0
sudo /usr/bin/pmset repeat cancel >/dev/null 2>&1 || true
sudo rm -f /var/vm/sleepimage 2>/dev/null || true

sudo mkdir -p "$SYSTEM_DIR"
sudo cp "$ROOT/lid-power-policy.sh" "$SYSTEM_SCRIPT"
sudo chmod 755 "$SYSTEM_SCRIPT"
TMP_PLIST=$(mktemp)
cat > "$TMP_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.terabitlab.t495s-lid-power</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SYSTEM_SCRIPT</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/var/log/T495sLidPower.log</string>
  <key>StandardErrorPath</key>
  <string>/var/log/T495sLidPower.log</string>
</dict>
</plist>
PLIST
sudo launchctl bootout system "$SYSTEM_AGENT" 2>/dev/null || true
sudo cp "$TMP_PLIST" "$SYSTEM_AGENT"
sudo chown root:wheel "$SYSTEM_AGENT"
sudo chmod 644 "$SYSTEM_AGENT"
rm -f "$TMP_PLIST"
sudo launchctl bootstrap system "$SYSTEM_AGENT"

defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.terabitlab.t495s-lid-continuity</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/T495sLidContinuity.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/T495sLidContinuity.log</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$UID" "$AGENT" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$AGENT"
launchctl kickstart -k "gui/$UID/com.terabitlab.t495s-lid-continuity"

echo "Lid continuity enabled. The computer remains powered while the lid is closed."
