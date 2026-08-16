# Installation

## Scope

This procedure targets the hardware documented in `HARDWARE.md`.

Do not use it as a generic T495s guide without first comparing:

```text
machine type
BIOS
CPU/iGPU
audio
Wi-Fi/Bluetooth
touchpad
USB topology
display
```

## Important known installer issue

On the target T495s:

```text
Intel Wi-Fi may be unavailable during the macOS installer
AirportItlwm can destabilize or crash the installer
```

This issue is limited to the installation environment in the current project record.

Post-install Wi-Fi operation is user-confirmed with the normal profile.

## Files used

Normal profile:

```text
EFI/OC/config.plist
```

Installer profile:

```text
EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

The installer profile is intended to differ functionally only by:

```text
AirportItlwm.kext -> Enabled = false
```

## Before installation

### 1. Preserve a known-good boot path

Keep:

- a known-good USB EFI;
- a copy of the current working EFI;
- another computer or recovery method capable of editing the EFI partition.

Do not perform first-boot experiments with the only bootable copy.

### 2. Verify target firmware

Target:

```text
BIOS R13ET56W 1.30
```

The firmware UI is simplified and does not expose the sleep-state selector sometimes present on other ThinkPads.

Do not invent or search for a setting that is not present as a prerequisite for this EFI.

### 3. Personalize SMBIOS

The public file contains placeholders:

```text
SystemSerialNumber = C02DEMO00000
MLB = C02DEMO0000000000
SystemUUID = 00000000-0000-0000-0000-000000000000
ROM = 000000000000
```

Replace them with private values appropriate for the selected SMBIOS:

```text
MacBookPro16,3
```

Never publish the resulting production values.

### 4. Validate plist syntax

On macOS:

```bash
plutil -lint EFI/OC/config.plist
plutil -lint EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

The repository validation script can also perform a cross-platform plist parse.

### 5. Preserve required boot arguments

Current normal profile:

```text
keepsyms=1 debug=0x100 npci=0x2000 alcid=97 revblock=media revpatch=cpuname,sbvmm,auto AMDBacklight=1
```

Do not remove `npci=0x2000` as a cleanup step on this target unless bootability has been tested separately.

## macOS installer EFI

Because of the Wi-Fi installer issue:

1. duplicate the working EFI before changing it;
2. use the no-Wi-Fi profile as the installer `config.plist`;
3. leave the rest of the EFI unchanged;
4. use Ethernet or a full/offline installer.

The repository validation rule treats unrelated changes in the no-Wi-Fi profile as an error.

## Installation sequence

1. create the macOS Ventura installer using a lawful Apple-provided installer source;
2. mount the installer EFI partition;
3. copy the repository EFI;
4. personalize SMBIOS;
5. replace `config.plist` with the no-Wi-Fi profile if installer Wi-Fi causes instability;
6. validate plist syntax;
7. boot OpenCore;
8. use keyboard navigation in the picker;
9. install macOS Ventura;
10. allow required installer reboots;
11. after the installed system reaches the desktop, return to the normal profile with AirportItlwm enabled;
12. copy the validated EFI to the internal EFI partition only after the external/USB boot path is known-good.

## Post-install

Root launcher:

```text
INSTALL.command
```

It invokes:

```text
Tools/Install.command
```

## What the post-install script changes

### Trackpad preferences

It writes:

```text
Clicking = true
TrackpadRightClick = true
TrackpadCornerSecondaryClick = 2
ForceSuppressed = true
com.apple.mouse.tapBehavior = 1
```

for the relevant user preference domains.

### Brightness helper

It runs:

```text
Tools/Brightness/Install.command
```

which builds and installs the v17 AppKit brightness overlay.

The brightness installer:

- compiles local source with the installed macOS SDK;
- unloads/removes the retired gamma bridge;
- restores ColorSync state left by the retired bridge;
- installs the overlay binary;
- installs a per-user LaunchAgent.

### Power settings

Current default result:

```text
Power and sleep settings: unchanged
```

The default installer does not enable historical lid continuity.

### Touchscreen

The experimental touchscreen bridge is not installed.

## Command Line Tools requirement

The brightness helper uses:

```bash
xcrun --find clang
xcrun --sdk macosx --show-sdk-path
```

If no compiler/SDK is available, install Apple Command Line Tools:

