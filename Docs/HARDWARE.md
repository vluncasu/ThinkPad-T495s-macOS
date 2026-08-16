# Target hardware

## Scope

This repository targets one validated machine family and one known machine type.

```text
Lenovo ThinkPad T495s
Machine type: 20QK
BIOS: R13ET56W 1.30
```

A T495s with different panel, WLAN, touch controller, firmware revision, storage controller behavior or board routing must be treated as a different validation target until tested.

## CPU

```text
AMD Ryzen 7 PRO 3700U
Architecture generation: Picasso / Zen+
Cores: 4
Threads: 8
Nominal frequency shown by Cinebench: 2.3 GHz
Single-core boost shown by Cinebench: 3.3 GHz
```

The CPU is not natively supported as an Apple platform processor. The project therefore depends on the AMD XNU patch set and support kexts documented elsewhere.

## Graphics

```text
AMD Radeon Vega 10
PCI vendor: 0x1002
PCI device: 0x15D8
Revision reported by macOS: 0x00D1
Reported VRAM: 2 GB
ROM version reported by macOS: 113-PICASSO-117
```

macOS reports Metal support and uses the Apple AMD graphics stack after NootedRed initialization.

## Memory

```text
16 GB DDR4-2400
```

No memory-overclocking assumptions are part of this repository.

## Internal display

Observed macOS output:

```text
Resolution: 1920 x 1080
Refresh rate: 60 Hz
Built-in: yes
Online: yes
Framebuffer color depth: 30-bit / ARGB2101010 in captured profiler output
Automatic brightness: no
```

Panel identification collected during development:

```text
InfoVision
IVO057D
R140NWF5 RG
1920 x 1080
```

The panel/backlight does not respond as a normal Apple laptop panel across the full macOS brightness range. See `BRIGHTNESS.md`.

## Audio

```text
Codec: Realtek ALC257
Runtime path: AppleALC
Layout: 97
```

The OpenCore UEFI chime uses a separate pre-boot audio path.

## Wi-Fi

```text
Intel AX200
Runtime macOS path: AirportItlwm
```

Post-install use is user-confirmed. Installer-stage Wi-Fi remains a known problem.

## Bluetooth

Captured USB enumeration:

```text
Product: Bluetooth USB Host Controller
Vendor: 0x8087
Product: 0x0029
Built-in: yes
```

The production stack contains:

```text
IntelBTPatcher.kext
IntelBluetoothFirmware.kext
BlueToolFixup.kext
```

## Ethernet

```text
Realtek RTL8111 family
Driver: RealtekRTL8111.kext
```

## NVMe storage

Development records identify a Crucial/Micron P3 Plus family NVMe device. The installed system boots successfully from NVMe. `NVMeFix.kext` is included.

## Keyboard and touchpad

Keyboard and pointing-device path:

```text
PS/2
VoodooPS2Controller
VoodooPS2Keyboard
VoodooPS2Trackpad
VoodooInput
```

Touchpad identification:

```text
Elan PS/2 v4
macOS-side class observed during development: ApplePS2Elan
```

The active production configuration does not use VoodooI2C for the touchpad.

## Touchscreen

Windows-side device identity:

```text
USB2IIC_CTP_CONTROL
VID: 0x1A86
PID: 0xE5E3
```

This target is not present in the captured macOS IOUSB/IOHID enumeration.

## Internal USB topology relevant to touch investigation

Captured macOS USB profiler:

```text
AMD USB controller
  HS02
    Genesys Logic USB2.0 Hub
    VID: 0x05E3
    PID: 0x0610
    Built-In: yes
      Integrated Camera
      VID: 0x13D3
      PID: 0x5406
```

A separate Intel Bluetooth controller enumerates as `8087:0029`.

The hub enumeration proves that the parent internal USB path exists in macOS. It does not prove that the missing touchscreen endpoint is exposed to macOS.

## Integrated camera

Captured enumeration:

```text
Product: Integrated Camera
Vendor: AzureWave
VID: 0x13D3
PID: 0x5406
USB 2.0
Built-In: yes
```

Enumeration is documented. A dedicated FaceTime/AVFoundation application test is not archived.

## Firmware constraints

The BIOS UI on the target machine is simplified. The photographed `Config -> Power` page exposes:

```text
AMD PowerNow! technology
Mode for AC
Mode for Battery
Adaptive Thermal Management
CPU Power Management
Power On with AC Attach
Disable Built-in Battery
```

No selectable Linux S3 / Windows Modern Standby mode is exposed in that firmware UI.

Documentation must therefore not instruct this specific machine to select a BIOS option that is absent.

## Hardware changes and portability

Do not assume direct portability if any of these differ:

- machine type;
- BIOS/EC revision;
- display panel;
- touch controller;
- WLAN card;
- audio codec routing;
- NVMe model;
- USB daughterboard/topology.

The repository is an engineering record for the tested target, not a universal T495s hardware abstraction.
