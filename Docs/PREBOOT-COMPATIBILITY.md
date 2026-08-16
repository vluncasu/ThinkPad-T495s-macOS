# Pre-boot compatibility layer

## Purpose

The ThinkPad T495s is an OEM Windows-oriented laptop. Its firmware and ACPI tables were not authored for an AMD Mac platform.

The pre-boot compatibility layer is the set of OpenCore, ACPI and platform-identity changes applied before macOS takes full control.

The phrase "Windows emulation" is used in this project only for the ACPI operating-system interface. It must not be interpreted as Windows virtualization.

## What is being emulated

ACPI firmware can call an operating-system interface method such as:

```text
_OSI("Windows 2015")
```

and branch based on the returned result.

A typical OEM firmware uses these answers to decide how to expose or configure:

- embedded-controller behavior;
- hotkeys;
- power methods;
- device-specific ACPI paths;
- compatibility workarounds intended for particular Windows generations.

The current OpenCore configuration contains the binary rename:

```text
Find:    5F 4F 53 49
ASCII:   _OSI

Replace: 58 4F 53 49
ASCII:   XOSI
```

and injects:

```text
SSDT-XOSI.aml
```

The injected table contains the `XOSI` symbol, the original `_OSI` symbol and Windows OS-interface strings including generations from Windows 2000 through Windows 2016, together with Darwin-related logic.

The functional result is an interposition layer:

```text
firmware code calls _OSI
        |
        v
OpenCore rename redirects reference to XOSI
        |
        v
injected SSDT-XOSI logic determines the compatibility answer
        |
        v
firmware selects an OS-dependent ACPI branch
```

## What is not being emulated

This mechanism does not:

- boot Windows;
- execute Windows kernel code;
- implement Win32;
- run Windows device drivers;
- emulate NT system calls;
- emulate DirectX;
- make the macOS kernel identify as Windows;
- depend on the original Windows installation remaining on disk.

The machine's OEM Windows origin matters because it explains the assumptions built into the Lenovo firmware. The compatibility mechanism itself is independent of the old Windows partition.

## Why the layer is pre-boot

The ACPI namespace and many hardware decisions are established before normal macOS applications start.

By the time userspace is running, it is too late to solve many firmware branch-selection problems cleanly.

OpenCore can:

1. load the original ACPI tables;
2. apply controlled binary renames;
3. inject additional SSDTs;
4. set platform identity;
5. inject required kernel extensions;
6. hand control to XNU.

This makes it the correct architectural point for the compatibility layer.

## Current ACPI additions

The production configuration enables:

| Table | Role in this project |
|---|---|
| `SSDT-CPUR.aml` | AMD CPU namespace compatibility support. |
| `SSDT-EC.aml` | Embedded-controller compatibility. |
| `SSDT-HPET.aml` | HPET/interrupt compatibility layer. |
| `SSDT-PLUG.aml` | Processor plug/power-management compatibility. |
| `SSDT-PNLF.aml` | Apple-style panel/backlight device interface. |
| `SSDT-USBX.aml` | USB power-property compatibility. |
| `SSDT-XOSI.aml` | ACPI OS-interface mediation. |

The role descriptions are functional project descriptions. They do not imply that every table reproduces Apple firmware behavior exactly.

## Current ACPI binary patches

### RTC IRQ patch

```text
Comment: RTC IRQ 8 Patch
Find:    22 00 01 79 00
Replace: 22 00 00 79 00
```

Purpose:

- alter an RTC IRQ descriptor used by the OEM ACPI configuration;
- avoid an interrupt assignment that is incompatible with the intended macOS path.

### Brightness key forwarding

```text
Comment: NBCF=1 for brightness key forwarding
Find:    08 4E 42 43 46 0A 00
Replace: 08 4E 42 43 46 0A 01
```

This changes the AML integer associated with `NBCF` from `0` to `1`.

In this project it is part of the key-event control path:

```text
Fn key -> Lenovo ACPI/EC -> NBCF-enabled path -> BrightnessKeys -> macOS
```

It does not itself control panel PWM.

### `_OSI -> XOSI`

```text
Comment: _OSI to XOSI rename - requires SSDT-XOSI.aml
Find:    5F 4F 53 49
Replace: 58 4F 53 49
```

This rename and the injected table must be treated as one unit. Enabling the rename without the corresponding method would break the intended ACPI call path.

## Separate Apple-facing identity

The firmware-facing XOSI mechanism does not replace the Apple identity macOS expects.

The public configuration contains:

```text
SystemProductName = MacBookPro16,3
```

This identity is presented through OpenCore `PlatformInfo`.

Conceptually:

```text
Lenovo ACPI side:
  Windows-compatible OSI behavior

macOS platform side:
  MacBookPro16,3 SMBIOS identity
```

The two layers solve different problems.

## CPU-name presentation

The configuration also contains:

```text
revcpuname = Quad-Core AMD Ryzen 7 PRO
revcpu = 1
```

together with RestrictEvents boot arguments:

```text
revpatch=cpuname,sbvmm,auto
```

This is presentation/compatibility metadata. It is not CPU emulation and does not convert the Ryzen processor into an Intel processor.

## UEFI runtime layer

The current enabled UEFI drivers are:

```text
AudioDxe.efi
HfsPlus.efi
OpenCanopy.efi
OpenRuntime.efi
Ps2KeyboardDxe.efi
ResetNvramEntry.efi
```

Their roles are distinct:

- `OpenRuntime.efi` supplies OpenCore runtime services support.
- `HfsPlus.efi` supplies HFS+ filesystem access for pre-boot discovery.
- `OpenCanopy.efi` supplies the graphical picker.
- `Ps2KeyboardDxe.efi` provides pre-boot keyboard input on this laptop.
- `ResetNvramEntry.efi` exposes the auxiliary reset entry.
- `AudioDxe.efi` supplies the pre-boot audio device path used by OpenCore audio.

## Kernel handoff

Before XNU reaches normal userspace, OpenCore also supplies:

- AMD XNU patches;
- kext injection;
- device properties;
- NVRAM boot arguments;
- SMBIOS/platform identity;
- security and boot policy settings.

This means the full pre-boot layer is broader than XOSI.

A precise definition is:

> The pre-boot compatibility layer is the OpenCore-controlled transformation from Lenovo OEM firmware state into the ACPI, kernel, device and platform state required for this specific macOS boot.

## Why this description is preferable to "emulating Windows"

"Emulating Windows" is understandable shorthand but technically incomplete.

The exact claim supported by this repository is:

> Selected Lenovo ACPI OS-interface queries are intercepted so firmware can follow a Windows-compatible ACPI path while the operating system remains macOS.

That is specific, testable and does not imply an operating-system virtual machine.

## Failure modes

Potential failures in this layer include:

- XOSI rename without injected XOSI method;
- different BIOS changing the AML byte pattern;
- a different board requiring different OSI answers;
- PNLF or EC table mismatch;
- kernel patch scopes not matching a different Darwin version;
- invalid SMBIOS publication placeholders being used as if they were production identifiers.

Any firmware update should therefore trigger revalidation of:

```text
ACPI binary patch matches
SSDT load order
boot
brightness keys
battery/EC behavior
USB
sleep
```
