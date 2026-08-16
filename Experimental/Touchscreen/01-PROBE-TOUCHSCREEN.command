#!/bin/bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HOME/Desktop/T495s-touchscreen-probe-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
echo "Collecting USB and HID information..."
system_profiler SPUSBDataType > "$OUT/system-profiler-usb.txt" 2>&1
ioreg -p IOUSB -l -w0 > "$OUT/ioreg-usb.txt" 2>&1
ioreg -r -c IOHIDDevice -l -w0 > "$OUT/ioreg-hid.txt" 2>&1
log show --last boot --style compact --predicate 'process == "kernel" AND (eventMessage CONTAINS[c] "USB" OR eventMessage CONTAINS[c] "XHCI" OR eventMessage CONTAINS[c] "HID")' > "$OUT/kernel-usb-hid-log.txt" 2>&1

BIN="$OUT/TouchscreenBridge-Probe"
clang -fobjc-arc -fblocks "$HERE/TouchscreenBridge.m" -framework Foundation -framework ApplicationServices -framework IOKit -o "$BIN" 2> "$OUT/build-errors.txt"
if [ -x "$BIN" ]; then
  echo "Touch the panel several times during the next 20 seconds."
  "$BIN" --probe-only > "$OUT/bridge-probe.txt" 2>&1
else
  echo "Build failed. See build-errors.txt"
fi

/usr/bin/zip -qry "$OUT.zip" "$OUT"
echo
echo "DONE: $OUT.zip"
open -R "$OUT.zip"
