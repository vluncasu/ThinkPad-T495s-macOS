# T495s v17 visual brightness overlay

## Status

```text
Native macOS brightness control plane: observed working
Continuous physical panel backlight range: unresolved
v17 AppKit overlay implementation: implemented, pending sustained revalidation
v15/v16 continuous gamma bridge: rejected
```

The helper in this directory extends perceived brightness range. It does not create additional hardware PWM levels and must not be described as native backlight control.

## Why the overlay exists

On the target T495s, macOS receives a brightness control path through the ACPI/backlight stack, but the physical panel responds through approximately two useful effective hardware levels.

The native input/control path is retained:

```text
brightness key or macOS slider
        -> IODisplayConnect brightness property
        -> physical panel path
```

The v17 helper reads the same property and adds a visual dimming layer only below a configurable threshold:

```text
native brightness value
        -> T495sBrightnessOverlay
        -> AppKit black overlay alpha
        -> lower perceived luminance
```

## Current implementation

Source:

```text
src/T495sBrightnessOverlay.m
```

Frameworks:

```text
AppKit
CoreGraphics
IOKit
```

Default parameters installed by `Install.command`:

```text
threshold = 0.90
maximum overlay alpha = 0.90
curve exponent = 1.35
poll interval = 250 ms
```

Below the threshold `T`, the implementation derives a normalized dimming progress and maps it through a curve before applying window alpha. Conceptually:

```text
progress = 1 - brightness / T
alpha = maxAlpha * progress^curve
```

The exact implementation, clamping and display-selection behavior are documented in [`../../Docs/BRIGHTNESS.md`](../../Docs/BRIGHTNESS.md).

## Window behavior

The overlay is designed to:

- target the built-in display;
- be borderless and black;
- ignore mouse input;
- remain outside normal window interaction;
- follow all Spaces;
- remain available with full-screen applications;
- be excluded from normal window sharing;
- sit below the screen-saver window level used by the helper.

It is visual software dimming. Backlight power does not necessarily fall proportionally with the perceived luminance.

## ColorSync and gamma boundary

The rejected v15/v16 bridge repeatedly called a CoreGraphics display-transfer API to install custom gamma curves. That design produced useful perceived dimming but was isolated as an instability source and removed.

The v17 running path does **not** continuously call:

```text
CGSetDisplayTransferByFormula
```

However, the current v17 source does call:

```text
CGDisplayRestoreColorSyncSettings()
```

in restoration/migration paths, including startup/wake/session handling and `--restore-only`. This is intentional: it removes custom transfer state that may have been left by the old gamma experiment.

Therefore the precise statement is:

> v17 does not continuously program custom gamma tables; it may restore system ColorSync settings at defined lifecycle points.

## Installation

Run from the repository root:

```bash
./INSTALL.command
```

or directly:

```bash
./Tools/Brightness/Install.command
```

The installer:

1. requires Apple Command Line Tools/Xcode compiler and SDK;
2. compiles the source locally;
3. stops/removes the obsolete gamma bridge;
4. stops an existing overlay instance;
5. installs the new executable under the current user's Application Support directory;
6. invokes `--restore-only` once;
7. writes a per-user LaunchAgent;
8. bootstraps and starts the LaunchAgent.

Installed files:

```text
~/Library/Application Support/T495s/T495sBrightnessOverlay
~/Library/LaunchAgents/com.terabitlab.t495s-brightness-overlay.plist
~/Library/Logs/T495sBrightnessOverlay.log
```

The default repository installer does not modify `pmset` and does not install the historical lid-continuity power workaround.

## Status check

Run:

```bash
./Tools/Brightness/Status.command
```

It reports:

```text
installed binary
LaunchAgent validity/state
running brightness helper process
presence/absence of obsolete gamma bridge
native backlight property excerpt
recent helper log
```

## Disable immediately

For regression isolation:

```bash
./Tools/Brightness/Disable.command
```

This unloads the current and obsolete agents where present, terminates both helper process names and performs a restoration call through the current binary when available.

Native macOS brightness handling remains available after the overlay is disabled.

## Re-enable

```bash
./Tools/Brightness/Enable.command
```

This requires the v17 LaunchAgent to have been installed first.

## Required revalidation

Do not promote the v17 overlay to `Observed working` until the target machine has passed a sustained test that includes at least:

```text
repeated brightness changes
Chrome in the intended graphics mode
full-screen application transitions
Space changes
screen lock/unlock
external-display connect/disconnect if used
sleep/wake tests when native sleep work resumes
multi-hour normal desktop use
no new WindowServer/GPU hangs attributable to the helper
```

The current repository deliberately records the implementation as pending revalidation.
