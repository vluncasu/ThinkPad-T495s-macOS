#!/bin/zsh
set -u

STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$HOME/Desktop/T495s-power-brightness-$STAMP"
mkdir -p "$OUT"

{
  date
  sw_vers
  uname -a
  nvram boot-args 2>&1 || true
} > "$OUT/system.txt" 2>&1

pmset -g custom > "$OUT/pmset-custom.txt" 2>&1 || true
pmset -g assertions > "$OUT/pmset-assertions.txt" 2>&1 || true
pmset -g log | tail -1200 > "$OUT/pmset-log.txt" 2>&1 || true
system_profiler SPDisplaysDataType > "$OUT/displays.txt" 2>&1 || true
ioreg -lw0 -r -c AppleBacklightDisplay > "$OUT/apple-backlight-display.txt" 2>&1 || true
ioreg -lw0 -r -c IODisplayConnect > "$OUT/display-connect.txt" 2>&1 || true
ioreg -lw0 -r -k AppleClamshellState -d 4 > "$OUT/clamshell.txt" 2>&1 || true
kmutil showloaded | grep -Ei 'Lilu|NootedRed|BrightnessKeys|VoodooPS2|NVMeFix|AirportItlwm|IntelBluetooth' > "$OUT/kexts.txt" 2>&1 || true
launchctl print "gui/$UID/com.terabitlab.t495s-brightness" > "$OUT/brightness-agent.txt" 2>&1 || true
launchctl print "gui/$UID/com.terabitlab.t495s-lid-continuity" > "$OUT/lid-agent.txt" 2>&1 || true
sudo launchctl print system/com.terabitlab.t495s-lid-power > "$OUT/lid-power-daemon.txt" 2>&1 || true
cp "$HOME/Library/Logs/T495sBrightness.log" "$OUT/" 2>/dev/null || true
cp "$HOME/Library/Logs/T495sLidContinuity.log" "$OUT/" 2>/dev/null || true
sudo cp /var/log/T495sLidPower.log "$OUT/" 2>/dev/null || true

ditto -c -k --sequesterRsrc --keepParent "$OUT" "$OUT.zip"
rm -rf "$OUT"
echo "$OUT.zip"
