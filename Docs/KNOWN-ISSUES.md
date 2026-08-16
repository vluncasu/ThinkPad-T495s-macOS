# Known issues

## Severity 1 - accelerated GPU instability

Status:

```text
Unresolved
```

Symptoms:

- severe graphical artifacts in accelerated Chrome;
- Chrome can stop responding;
- entire machine can stop responding;
- captured macOS GPU reset;
- `AMDRadeonX5000` GFX channel timeout/hang;
- related panic reports in AMD graphics diagnosis/restart path.

Control:

```text
Chrome with hardware acceleration disabled
```

is user-confirmed functional.

Workaround:

```bash
Tools/Chrome/Launch-Safe.command
```

Do not describe the workaround as a native GPU fix.

## Severity 2 - native suspend/resume

Status:

```text
Unresolved
```

Observed:

- native sleep entry;
- at least one successful HID-triggered wake;
- controlled sleep that did not record a completed wake before restart.

The current release does not provide reliable close-lid sleep.

Historical lid continuity is not native sleep.

Do not place the closed laptop in a bag assuming it suspended.

## Brightness - no continuous physical backlight range

Status:

```text
Scoped hardware-control limitation
```

The macOS brightness control plane works, but the panel responds through approximately two useful physical levels.

The v17 visual overlay is a userspace perceived-luminance extension and is pending sustained target revalidation.

## Wi-Fi during macOS installer

Status:

```text
Known installer-stage issue
```

Symptoms:

- Intel Wi-Fi may not work in installer;
- AirportItlwm path can crash/destabilize installer.

Mitigation:

```text
EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

Use Ethernet or an offline installer.

After installation, return to the normal profile.

## Touchscreen not enumerated

Status:

```text
Experimental / blocked
```

Expected target:

```text
VID 0x1A86
PID 0xE5E3
USB2IIC_CTP_CONTROL
```

Captured macOS result:

```text
not present in IOUSB
not matched in IOHID
```

The userspace bridge cannot operate until enumeration succeeds.

## Startup chime validation incomplete

Status:

```text
Configured
```

UEFI audio is enabled, but the public evidence set does not contain a formal audibility result.

Do not claim audible chime based only on `AudioSupport=true`.

## Audio endpoint validation incomplete

Status:

```text
Configured
```

AppleALC/ALC257 layout 97 is configured.

The public evidence archive does not contain a full speaker/headphone/microphone matrix.

## Ethernet validation incomplete

Status:

```text
Configured
```

RealtekRTL8111 is present.

No formal throughput or wake-reconnect test is archived.

## SD card validation incomplete

Status:

```text
Configured
```

EmeraldSDHC is present.

No formal card read/write test is archived.

## Bluetooth long-duration validation incomplete

Status:

```text
Configured and enumerated
```

The Intel USB controller and firmware stack appear.

Formal pairing/reconnect/sleep reliability is not archived.

A slow Bluetooth sleep acknowledgement was recorded during a failed native-sleep test. It is an observation, not a proven cause.

## Secondary panic observations

Two collected panic reports include AMD CPU/SMC helper paths.

Status:

```text
Diagnostic observation
```

They are not currently classified as a third primary problem because independent reproduction is absent.

## BIOS sleep-state selector absent

The target firmware UI does not expose the Linux S3/Windows sleep-state selector sometimes described in generic ThinkPad guidance.

Do not instruct this target user to change a setting that is not present.

## Public SMBIOS is intentionally invalid

The repository public identifiers are placeholders.

If copied unchanged, Apple services behavior should not be expected to represent a properly personalized production EFI.