```bash
xcode-select --install
```

The installer should fail the brightness-helper step rather than silently claiming success.

## Brightness validation after install

Run:

```bash
Tools/Brightness/Status.command
```

Then test:

- slider;
- brightness keys;
- minimum/maximum visual range;
- fullscreen window;
- click-through pointer behavior;
- lock/unlock.

Because the v17 overlay remains pending sustained target revalidation, do not immediately assume an installed LaunchAgent equals a validated result.

## Chrome configuration after install

Until the GPU issue is solved:

```text
Chrome -> Settings -> System
Use graphics acceleration when available -> Off
```

or launch:

```bash
Tools/Chrome/Launch-Safe.command
```

This is the documented containment requirement for reliable practical Chrome use on the currently documented system state; it does not repair the underlying GPU path.

## Native sleep warning

Native suspend/resume is not reliable.

Do not assume:

```text
closing lid = safe suspend
```

The current default installer intentionally does not hide this limitation behind the historical continuity mode.

## Historical lid continuity

Manual path:

```text
Tools/Power/Enable-Continuity.command
```

Read `Tools/Power/README.md` first.

That mode:

- sets `disablesleep=1`;
- locks the session on lid close;
- sleeps the display;
- keeps the computer powered.

It is not native sleep and is not safe for closed-bag transport.

Disable:

```text
Tools/Power/Disable-Continuity.command
```

Review resulting `pmset` values after using either script.

## Touchscreen experiment

Do not install the touchscreen bridge until the probe finds:

```text
VID 0x1A86
PID 0xE5E3
```

First run:

```bash
Experimental/Touchscreen/01-PROBE-TOUCHSCREEN.command
```

Current expected result on the documented system is no matched target device.

## First-boot validation checklist

### Boot

```text
OpenCore picker appears
keyboard input works
Ventura reaches desktop
```

### CPU

```bash
sysctl -n hw.physicalcpu
sysctl -n hw.logicalcpu
```

Expected topology:

```text
4 physical
8 logical
```

### Graphics

```bash
system_profiler SPDisplaysDataType
kmutil showloaded | grep -Ei 'Lilu|NootedRed'
```

Expected:

```text
AMD Radeon Vega 10
Metal supported
internal 1920x1080 display
```

Do not interpret this as proof of long-duration stability.

### Network

Verify:

```text
post-install Wi-Fi
Bluetooth controller enumeration
Ethernet if used
```

### Input

Verify:

```text
keyboard
touchpad
tap
secondary click
scroll
TrackPoint/buttons if required
```

### Brightness

Verify native control plane first.

Then separately validate the v17 overlay.

### Audio

Verify actual output/input endpoints rather than only AppleALC load.

### USB

Verify internal camera and every external port required for normal use.

### Sleep

Do not run a casual lid-close test until you have a recovery plan.

Use the controlled procedure in `POWER-SLEEP.md`.

## Updating from v15/v16 brightness bridge

The current brightness installer removes:

```text
com.terabitlab.t495s-brightness.plist
T495sBrightnessBridge
```

and performs:

```text
CGDisplayRestoreColorSyncSettings
```

through the new helper's migration mode.

This is intended to clear state from the retired gamma solution.

## Updating from lid-continuity builds

If a previous build enabled continuity mode:

1. run the corresponding disable script;
2. inspect:

```bash
pmset -g custom
```

3. remove residual LaunchAgents/LaunchDaemons if necessary;
4. reboot;
5. test native sleep only after confirming `disablesleep` is not set.

## Installation failure categories

### OpenCore does not boot

Do not run post-install tools.

Restore known-good EFI and compare:

- ACPI;
- kernel patches;
- NootedRed/Lilu versions;
- boot arguments;
- SMBIOS.

### Installer crashes when networking starts

Use the no-Wi-Fi profile.

Do not remove unrelated kexts.

### Brightness helper compile fails

Record exact `clang` error and SDK path.

Do not claim brightness installed.

### Chrome freezes

Confirm retired gamma bridge is absent, then disable hardware acceleration.

### Sleep hangs

Do not change brightness, network and GPU simultaneously.

Collect power logs first.

## After a successful installation

Keep two EFI copies:

```text
EFI-known-good
EFI-development
```

Never perform an untested NootedRed, kernel patch or ACPI experiment directly on the only internal boot path.
