# Development history

## Purpose

This is the engineering chronology of the T495s compatibility work.

The history retains unsuccessful experiments because they explain why the current architecture exists and prevent repeated dead ends.

The version labels refer to the preserved project archives supplied during development.

## Summary timeline

| Stage | Primary purpose | Result |
|---|---|---|
| v2-v3 | Initial full EFI / backlight toggling | Bootable foundation; graphics/backlight path not yet properly isolated |
| v4 | Diagnostic split with no-NootedRed control | Established a clean comparison baseline |
| Final/early branch | NootedRed integration attempts | Graphics dependency/path still under investigation |
| v5 | Original-base no-NootedRed control | Bootable comparison state |
| v6 | NootedRed accelerated build | Reintroduced acceleration with compatible stack |
| v7 | Flattened bootable package | Normalized EFI deployment |
| v8 | Verified accelerated baseline | Became reference for later experiments |
| v9 | Wake/PNLF test | Began backlight and wake isolation |
| v10 | Clean diagnostic package | Reduced unrelated state and added diagnostics |
| v11 | Hibernation, brightness, touchpad | Built full brightness control plane, PS/2 touchpad tuning; hibernation did not solve resume |
| v12 | Non-verbose / touchscreen bridge | Daily boot cleanup and isolated touchscreen probe |
| v13 | Brightness-range NootedRed binary experiment | Rejected; reverted |
| v14 | Internal USB-hub touchscreen experiment | Target touchscreen still did not enumerate |
| v15 | Organized power + gamma brightness bridge | Architecture organized; first bridge installer failed; continuity was not native sleep |
| v16 | Brightness build/install repair | Gamma bridge actually deployable; independent installer status |
| v16.1 | OpenCore startup chime | Added UEFI audio path |
| v16.2 | Sleep-timeout diagnostics | Instrumentation build for native resume failure |
| v17 | Safe brightness redesign | Removed continuous custom gamma writes; userspace AppKit overlay |
| v17.1 public | GitHub documentation/public sanitization | Structured public repository |
| v17.1 docs-r2 | Documentation audit | Evidence classification, exact configuration, security and failure analysis expanded |

## v2 - initial full EFI

Archive:

```text
ThinkPad-T495s-Ventura-EFI-v2.zip
```

Observed configuration characteristics:

```text
NootedRed enabled
VoodooI2C present
AirportItlwm enabled
SSDT-ALS0 present
SSDT-XOSI present
no BrightnessKeys
no SSDT-PNLF
AudioSupport = false
verbose boot enabled
```

Boot arguments included:

```text
-v
keepsyms=1
debug=0x100
npci=0x2000
alcid=97
revblock=media
revpatch=cpuname,sbvmm,auto
```

This state combined multiple unresolved subsystems. It was useful as a source baseline but insufficient for causal isolation.

## v3 - backlight module disabled

Archive:

```text
ThinkPad-T495s-Ventura-EFI-v3.zip
```

Key difference:

```text
AMDBacklight=0
```

This was an early attempt to separate NootedRed graphics acceleration from NootedRed backlight behavior.

The later architecture retained this separation concept: acceleration and backlight must be tested as different subfunctions.

## v4 - diagnostic control

Archive:

```text
ThinkPad-T495s-Ventura-Diagnostic-v4.zip
```

The archive contains a deliberately reduced no-NootedRed control profile.

Characteristics:

```text
NootedRed disabled
VoodooI2C disabled in control
AirportItlwm disabled in control
reduced ACPI set
verbose boot
```

Purpose:

- determine whether OpenCore/XNU can reach a useful state without NootedRed;
- separate core boot failure from graphics-patching failure.

This was methodologically important even though the control state was not the desired final system.

## Early "Final EFI" branch

Archive:

```text
ThinkPad-T495s-Ventura-Final-EFI.zip
```

It still contained NootedRed and the broader early device stack.

A temporary NootedRed-related argument:

