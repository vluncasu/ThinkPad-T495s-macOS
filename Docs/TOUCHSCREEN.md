# Experimental touchscreen investigation

## Current conclusion

The touchscreen is not part of the production input stack.

The target controller is known from Windows-side hardware information, but it is not enumerated by macOS in the captured USB/HID evidence.

Current status:

```text
hardware target identified
internal USB parent path observed
target controller not enumerated
userspace bridge implemented experimentally
production installation disabled
```

## Target controller

Known identity:

```text
USB2IIC_CTP_CONTROL
VID = 0x1A86
PID = 0xE5E3
```

The panel is associated with the internal display assembly, but the touch interface is a distinct input device and must not be confused with the display framebuffer or PS/2 touchpad.

## Internal USB topology

Captured macOS USB profiler shows:

```text
USB 3.1 Bus
  AMD XHCI
    USB2.0 Hub
      VID 0x05E3
      PID 0x0610
      Genesys Logic
      Built-In: yes
        Integrated Camera
          VID 0x13D3
          PID 0x5406
```

Captured IORegistry includes the hub under an ACPI path ending in:

```text
XHC1 / RHUB / PRT2
```

and a child-port path involving:

```text
PR21
```

The exact internal topology was investigated because a missing USB map entry could prevent a built-in child device from appearing.

## Probe result

The focused probe summary states:

```text
Expected: VID 0x1A86 / PID 0xE5E3 / USB2IIC_CTP_CONTROL
RESULT: TOUCHSCREEN IS STILL NOT ENUMERATED BY macOS
```

The userspace probe logs:

```text
IOHIDManagerOpen: 0x00000000
waiting for VID 0x1A86 PID 0xE5E3
```

No matching device callback was captured.

This means:

- the HID manager opened successfully;
- the userspace code was capable of waiting for the target;
- the target device was not presented by macOS.

## Why a userspace bridge cannot solve enumeration

The bridge operates after IOKit has created an HID device.

Required sequence:

```text
physical controller
  -> USB controller
  -> macOS USB enumeration
  -> HID device
  -> IOHIDManager match
  -> bridge input callbacks
```

Current failure occurs before:

```text
IOHIDManager match
```

Therefore the bridge cannot create or rescue the missing device.

## Experimental module

Directory:

```text
Experimental/Touchscreen/
```

Contents:

```text
01-PROBE-TOUCHSCREEN.command
02-INSTALL-TOUCHSCREEN-BRIDGE.command
03-UNINSTALL.command
TouchscreenBridge.m
settings.plist
README.md
```

## Bridge matching

The source matches exactly:

```text
Vendor ID = 0x1A86
Product ID = 0xE5E3
```

using:

```text
IOHIDManager
```

It does not bind generically to every pointer or digitizer.

## HID element model

The bridge looks for:

```text
Generic Desktop / X
Generic Desktop / Y
Digitizer / TipSwitch
Digitizer usage 0x33 as fallback
Button page usage 1 as fallback
```

For X/Y it records:

```text
logical minimum
logical maximum
current value
```

and normalizes into a 0..1 coordinate range.

## Display mapping

The bridge selects the built-in display where possible:

```text
CGDisplayIsBuiltin
```

and maps normalized coordinates into the physical `CGDisplayBounds`.

## Optional transforms

`settings.plist` supports:

```text
SwapXY
InvertX
InvertY
```

Defaults are false.

These exist because HID digitizer orientation may not match display orientation.

They are calibration transforms, not enumeration fixes.

## Pointer synthesis

The bridge translates touch contact into mouse-like CoreGraphics events:

```text
touch begins:
  mouse moved
  left mouse down

touch moves:
  left mouse dragged

touch ends:
  left mouse up
```

This is a pointer bridge.

It is not a native macOS multitouch digitizer driver and does not expose Apple's full trackpad/gesture semantics.

## Accessibility requirement

Non-probe mode checks:

```text
AXIsProcessTrustedWithOptions
```

because synthesized global input events require Accessibility permission.

This permission requirement is another reason the bridge is explicitly userspace and experimental.

## Probe-only mode

With:

```text
--probe-only
```

the code:

- opens IOHIDManager;
- waits for the exact VID/PID;
- dumps matched HID elements;
- logs input values;
- terminates after approximately 20 seconds.

This mode does not synthesize pointer events.

## Why the production USB map was not modified blindly

The internal Genesys hub already enumerates in macOS.

Adding a guessed touchscreen port without seeing the actual child device could:

- misclassify a physical port;
- affect USB power behavior;
- create sleep/wake side effects;
- exceed or distort the intended map;
- make later diagnosis harder.

The production map is therefore not modified solely to satisfy an expected but unseen VID/PID.

## Next valid investigation steps

Only evidence-driven steps are justified:

1. verify the touch controller is enabled in BIOS/firmware under another OS;
2. compare Windows USB tree and ACPI path;
3. cold boot Windows and macOS to check firmware-initialization dependency;
4. inspect whether the controller is actually USB, I2C behind a bridge, or conditionally enabled;
5. compare XHCI port status with and without Windows initialization;
6. capture Linux `lsusb`, `dmesg`, ACPI and HID descriptors if available;
7. only modify USB mapping after a physical child endpoint is identified;
8. install the userspace bridge only after macOS shows the target HID.

## Acceptance criteria

Touchscreen can move from experimental to supported only if:

1. `1A86:E5E3` is visible in macOS IOKit;
2. HID elements are stable across boots;
3. touch coordinates map correctly;
4. clicks/drags work;
5. sleep/wake does not regress;
6. USB map remains stable;
7. no conflict exists with the PS/2 touchpad;
8. installation no longer requires manual exploratory steps.

Current result:

```text
blocked at device enumeration
```
