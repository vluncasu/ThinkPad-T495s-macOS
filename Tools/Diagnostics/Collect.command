#!/bin/zsh
set -u

STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$HOME/Desktop/T495s-diagnostics-$STAMP"
mkdir -p "$OUT"

/usr/bin/pmset -g custom > "$OUT/pmset-custom.txt" 2>&1
/usr/bin/pmset -g assertions > "$OUT/pmset-assertions.txt" 2>&1
/usr/bin/pmset -g log | tail -2000 > "$OUT/pmset-log.txt" 2>&1
/usr/bin/kmutil showloaded > "$OUT/kexts.txt" 2>&1
/usr/sbin/ioreg -lw0 -p IOUSB > "$OUT/ioreg-usb.txt" 2>&1
/usr/sbin/ioreg -lw0 | /usr/bin/grep -Ei 'AppleClamshell|AppleBacklight|IODisplayParameters|linear-brightness|PNLF|NootedRed|ELAN|VoodooPS2|XHC' > "$OUT/ioreg-relevant.txt" 2>&1
/usr/sbin/system_profiler SPDisplaysDataType SPPowerDataType > "$OUT/system-profiler.txt" 2>&1
/usr/bin/log show --last 2h --style compact --predicate '(eventMessage CONTAINS[c] "sleep") OR (eventMessage CONTAINS[c] "wake") OR (eventMessage CONTAINS[c] "backlight") OR (eventMessage CONTAINS[c] "NootedRed")' > "$OUT/unified-log.txt" 2>&1
cp "$HOME/Library/Logs/T495sBrightness.log" "$OUT/" 2>/dev/null || true
cp "$HOME/Library/Logs/T495sLidContinuity.log" "$OUT/" 2>/dev/null || true

cd "$HOME/Desktop"
/usr/bin/zip -qry "T495s-diagnostics-$STAMP.zip" "T495s-diagnostics-$STAMP"
echo "$HOME/Desktop/T495s-diagnostics-$STAMP.zip"