```text
-NRedDPDelay
```

was present.

This branch should not be treated as a final result merely because of the archive name. Later versions replaced it.

## v5 - original-base no-NootedRed control

Archive:

```text
ThinkPad-T495s-Ventura-v5-OriginalBase-NoNootedRed.zip
```

Key state:

```text
NootedRed = disabled
normal broad device stack retained
```

Purpose:

- preserve the original-base EFI while explicitly removing NootedRed;
- establish a reproducible control before reintroducing acceleration.

## v6 - NootedRed accelerated build

Archive:

```text
ThinkPad-T495s-Ventura-v6-NootedRed-Accelerated.zip
```

NootedRed returned, with:

```text
AMDBacklight=0
```

The backlight module was deliberately kept out of the equation while acceleration was being verified.

A major historical dependency lesson came from the earlier log state:

```text
Lilu 1.6.8 loaded
NootedRed requested compatible Lilu 1.7.0
dependency resolution failed
```

The later working pair used:

```text
Lilu 1.7.2
NootedRed 0.9.0
```

## v7 - flat bootable layout

Archive:

```text
ThinkPad-T495s-Ventura-v7-FLAT-BOOTABLE.zip
```

The package was normalized so:

```text
EFI/
  BOOT/
  OC/
```

was directly deployable rather than nested under extra archive directories.

No major new functional claim should be attributed solely to this packaging change.

## v8 - verified accelerated baseline

Archive:

```text
ThinkPad-T495s-Ventura-v8-VERIFIED.zip
```

This became the reference accelerated baseline.

Important methodological role:

```text
later brightness, sleep and input changes could be compared against a known accelerated state
```

GPU acceleration was functional enough for subsequent benchmark work, though later Chrome testing proved the path was not fully stable.

## v9 - wake and PNLF experiment

Archive:

```text
ThinkPad-T495s-Ventura-v9-WAKE-TEST.zip
```

Notable configuration change:

```text
SSDT-PNLF.aml enabled
```

The project began testing whether Apple-style panel/backlight interface exposure improved:

- brightness;
- wake;
- display reinitialization.

The control-plane interface improved, but this did not solve native sleep or continuous hardware brightness.

## v10 - clean diagnostic state

Archive:

```text
ThinkPad-T495s-Ventura-v10-CLEAN-DIAGNOSTIC.zip
```

The package added focused post-install/diagnostic tooling and reduced some experimental clutter.

It retained:

```text
NootedRed
AMDBacklight=0
```

while continuing wake/display investigation.

## v11 - hibernation, brightness and touchpad integration

Archive:

```text
ThinkPad-T495s-Ventura-v11-FINAL-HIBERNATE-BRIGHTNESS-TRACKPAD.zip
```

Major changes:

```text
BrightnessKeys enabled
SSDT-PNLF enabled
AMDBacklight=1
darkwake=0
VoodooI2C removed from active path
PS/2 touchpad path retained/tuned
```

### Brightness

The combination:

```text
NBCF patch
BrightnessKeys
PNLF
AMDBacklight=1
```

established the macOS brightness control plane.

Observed limitation:

```text
physical panel still provided approximately two useful levels
```

This was a key result because it separated control-plane success from hardware-actuation failure.

### Touchpad

The project standardized on the actual Elan PS/2 path.

Important tuning included:

```text
QuietTimeAfterTyping = 0
external mouse suppression disabled
ForceTouchMode = 0
WakeDelay = 100
```

### Hibernation

A hibernation-oriented strategy was tested, including `hibernatemode 25` in the development workflow.

Result:

```text
did not solve reliable resume
```

It was not promoted to production.

## v12 - non-verbose daily profile

Archive:

```text
ThinkPad-T495s-Ventura-v12-NO-VERBOSE.zip
```

Key change:

```text
-v removed from normal boot arguments
```

Diagnostic arguments such as:

```text
keepsyms=1
debug=0x100
```

remained.

