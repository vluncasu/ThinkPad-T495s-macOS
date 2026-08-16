# OpenCore boot picker

## Current design

The picker is intentionally keyboard-first.

Enabled components:

```text
OpenCanopy.efi
Ps2KeyboardDxe.efi
ResetNvramEntry.efi
```

Current boot settings:

```text
PickerMode = External
ShowPicker = true
HideAuxiliary = true
PollAppleHotKeys = true
Timeout = 5
PickerAttributes = 17
```

## Normal keyboard interaction

```text
Arrow keys  - change selection
Enter       - boot selected entry
Space       - reveal auxiliary entries
```

Auxiliary entries may include:

```text
Recovery
Reset NVRAM
OpenShell
```

depending on the current filesystem/tools state.

## Removed pre-boot mouse experiment

An earlier PS/2 mouse DXE path produced inverted pointer behavior in the picker.

That experiment was removed.

Reason:

- the keyboard path was already reliable;
- a broken pointer adds pre-boot complexity;
- macOS touchpad behavior is handled by a different driver stack after kernel boot.

The pre-boot pointer problem therefore has no direct implication for the VoodooPS2 touchpad inside macOS.

## HFS and runtime support

Other enabled drivers:

```text
HfsPlus.efi
OpenRuntime.efi
```

These are part of the boot environment rather than picker input.

## Audio

`AudioDxe.efi` is also enabled for the pre-boot chime.

It should not alter the picker input architecture.

## Reset NVRAM

`ResetNvramEntry.efi` exposes an auxiliary reset function.

Use it intentionally.

The current NVRAM delete configuration includes `boot-args`, so a reset/configuration change can alter the effective boot argument state.

## Launcher

Current:

```text
LauncherOption = Full
LauncherPath = Default
```

This is recorded as the current configuration, not a universal recommendation.

## Picker regression test

After any OpenCore/driver update:

1. cold boot;
2. picker appears;
3. arrow keys work;
4. Enter works;
5. Space reveals auxiliary entries;
6. Recovery appears if present;
7. Reset NVRAM entry appears;
8. startup chime attempt does not stall input;
9. Ventura boots;
10. return to picker on reboot.

Do not reintroduce the pre-boot mouse merely for cosmetic parity unless it is independently validated.
