# Experimental T495s touchscreen path

This directory is intentionally excluded from the default production install path.

## Target identity

Windows-side hardware evidence identifies the touchscreen controller as:

```text
Product: USB2IIC_CTP_CONTROL
VID: 0x1A86
PID: 0xE5E3
```

## Current blocking condition

Focused macOS probes observed the internal USB hub but did **not** observe the target touchscreen controller in IOUSB or IOHID.

Observed internal USB devices include:

```text
Genesys Logic hub  05E3:0610
AzureWave camera    13D3:5406
Intel Bluetooth     8087:0029
```

The touchscreen target `1A86:E5E3` did not match.

Therefore the production EFI does not claim touchscreen support and does not blindly add a touchscreen-specific USB-map entry.

## Probe first

Run:

```bash
./Experimental/Touchscreen/01-PROBE-TOUCHSCREEN.command
```

The HID probe waits for an exact VID/PID match.

Do not proceed to bridge installation unless the probe reports the target device.

## Userspace bridge design

The experimental bridge is designed to:

1. open IOHIDManager;
2. match VID `1A86`, PID `E5E3`;
3. inspect X/Y GenericDesktop axes;
4. read touch state from Digitizer TipSwitch or the implemented fallback element;
5. normalize logical HID coordinates to the built-in display bounds;
6. optionally apply swap/invert transforms;
7. synthesize pointer movement/down/drag/up through CoreGraphics events.

This is a compatibility experiment, not a native macOS multitouch digitizer driver.

The bridge also requires Accessibility permission to synthesize pointer events.

## Why the bridge is currently blocked

A userspace HID bridge cannot communicate with a controller that macOS does not enumerate.

The current dependency chain is therefore:

```text
physical USB/I2C controller enumeration
-> IOUSB presence
-> IOHID device creation
-> exact VID/PID match
-> HID element discovery
-> userspace coordinate bridge
```

The project is blocked at the first/second stage, before actual touch-event translation.

## Production safety rule

Do not change the main USB map solely because Windows reports `1A86:E5E3`.

Require macOS-side evidence showing:

```text
controller enumerates
port can be identified
enumeration survives reboot
camera/Bluetooth/external USB remain unaffected
```

before promoting any touchscreen USB-map change.

Full research record: [`../../Docs/TOUCHSCREEN.md`](../../Docs/TOUCHSCREEN.md).