This reflects the distinction between:

```text
verbose console output
```

and:

```text
retained panic/debug information
```

## v12 touchscreen bridge branch

Archive:

```text
ThinkPad-T495s-Ventura-v12-TOUCHSCREEN-BRIDGE.zip
```

The touchscreen problem was isolated into a dedicated experimental module.

Target:

```text
VID 1A86
PID E5E3
USB2IIC_CTP_CONTROL
```

The userspace bridge was designed around IOHIDManager rather than modifying the main input stack.

This separation protected the working PS/2 touchpad configuration.

## v13 - brightness range binary experiment

Archive:

```text
ThinkPad-T495s-Ventura-v13-BRIGHTNESS-RANGE-FIX.zip
```

The NootedRed binary was modified at exactly seven bytes:

```text
offset 0x203e - 0x2044
```

Baseline bytes:

```text
89 c1 c1 e1 10 29 c1
```

v13 bytes:

```text
69 c8 00 ff 01 00 90
```

Hashes:

```text
baseline:
ee6cc4b5a58c282556d82391c948d3d5931e0ace1e06df917e807c92c64604a0

v13:
9e73468a843845890edac625a655eb6d0201017ab52292f907c3411b410b6c64
```

Goal:

- alter backlight scaling;
- recover a larger useful physical brightness range.

Result:

```text
no acceptable continuous hardware range
```

The experiment was rejected.

The later v15 NootedRed binary hash returned to the original baseline, confirming reversion.

## v14 - touchscreen internal-hub experiment

Archive:

```text
ThinkPad-T495s-Ventura-v14-TOUCHSCREEN-USB-HUB-FIX.zip
```

Investigation focused on the internal USB topology.

The Genesys hub:

```text
05E3:0610
```

was observed in macOS.

The integrated camera also enumerated.

The target touchscreen:

```text
1A86:E5E3
```

still did not appear.

Result:

```text
parent USB path exists
target child controller remains absent
```

The project did not retain a guessed production USB-map fix for an unseen endpoint.

## v15 - organized power and brightness

Archive:

```text
ThinkPad-T495s-Ventura-v15-POWER-BRIGHTNESS-ORGANIZED.zip
```

Major architectural changes:

- restored upstream NootedRed binary;
- removed the failed v13 PWM modification;
- introduced userspace visual brightness;
- isolated experimental touchscreen;
- introduced lid continuity as an explicit workaround rather than pretending native sleep worked;
- removed `darkwake=0` from the normal boot arguments;
- set `PowerTimeoutKernelPanic=false` in the normal profile.

### v15 gamma bridge design

Source:

```text
T495sBrightnessBridge.m
```

Input:

```text
IODisplayConnect "brightness"
```

Output:

```text
CGSetDisplayTransferByFormula
```

This extended perceived brightness below the panel's physical useful range.

### v15 deployment failure

The first v15 installation attempt failed during compilation:

```text
fatal error:
'ApplicationServices/ApplicationServices.h' file not found
```

The installer also used fail-fast behavior.

Consequences:

```text
brightness bridge not installed
later power-continuity stage also did not execute in that run
```

This is preserved because it prevents a false causal interpretation of behavior observed immediately after the failed installer.

## v16 - installer and bridge build repair

Archive:

```text
ThinkPad-T495s-Ventura-v16-POWER-BRIGHTNESS-INSTALL-FIX.zip
```

The bridge was rewritten in C with:

```text
CoreFoundation
CoreGraphics
IOKit
```

and explicit SDK discovery.

The installer was changed so:

```text
power continuity
brightness bridge
```

reported independent status.

One failed step no longer prevented the other from being attempted.

The gamma approach was now deployable, which enabled a valid stability test.

## v16.1 - startup chime

Archive:

```text
ThinkPad-T495s-Ventura-v16.1-APPLE-CHIME.zip
```

Changes:

```text
AudioDxe.efi enabled
AudioSupport = true
PlayChime = Enabled
```

