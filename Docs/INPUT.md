# Keyboard, touchpad and pointing input

## Current production path

The target machine uses a PS/2 input stack for the built-in keyboard and Elan touchpad.

Active OpenCore entries:

```text
VoodooPS2Controller.kext
VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext
VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext
VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext
```

The current production EFI does not load VoodooI2C for the touchpad.

## Why the I2C path was removed

Earlier configurations included VoodooI2C-related components while the actual built-in touchpad on this machine was subsequently identified as an Elan PS/2 device.

Maintaining an unrelated I2C touchpad path:

- added unnecessary driver overlap;
- complicated failure attribution;
- created the possibility of conflicting input ownership.

The later design therefore reduced the input stack to the actual hardware path.

## Touchpad identity

Development observations:

```text
Elan PS/2 v4
macOS-side class: ApplePS2Elan
firmware identifier observed during development: 5f3001
```

This is separate from the touchscreen. The touchscreen uses a different USB/HID target and is documented in `TOUCHSCREEN.md`.

## Active Elantech profile tuning

The current `VoodooPS2Trackpad.kext` Elantech profile contains:

```text
ForceTouchMode = 0
MouseSampleRate = 200
ProcessBluetoothMouseStopsTrackpad = false
ProcessUSBMouseStopsTrackpad = false
QuietTimeAfterTyping = 0
ScrollResolution = 400
TrackpointMultiplierX = 120
TrackpointMultiplierY = 120
USBMouseStopsTrackpad = 0
UseHighRate = true
WakeDelay = 100
```

## Rationale for each setting

### `ForceTouchMode = 0`

No Force Touch emulation is forced for the physical Elan device.

This avoids pretending the hardware has a pressure/Force Touch capability that is not part of the validated input path.

### `QuietTimeAfterTyping = 0`

The original user experience included an unwanted touchpad dead period after keyboard activity.

Setting the quiet time to zero removes the VoodooPS2 post-typing suppression interval.

The goal is:

```text
typing
immediate pointer/touchpad response
```

rather than:

```text
typing
fixed suppression delay
touchpad resumes later
```

### External mouse suppression flags

```text
ProcessBluetoothMouseStopsTrackpad = false
ProcessUSBMouseStopsTrackpad = false
USBMouseStopsTrackpad = 0
```

The touchpad should not be automatically disabled merely because an external USB or Bluetooth mouse is present.

### `UseHighRate = true`

Uses the higher-rate Elantech input path supported by the profile.

### `MouseSampleRate = 200`

Configures the profile's sample-rate target.

This number is a driver setting, not a measured end-to-end macOS pointer polling benchmark.

### `ScrollResolution = 400`

Controls the profile's scroll-resolution behavior.

### TrackPoint multipliers

```text
TrackpointMultiplierX = 120
TrackpointMultiplierY = 120
```

These are configuration values for TrackPoint motion scaling.

The presence of the values is documented. A dedicated quantitative TrackPoint test artifact is not archived.

### `WakeDelay = 100`

Configures a short driver wake delay used during input reinitialization.

This setting does not solve the platform's native system sleep problem.

## macOS user preferences installed by the project

`Tools/Install.command` writes:

```text
com.apple.AppleMultitouchTrackpad:
  Clicking = true
  TrackpadRightClick = true
  TrackpadCornerSecondaryClick = 2
  ForceSuppressed = true

com.apple.driver.AppleBluetoothMultitouch.trackpad:
  Clicking = true
  TrackpadRightClick = true
  TrackpadCornerSecondaryClick = 2

NSGlobalDomain:
  com.apple.mouse.tapBehavior = 1
```

The same tap behavior is also written to the current host domain.

Then:

```text
cfprefsd
```

is restarted to reload preferences.

## Why macOS preferences are used even with VoodooPS2

VoodooPS2 exposes the pointing device into macOS.

macOS still maintains user-level interpretation/preferences for behaviors such as:

- tap-to-click;
- secondary click;
- corner behavior.

Therefore driver tuning and user preference tuning are separate layers.

## Right-click behavior

The project enables:

```text
TrackpadRightClick = true
TrackpadCornerSecondaryClick = 2
```

This supports a practical secondary-click configuration without introducing a custom userspace mouse-event daemon.

## Boot-picker input

The OpenCore picker uses:

```text
Ps2KeyboardDxe.efi
```

for pre-boot keyboard input.

The stable interaction is keyboard-first:

```text
arrow keys
Enter
Space for auxiliary entries
```

A pre-boot PS/2 mouse driver experiment produced inverted pointer behavior and was removed.

This pre-boot decision is independent of the macOS VoodooPS2 touchpad path.

## Validation status

| Function | Status |
|---|---|
| Built-in keyboard | Observed working |
| Elan touchpad | User-confirmed working |
| Tap-to-click preferences | Implemented |
| Secondary click preferences | Implemented |
| Post-typing suppression removal | Configured |
| External mouse suppression disabled | Configured |
| Force Touch | Intentionally disabled |
| TrackPoint path | Configured; dedicated validation artifact not archived |
| Pre-boot mouse | Removed |
| Touchscreen | Separate experimental subsystem |

## Regression test

After any VoodooPS2 update:

1. boot;
2. type continuously for 30 seconds;
3. move pointer immediately after final keystroke;
4. test single-finger pointer movement;
5. test two-finger scrolling;
6. test tap-to-click;
7. test secondary click;
8. attach USB mouse and verify touchpad remains active;
9. attach Bluetooth mouse and verify touchpad remains active;
10. test TrackPoint and physical buttons separately;
11. lock/unlock session;
12. after native sleep becomes available, test wake.

Do not update the PS/2 stack solely to obtain a newer version number without repeating these tests.
