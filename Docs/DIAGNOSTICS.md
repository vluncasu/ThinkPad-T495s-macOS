# Diagnostics

## Objective

Diagnostics should capture enough state to identify the failing layer without publishing unnecessary personal data.

Keep raw diagnostics private. Add only sanitized excerpts to the public repository.

## Baseline system state

```bash
sw_vers
uname -a
nvram boot-args
system_profiler SPHardwareDataType
system_profiler SPDisplaysDataType
```

## Loaded project kexts

```bash
kmutil showloaded | grep -Ei \
'Lilu|NootedRed|VirtualSMC|SMC|Ryzen|ForgedInvariant|AppleALC|BrightnessKeys|Voodoo|Airport|IntelBluetooth|BlueTool|Realtek|NVMe|Emerald|ECEnabler|RestrictEvents'
```

## Graphics

```bash
system_profiler SPDisplaysDataType
ioreg -lw0 | grep -Ei 'AMDRadeon|IOAccelerator|IOFramebuffer|AppleBacklightDisplay|IODisplayConnect'
```

Relevant failure reports:

```bash
find /Library/Logs/DiagnosticReports \
     "$HOME/Library/Logs/DiagnosticReports" \
     -type f \
     \( -iname '*gpuRestart*' -o -iname '*panic*' -o -iname '*WindowServer*' \)
```

## Chrome live logging

A reproducible accelerated test can launch Chrome from Terminal with logging enabled.

The project has previously collected:

```text
Chrome stderr/log output
unified kernel/WindowServer stream
display state
IORegistry GPU state
loaded kexts
```

The simplest stable control is:

```bash
Tools/Chrome/Launch-Safe.command
```

## Brightness

Status:

```bash
Tools/Brightness/Status.command
```

Process:

```bash
pgrep -fl 'T495sBrightness'
```

Display property:

```bash
ioreg -r -c IODisplayConnect -l
```

Overlay log:

```text
~/Library/Logs/T495sBrightnessOverlay.log
```

## Power and sleep

Before:

```bash
pmset -g
pmset -g custom
pmset -g cap
pmset -g assertions
ioreg -r -k AppleClamshellState -d 4
```

After:

```bash
pmset -g log
```

Unified log search:

```bash
log show --last 45m --style compact \
  --predicate '(process == "powerd") OR (process == "kernel")'
```

Useful terms:

```text
Sleep
Wake
DarkWake
FullWake
WakeTime
PM Client Acks
IOGraphics
AMDRadeon
Bluetooth
USB
```

Repository helper:

```bash
Tools/Diagnostics/Collect-Power-Brightness.command
```

## USB

```bash
system_profiler SPUSBDataType
ioreg -p IOUSB -l -w0
```

Expected observed internal devices include:

```text
05E3:0610 Genesys hub
13D3:5406 integrated camera
8087:0029 Intel Bluetooth
```

The touchscreen target expected but absent in captured data:

```text
1A86:E5E3
```

## Touchscreen

Run:

```bash
Experimental/Touchscreen/01-PROBE-TOUCHSCREEN.command
```

Do not install the bridge simply because the probe executable builds.

Required success condition:

```text
Matched touchscreen
VID=0x1A86
PID=0xE5E3
```

## Audio

```bash
system_profiler SPAudioDataType
ioreg -lw0 | grep -Ei 'AppleHDA|ALC'
kmutil showloaded | grep -Ei 'Lilu|AppleALC'
```

## Network

Wi-Fi:

```bash
ifconfig
networksetup -listallhardwareports
```

Bluetooth:

```bash
system_profiler SPBluetoothDataType
system_profiler SPUSBDataType
```

Ethernet:

```bash
ifconfig
```

## Storage

```bash
diskutil list
system_profiler SPNVMeDataType
```

## Public sanitization

Before committing any diagnostic:

remove:

```text
/Users/<name>
hostnames
serial numbers
SystemUUID
MLB
ROM
Apple account identifiers
unrelated browser/process data
USB storage serials when unnecessary
```

Retain:

```text
timestamps
driver names
kernel extensions
device IDs
error strings
state transitions
```

## Diagnostic filename convention

Recommended:

```text
YYYYMMDD-HHMMSS-subsystem-state
```

Examples:

```text
20260801-034527-gpu-reset
20260801-032814-sleep-failed-resume
```

## Evidence acceptance

A diagnostic excerpt added to the public repository should include:

```text
source bundle
date
configuration version
minimum lines needed to support claim
interpretation
limitations
```

Do not publish a conclusion without the supporting failure string when that string is available.
