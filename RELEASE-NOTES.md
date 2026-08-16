# Release notes - ThinkPad T495s Hackintosh v17.1 | macOS Ventura + Radeon Vega 10

OpenCore EFI and complete engineering documentation for the Lenovo ThinkPad T495s (AMD Ryzen 7 PRO 3700U, Radeon Vega 10 mobile) running macOS Ventura 13.7.8 with GPU acceleration via NootedRed.

This package is a documentation, reproducibility and public-release audit of the v17.1 T495s snapshot. It does not claim a new GPU or native-sleep fix.

## Scope

The release freezes the current technical state in a form suitable for a public engineering repository:

- exact target hardware;
- exact OpenCore/ACPI/kext configuration;
- exact evidence boundaries;
- complete development history;
- current workarounds;
- rejected experiments;
- unresolved failures;
- public-identifier sanitization;
- automated repository validation.

## Current primary blockers

### 1. Accelerated GPU stability

Vega 10 framebuffer and Metal are operational through NootedRed, but accelerated Chrome has produced a captured AMD GFX-channel hang and complete system unresponsiveness.

The documented containment path is Chrome with hardware acceleration disabled. This is user-confirmed functional but is not a GPU-driver fix.

### 2. Native sleep/resume

Sleep entry and some successful wake transitions are present in the evidence, but repeatable native suspend/resume and normal lid-close/open behavior are not established.

The historical lid-continuity mechanism deliberately prevents suspend and must not be described as native sleep.

## Brightness status

The repository now documents brightness as three separate layers:

1. macOS control plane: exposed and responsive;
2. physical backlight response: approximately two useful effective hardware levels;
3. v17 visual extension: AppKit overlay, implemented and pending sustained revalidation.

The rejected v15/v16 continuous gamma bridge is fully documented because disabling it isolated a bridge-specific freeze. The v17 source does not continuously write custom display transfer curves.

## Touchpad

The current input path is Elan PS/2 through VoodooPS2. VoodooI2C is not the production touchpad path. Tuning values, tap/click preferences and picker-input history are documented.

## Touchscreen

The Windows-side touchscreen is identified as `USB2IIC_CTP_CONTROL`, VID `1A86`, PID `E5E3`.

macOS probes do not enumerate the target in IOUSB or IOHID. The userspace bridge therefore remains experimental and is not installed by default.

## Installer Wi-Fi

Intel AX200 is user-confirmed functional after installation. During the macOS installer, AirportItlwm can be unavailable or destabilize/crash the environment.

A dedicated profile is included:

```text
EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

Its intended functional difference from the normal public profile is only:

```text
AirportItlwm.kext -> Enabled = false
```

## Benchmarks

Included and documented:

```text
Cinebench R23 multi-core: 3141
Geekbench Metal: 11179
Geekbench Metal: 5164
Geekbench CPU: no standalone result supplied
```

A completed Metal benchmark is treated as proof of the benchmark path, not proof of long-duration graphics stability.

## Documentation added or fully revised

The documentation set now covers:

```text
architecture
hardware inventory
pre-boot/XOSI compatibility
OpenCore configuration
AMD kernel patch inventory
security posture
third-party component inventory
graphics/NootedRed/Chrome failure analysis
brightness architecture and full experimental history
input/touchpad
touchscreen research
native sleep/wake
networking and installer Wi-Fi
USB/storage/camera/SD
audio and UEFI chime
boot picker
benchmarks
evidence methodology
development history
known issues
troubleshooting
diagnostics
build/release process
glossary
```

## Validation

The package includes:

```text
Scripts/validate_release.py
.github/workflows/validate.yml
```

The validator checks repository structure, plist parsing, enabled file paths, public SMBIOS placeholders, the no-Wi-Fi profile invariant, kernel patch counts, v17 brightness source constraints, default-installer power isolation, local Markdown links, selected privacy hazards and the SHA-256 manifest.

## Public safety

Production SMBIOS identifiers are not included in the public config. The release uses dummy values for:

```text
SystemSerialNumber
MLB
SystemUUID
ROM
```

Users must generate their own production values before booting this public EFI.

## Runtime disclaimer

This is an experimental hardware-specific macOS compatibility project. The EFI and helper code are not presented as a universal T495s configuration, and the two primary blockers above remain unresolved at this release state.

## GitHub publication package

The repository now includes the complete publication-side metadata used to create the GitHub Release:

```text
RELEASES/v17.1.md
RELEASE-CHECKLIST.md
.github/release.yml
.github/ISSUE_TEMPLATE/config.yml
SECURITY.md
SUPPORT.md
LICENSE.md
CHANGELOG.md
```

A GitHub Release is a server-side GitHub object and cannot itself be stored inside a ZIP. The repository contains the exact release body, tag/title convention, asset convention and publication checklist required to reproduce that object.
