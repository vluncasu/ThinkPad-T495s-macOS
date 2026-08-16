#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h}"
APP_DIR="$HOME/Library/Application Support/T495s"
BIN="$APP_DIR/T495sBrightnessOverlay"
SOURCE="$ROOT/src/T495sBrightnessOverlay.m"
AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness-overlay.plist"
OLD_AGENT="$HOME/Library/LaunchAgents/com.terabitlab.t495s-brightness.plist"
LOG="$HOME/Library/Logs/T495sBrightnessOverlay.log"

CLANG="$(xcrun --find clang 2>/dev/null || true)"
SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
if [[ -z "$CLANG" || -z "$SDKROOT" ]]; then
  echo "Command Line Tools are required: xcode-select --install"
  exit 1
fi

mkdir -p "$APP_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
TMP_BIN="$(mktemp -t T495sBrightnessOverlay)"
trap 'rm -f "$TMP_BIN"' EXIT

"$CLANG" \
  -isysroot "$SDKROOT" \
  -mmacosx-version-min=13.0 \
  -fobjc-arc \
  -O2 -Wall -Wextra \
  "$SOURCE" \
  -framework AppKit \
  -framework CoreGraphics \
  -framework IOKit \
  -o "$TMP_BIN"

launchctl bootout "gui/$UID" "$OLD_AGENT" 2>/dev/null || true
launchctl bootout "gui/$UID" "$AGENT" 2>/dev/null || true
pkill -x T495sBrightnessBridge 2>/dev/null || true
pkill -x T495sBrightnessOverlay 2>/dev/null || true

rm -f "$OLD_AGENT" "$APP_DIR/T495sBrightnessBridge"
install -m 755 "$TMP_BIN" "$BIN"
"$BIN" --restore-only

cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.terabitlab.t495s-brightness-overlay</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN</string>
    <string>--threshold</string>
    <string>0.90</string>
    <string>--max-alpha</string>
    <string>0.90</string>
    <string>--curve</string>
    <string>1.35</string>
    <string>--interval-ms</string>
    <string>250</string>
  </array>
  <key>LimitLoadToSessionType</key>
  <string>Aqua</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ThrottleInterval</key>
  <integer>10</integer>
  <key>ProcessType</key>
  <string>Interactive</string>
  <key>StandardOutPath</key>
  <string>$LOG</string>
  <key>StandardErrorPath</key>
  <string>$LOG</string>
</dict>
</plist>
PLIST

plutil -lint "$AGENT" >/dev/null
launchctl bootstrap "gui/$UID" "$AGENT"
launchctl kickstart -k "gui/$UID/com.terabitlab.t495s-brightness-overlay"

echo "Brightness overlay installed."
echo "ColorSync gamma modification removed."
echo "Sleep configuration was not changed."
