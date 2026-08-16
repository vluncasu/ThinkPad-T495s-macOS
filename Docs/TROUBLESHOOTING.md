# Troubleshooting

## Rule 1 - identify the subsystem before changing the EFI

Do not respond to a symptom by updating every kext.

Classify first:

```text
boot
CPU
GPU
brightness
input
network
audio
USB/storage
sleep
touchscreen
```

Then change one variable.

## Chrome artifacts, freeze or total system lock

### First check

Confirm the retired gamma bridge is not running:

```bash
pgrep -fl T495sBrightnessBridge
```

Expected:

```text
no process
```

The current overlay process, if installed, is:

```text
T495sBrightnessOverlay
```

### Control test

Launch:

```bash
Tools/Chrome/Launch-Safe.command
```

If Chrome remains functional in software-rendering mode while normal accelerated Chrome fails, classify the issue as GPU-path related.

### Collect

After restart:

```bash
find /Library/Logs/DiagnosticReports \
     "$HOME/Library/Logs/DiagnosticReports" \
     -type f \
     \( -iname '*gpuRestart*' -o -iname '*panic*' -o -iname '*WindowServer*' \)
```

Look for:

```text
AMDRadeonX5000
IOAcceleratorFamily2
GFX
hung
timeout
Google Chrome Helper
Metal
```

Do not reinstall Chrome as the first response to a kernel-level GPU reset.

## Geekbench Metal passes but Chrome fails

This is not contradictory.

Geekbench proves:

```text
Metal can execute a benchmark workload
```

Chrome may stress different:

- command-buffer patterns;
- Dawn/WebGPU path;
- video decode;
- compositing;
- surfaces;
- synchronization;
- WindowServer integration.

Keep the GPU classified as accelerated but unstable.

## Brightness slider moves but screen has only two levels

Expected current hardware limitation.

Verify control property:

```bash
ioreg -r -c IODisplayConnect -l | grep -i brightness
```

Do not assume the missing physical range can be solved by another slider.

The v17 overlay exists specifically because the control value is continuous while the hardware response is not.

## Brightness overlay does not run

Check:

```bash
Tools/Brightness/Status.command
```

Then:

```bash
launchctl print "gui/$UID/com.terabitlab.t495s-brightness-overlay"
```

Log:

```text
~/Library/Logs/T495sBrightnessOverlay.log
```

If build failed:

```bash
xcrun --find clang
xcrun --sdk macosx --show-sdk-path
```

The installer requires a usable macOS SDK.

## Colors look wrong after old brightness bridge

Run the current brightness installer or its migration restore path.

The v17 helper calls:

```text
CGDisplayRestoreColorSyncSettings()
```

to clear the retired custom transfer state.

Do not re-enable the old gamma bridge.

## Touchpad stops after typing

Confirm the actual active Elantech profile contains:

```text
QuietTimeAfterTyping = 0
```

and that no conflicting VoodooI2C/VoodooPS2Mouse path has been reintroduced.

Check loaded stack:

```bash
kmutil showloaded | grep -Ei 'VoodooPS2|VoodooInput|VoodooI2C'
```

## Touchpad stops when USB/Bluetooth mouse is attached

Confirm:

```text
ProcessBluetoothMouseStopsTrackpad = false
ProcessUSBMouseStopsTrackpad = false
USBMouseStopsTrackpad = 0
```

Do not change macOS tap preferences to solve a driver-level suppression problem.

## Wi-Fi crashes or is absent in macOS installer

Use:

```text
EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

or disable only AirportItlwm in a copy of the normal config.

Use Ethernet or a full/offline installer.

After installed macOS boots, restore the normal profile.

## Wi-Fi works after install but not in installer

This is the currently documented expected asymmetry.

Do not treat it as evidence that the normal AirportItlwm profile must remain disabled permanently.

## Bluetooth does not initialize

Check USB enumeration:

```bash
system_profiler SPUSBDataType
```

Expected target:

```text
8087:0029
```

Check loaded stack:

```bash
kmutil showloaded | grep -Ei 'IntelBluetooth|IntelBTPatcher|BlueTool'
```

If the USB device itself is absent, a firmware kext update is not the first diagnosis.

## Native sleep enters but does not wake

First remove test confounders:

```text
Screen Sharing
external USB storage
dock
HDMI
```

Confirm historical continuity is disabled.

Then collect:

```bash
pmset -g
pmset -g custom
pmset -g assertions
```

Perform manual Apple-menu sleep before lid testing.

After restart:

```bash
pmset -g log
```

Search:

```text
Entering Sleep
DarkWake
FullWake
WakeTime
PM Client Acks
IOGraphics
AMDRadeon
Bluetooth
```

Do not call display-off continuity a sleep fix.

## Laptop remains powered with lid closed

Check whether historical continuity mode is enabled.

It intentionally sets:

```text
disablesleep=1
```

Disable it with:

```bash
Tools/Power/Disable-Continuity.command
```

Then inspect:

```bash
pmset -g custom
```

before native sleep testing.

## Touchscreen probe finds nothing

Current documented result is no enumeration.

Run:

```bash
Experimental/Touchscreen/01-PROBE-TOUCHSCREEN.command
```

The bridge should not be installed until:

```text
VID 1A86
PID E5E3
```

appears.

Do not use guessed pointer events or USB-map edits to conceal a missing hardware endpoint.

## NootedRed does not load

Check:

```bash
kmutil showloaded | grep -Ei 'Lilu|NootedRed'
```

Historical failure:

```text
Lilu 1.6.8
NootedRed required compatible 1.7.0
```

Current bundled Lilu:

```text
1.7.2
```

Treat Lilu/NootedRed as a dependency pair.

## Boot fails after kernel patch update

Restore the known-good config.

Compare:

```text
kernel version
patch MinKernel/MaxKernel
Find/Replace bytes
enabled state
PAT alternative
```

Do not expand version ranges blindly.

## Startup chime silent

Separate pre-boot audio from runtime audio.

Check:

```text
AudioDxe.efi enabled
AudioSupport=true
PlayChime=Enabled
AudioDevice path
AudioOutMask
```

A working AppleALC runtime speaker does not prove UEFI audio.

## Audio works poorly in macOS

Collect:

```bash
system_profiler SPAudioDataType
kmutil showloaded | grep -Ei 'Lilu|AppleALC'
```

Verify `alcid=97`.

Do not change `AudioDxe` to solve a CoreAudio route.

## USB device missing

First determine whether:

```text
controller port exists
device enumerates
device is mapped
driver matches
```

A missing device is not automatically a USBMap problem.

The touchscreen investigation is the example: the parent hub enumerates while the target child does not.

## After any successful fix

Update:

```text
STATUS.md
TEST-MATRIX.md
DEVELOPMENT-HISTORY.md
KNOWN-ISSUES.md
```

and attach evidence before changing a status label.
