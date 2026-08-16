# Storage, USB and SD subsystem

## NVMe

The target macOS installation operates from NVMe storage.

Development hardware identification points to a Crucial/Micron P3 Plus family device.

The production EFI contains:

```text
NVMeFix.kext 1.1.1
```

Current validation status:

```text
boot/storage path: observed working
formal long-duration SMART/thermal/power benchmark: not archived
```

## USB map

The production EFI contains a hardware-specific:

```text
USBMap.kext
CFBundleShortVersionString = 1.1
model = MacBookPro16,3
```

The map defines multiple controller personalities.

## XHC0 mapping

```text
HS01  UsbConnector=9   port=1
HS02  UsbConnector=3   port=2
HS03  UsbConnector=3   port=3
HS04  UsbConnector=9   port=4
SS01  UsbConnector=9   port=5
SS02  UsbConnector=3   port=6
SS03  UsbConnector=3   port=7
SS04  UsbConnector=9   port=8
```

## XHC1 mapping

```text
HS01  UsbConnector=255  port=1
HS02  UsbConnector=255  port=2
SS01  UsbConnector=255  port=3
```

## Additional controller personality

A separate personality matching PCI debug identity `3:0:4` maps:

```text
PRT1
UsbConnector=0
port=1
```

These are configured values, not a generalized Lenovo port schema.

## Captured internal hub

macOS enumerates:

```text
USB2.0 Hub
Genesys Logic
VID 0x05E3
PID 0x0610
Built-In: yes
Speed: 480 Mb/s
```

The hub appears behind the AMD XHCI path.

## Integrated camera

Captured child:

```text
Integrated Camera
AzureWave
VID 0x13D3
PID 0x5406
Built-In: yes
Speed: 480 Mb/s
```

This proves USB enumeration.

It does not constitute an application-level camera quality or microphone test.

## Bluetooth USB

Separate captured device:

```text
Bluetooth USB Host Controller
Intel
VID 0x8087
PID 0x0029
Built-In: yes
```

## External storage evidence

A USB 3 mass-storage device was captured during diagnostics:

```text
Phison Electronics
VID 0x13FE
PID 0x5500
Speed: up to 5 Gb/s
```

The device was mounted and generated an `ExternalMedia` power assertion.

This is evidence that external USB storage enumeration works.

It is also why clean sleep tests should remove external storage.

## Touchscreen relevance

The internal hub and camera enumerate, but:

```text
1A86:E5E3
```

does not.

This is a critical distinction.

The existence of the parent hub does not prove that the touchscreen child is electrically/logically exposed to macOS.

See `TOUCHSCREEN.md`.

## USB and sleep

USB topology affects sleep because:

- mounted media can hold power assertions;
- internal devices may have wake capability;
- incorrect connector types can affect power handling;
- Bluetooth is itself a USB device on this target.

Future native sleep testing should therefore be repeated with:

```text
all external USB devices disconnected
```

before modifying ACPI or graphics.

## SD reader

The EFI includes:

```text
EmeraldSDHC.kext 0.1.2
```

This establishes the intended SD host-controller support path.

The public evidence archive does not contain a dedicated read/write test, so status remains:

```text
Configured
```

rather than:

```text
Observed working
```

## Storage/USB acceptance tests

### NVMe

1. repeated cold boot;
2. APFS read/write;
3. 20 GB sequential file copy;
4. temperature monitoring;
5. idle;
6. display sleep;
7. native sleep once repaired;
8. no NVMe timeout panic.

### USB

1. every physical USB-A/USB-C port at USB 2 speed;
2. every SuperSpeed path;
3. hot-plug;
4. mass storage;
5. HID device;
6. internal camera;
7. Bluetooth;
8. sleep/wake.

### SD

1. insertion detection;
2. read;
3. write;
4. eject;
5. reinsert;
6. sleep/wake.

Only after those tests should the corresponding rows in `STATUS.md` be promoted.