No brightness or sleep fix was implied by this change.

The chime path is separate from AppleALC runtime audio.

## Native sleep diagnostics before v16.2

Controlled data collection established:

```text
SleepDisabled = 0
sleep entry occurs
repeatable wake does not
```

and preserved earlier successful wake examples.

This shifted the sleep problem from:

```text
is macOS allowed to sleep?
```

to:

```text
which platform/driver path prevents reliable resume?
```

## v16.2 - power-transition diagnostic profile

Archive:

```text
ThinkPad-T495s-Ventura-v16.2-SLEEP-TIMEOUT-DIAGNOSTIC.zip
```

Instrumentation changes:

```text
PowerTimeoutKernelPanic = true
darkwake=0
swd_panic=1
```

Purpose:

- turn an indefinite power-transition stall into a diagnosable timeout/panic when possible.

This was a diagnostic profile, not the final production configuration.

## Gamma bridge and Chrome instability isolation

During later testing:

```text
opening Chrome with the gamma bridge active could freeze the system
```

Disabling the bridge removed that bridge-specific trigger.

The gamma approach was therefore rejected.

Separately, Chrome with hardware acceleration enabled later produced a direct AMD GFX reset/hang even after the bridge issue was isolated.

The project therefore has two distinct graphics-related historical findings:

```text
1. continuous gamma bridge was unsafe
2. accelerated Chrome/NootedRed path is independently unstable
```

## v17 - safe brightness overlay

Archive:

```text
ThinkPad-T495s-Ventura-v17-SAFE-BRIGHTNESS.zip
```

The new helper:

```text
T495sBrightnessOverlay.m
```

retains the macOS brightness property as input but changes the visual-extension mechanism.

Old:

```text
continuous custom gamma transfer formula
```

New:

```text
black click-through AppKit overlay
```

The installer removes the retired bridge and restores ColorSync state.

The current final overlay architecture is documented as:

```text
Implemented, pending sustained target revalidation
```

because its design is present but the public evidence archive does not yet contain a long-duration final-implementation validation run.

## Chrome safe launcher

The repository added:

```text
Tools/Chrome/Launch-Safe.command
```

with:

```text
--disable-gpu
--disable-gpu-compositing
--disable-accelerated-video-decode
```

The machine owner confirmed that Chrome works when graphics acceleration is disabled.

This is a workaround for the primary GPU stability problem.

## v17.1 public GitHub release

Public-release work included:

- sanitized SMBIOS;
- benchmark screenshots;
- focused evidence excerpts;
- pre-boot compatibility documentation;
- brightness history;
- Chrome GPU-reset analysis;
- native sleep timeline;
- input/touchscreen separation;
- installer no-Wi-Fi profile;
- component inventory;
- manifest.

## v17.1 documentation revision 2

This revision does not intentionally change EFI runtime behavior.

Documentation changes include:

- exhaustive status classification;
- removal of emoji/decorative status markers;
- distinction between `Observed working`, `Configured`, `User-confirmed`, `Pending revalidation`, `Unresolved` and `Experimental`;
- exact OpenCore settings;
- exact AMD kernel patch inventory;
- exact kext versions;
- security posture;
- internal USB map;
- Bluetooth/camera enumeration;
- expanded GPU panic evidence;
- expanded sleep confounder/timing analysis;
- exact v13 NootedRed binary-diff record;
- explicit statement that final v17 brightness overlay still requires sustained target revalidation;
- explicit statement that startup chime is configured but archived audibility proof is absent;
- automated public-release validation.

## Current development priorities

Priority 1:

```text
accelerated GPU stability
```

Priority 2:

```text
native suspend/resume
```

Secondary:

```text
final brightness-overlay revalidation
installer Wi-Fi isolation
touchscreen enumeration
formal validation of configured-but-unarchived endpoints
```

The project should not add new cosmetic features before the two primary blockers are understood.
