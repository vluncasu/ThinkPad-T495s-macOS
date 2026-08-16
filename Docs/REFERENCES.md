# References and upstream boundaries

This repository is an integration project. OpenCore, kernel extensions and Apple platform behavior are not redefined here. Upstream documentation and source repositories remain authoritative for their own interfaces, licenses and implementation details.

## Primary upstream projects

| Project | Role in this repository | Upstream |
|---|---|---|
| OpenCorePkg | Bootloader, configuration schema, UEFI runtime, picker and UEFI audio integration | https://github.com/acidanthera/OpenCorePkg |
| Lilu | Kernel patching framework required by multiple macOS compatibility kexts | https://github.com/acidanthera/Lilu |
| VirtualSMC | SMC emulation framework | https://github.com/acidanthera/VirtualSMC |
| AppleALC | Runtime codec patching for ALC257 path | https://github.com/acidanthera/AppleALC |
| NVMeFix | NVMe compatibility/power-management support | https://github.com/acidanthera/NVMeFix |
| VoodooPS2 | Keyboard/touchpad PS/2 stack | https://github.com/acidanthera/VoodooPS2 |
| BrightnessKeys | macOS brightness key event integration | https://github.com/acidanthera/BrightnessKeys |
| RestrictEvents | macOS compatibility/restriction patches | https://github.com/acidanthera/RestrictEvents |
| NootedRed | AMD integrated-GPU enablement and fixes for the Vega 10 path | https://github.com/ChefKissInc/NootedRed |
| SMCRadeonSensors | Radeon sensor reporting | https://github.com/ChefKissInc/SMCRadeonSensors |
| AirportItlwm / itlwm | Intel AX200 Wi-Fi path | https://github.com/OpenIntelWireless/itlwm |
| IntelBluetoothFirmware | Intel Bluetooth firmware path | https://github.com/OpenIntelWireless/IntelBluetoothFirmware |
| ECEnabler | Embedded-controller battery/data access support | https://github.com/1Revenger1/ECEnabler |
| USBToolBox | USB mapping ecosystem used to create/maintain USB maps | https://github.com/USBToolBox |

Exact versions present in this snapshot are listed in [`COMPONENTS.md`](COMPONENTS.md).

## AMD graphics limitation reference

NootedRed itself is an active research/development compatibility layer over Apple's AMD graphics drivers. This repository therefore does not assume that successful Metal initialization implies complete GPU stability.

A relevant upstream issue documents a separate AMD/NootedRed-class wake failure in which a wake transition times out while `IOGraphicsFamily` is executing power-state callbacks:

https://github.com/ChefKissInc/NootedRed/issues/188

That upstream issue is not used as proof that the T495s failure has the same root cause. It is used only as comparative evidence that graphics power-state transitions are a known area of failure in the wider stack. The T495s sleep conclusions are based on its own `pmset` and panic evidence in [`POWER-SLEEP.md`](POWER-SLEEP.md).

## Apple APIs used by project-local code

The v17 brightness overlay uses public macOS frameworks/APIs including:

```text
AppKit
CoreGraphics
IOKit graphics parameters
```

Its relevant architectural operations are:

```text
read IODisplayConnect brightness property
identify built-in display
create non-interactive AppKit overlay window
restore ColorSync settings during migration/start/wake paths
```

The rejected v15/v16 bridge used continuous CoreGraphics display-transfer programming. That design is retained only in the development history and is not part of the current source tree.

See [`BRIGHTNESS.md`](BRIGHTNESS.md).

## OpenCore validation boundary

When changing `config.plist`, consult the configuration documentation and `ocvalidate` shipped with the same OpenCore release as the EFI being maintained. A value accepted by an older or newer OpenCore schema may not be appropriate for the current snapshot.

This repository's Python validator checks structural invariants. It is intentionally not a replacement for OpenCore's own semantic validator.

## Hardware-source boundary

Hardware identifiers in this repository are derived from the target machine's own diagnostic evidence and Windows/macOS enumeration, not from generic model assumptions. Important examples include:

```text
GPU        1002:15D8
Touch      1A86:E5E3
USB hub    05E3:0610
Camera     13D3:5406
Bluetooth  8087:0029
```

When a generic Lenovo specification and captured target-machine evidence disagree, this project documents the captured target-machine evidence.

## Citation policy for this repository

Documentation should distinguish three classes of statement:

1. **Repository fact** - directly derivable from `config.plist`, source code, kext metadata or bundled files.
2. **Target evidence** - directly observed in sanitized logs, benchmark screenshots or explicit target-machine user confirmation.
3. **Upstream context** - behavior described by OpenCore, NootedRed, Apple or another upstream project.

An upstream issue is not sufficient to label a local root cause. A bundled kext is not sufficient to label a feature working. A benchmark is not sufficient to label a subsystem stable.

The evidence model is defined in [`EVIDENCE.md`](EVIDENCE.md) and [`METHODOLOGY.md`](METHODOLOGY.md).
