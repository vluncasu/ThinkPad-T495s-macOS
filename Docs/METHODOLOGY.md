# Engineering and validation methodology

## Objective

The project uses controlled comparison rather than accumulating patches until a symptom disappears.

A feature is considered validated only when the relevant layer has been exercised on the target hardware.

## Validation levels

### Level 0 - present in repository

Example:

```text
AppleALC.kext exists
```

Conclusion allowed:

```text
component is bundled
```

### Level 1 - configured

Example:

```text
AppleALC enabled
alcid=97
```

Conclusion allowed:

```text
runtime audio path is configured
```

### Level 2 - enumerated/loaded

Example:

```text
Intel Bluetooth USB controller appears
IntelBluetoothFirmware matches
```

Conclusion allowed:

```text
controller enumerates and driver stack loads
```

### Level 3 - function exercised

Example:

```text
Geekbench Metal completes
```

Conclusion allowed:

```text
Metal acceleration functions for that workload
```

### Level 4 - repeated workload stability

Example:

```text
Chrome accelerated browsing for one hour with no reset
```

Not currently achieved for the GPU.

### Level 5 - lifecycle stability

Includes:

```text
boot
lock/unlock
display sleep
native system sleep
wake
battery/AC transitions
```

Not currently achieved for graphics/power.

## Core experimental rule

Change one subsystem at a time.

Bad experiment:

```text
update NootedRed
change ACPI
change USB map
change Wi-Fi
change pmset
```

then test sleep once.

Good experiment:

```text
known baseline
one change
defined trigger
defined control
diagnostics
revert or retain
```

## Control configuration

The project deliberately created no-NootedRed and verified accelerated baselines.

That allows separation of:

```text
boot failure
```

from:

```text
graphics enablement failure
```

and later:

```text
graphics stability failure
```

## Negative results are retained

Rejected experiments remain in the history because they reduce repeated work.

Examples:

- VoodooI2C path for a PS/2 touchpad;
- v13 NootedRed PWM binary patch;
- v15/v16 continuous gamma brightness bridge;
- hibernation as a sleep substitute;
- pre-boot PS/2 mouse pointer;
- guessed touchscreen USB-path changes without actual device enumeration.

## Cause versus correlation

A component appearing in a panic backtrace is not automatically the root cause.

For example:

```text
AMDRyzenCPUPowerManagement
SMCProcessorAMD
```

appear in secondary collected panics.

The project does not remove them solely on that basis because independent reproduction is missing.

By contrast, the Chrome graphics evidence is stronger because it contains:

```text
application = Google Chrome Helper
SubmitContext = Metal
GFX channel timeout
GPU reset
```

and matches the user-visible trigger.

## Workaround terminology

A workaround must not be documented as a native fix.

Examples:

```text
Chrome --disable-gpu
```

is:

```text
workload containment
```

not:

```text
GPU driver fix
```

Historical lid continuity is:

```text
display/session continuity while suspend is prevented
```

not:

```text
sleep fix
```

v17 brightness overlay is:

```text
perceived-luminance extension
```

not:

```text
continuous hardware PWM
```

## Failure reproduction template

Every reproducible failure should record:

```text
hardware
BIOS
macOS build
EFI/repository version
boot arguments
relevant kext versions
trigger
expected behavior
actual behavior
whether forced restart was required
diagnostic artifact
control experiment
```

## GPU experiment protocol

Baseline:

```text
retired gamma bridge disabled
known NootedRed/Lilu pair
```

Trigger:

```text
Chrome graphics acceleration enabled
```

Control:

```text
Chrome graphics acceleration disabled
```

Required output:

```text
gpuRestart
panic
WindowServer/kernel log
display profiler
loaded kext list
```

## Brightness experiment protocol

Separate:

```text
control path
hardware panel response
userspace visual extension
```

Do not judge all three with one statement.

Required observations:

```text
brightness property value
physical screen luminance behavior
helper state
Chrome stability
ColorSync state after uninstall
```

## Sleep experiment protocol

Remove confounders where possible:

```text
Screen Sharing
external USB storage
dock
HDMI
```

Capture:

```text
pmset settings
assertions
sleep entry
wake record
driver delays
panic/timeout
```

Do not classify black screen alone as "system did not wake" until remote reachability or power logs are checked.

## Touchscreen experiment protocol

Required order:

```text
1. physical device identity
2. USB enumeration
3. HID enumeration
4. element descriptors
5. coordinate values
6. userspace bridge
```

Never install the bridge before steps 2-4.

## Installer profile discipline

The installer no-Wi-Fi profile has one intended functional difference:

```text
AirportItlwm Enabled true -> false
```

The validation script checks this invariant to prevent accidental drift.

## Publication discipline

Public releases require:

```text
SMBIOS sanitization
private-log sanitization
plist parsing
Markdown local-link validation
manifest rebuild
ZIP integrity test
post-extract validation
```

## Promotion criteria

A status can be promoted only with evidence.

Examples:

```text
Configured -> Observed working
```

requires actual function exercise.

```text
Implemented, pending revalidation -> Observed working
```

requires sustained final-implementation testing.

```text
Unresolved -> Solved
```

requires removal of the native failure without relying on a workaround that bypasses the feature.

## Reversion rule

If an experiment:

- does not improve the target symptom;
- creates a new regression;
- cannot be explained;
- reduces stability;

it should be reverted to the last validated baseline.

That rule caused the project to revert:

- v13 NootedRed binary modification;
- continuous gamma bridge;
- automatic lid-continuity installation.
