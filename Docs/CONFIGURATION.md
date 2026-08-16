# OpenCore configuration

## Interpretation rule

This document treats executable configuration fields and bundled component metadata as authoritative. Human-readable OpenCore `Comment` strings are not runtime inputs and may retain historical version labels. Component versions are therefore taken from the bundled kext `Info.plist` files and documented in [`COMPONENTS.md`](COMPONENTS.md), not inferred from comment text.

This document records the current public production `EFI/OC/config.plist`.

It is a snapshot, not a universal recommendation.

## PlatformInfo

Top-level behavior:

```text
Automatic = true
CustomMemory = false
UpdateDataHub = true
UpdateNVRAM = true
UpdateSMBIOS = true
UpdateSMBIOSMode = Create
UseRawUuidEncoding = false
```

Generic identity:

```text
AdviseFeatures = false
MaxBIOSVersion = false
ProcessorType = 1537
SpoofVendor = true
SystemMemoryStatus = Auto
SystemProductName = MacBookPro16,3
SystemSerialNumber = C02DEMO00000
MLB = C02DEMO0000000000
SystemUUID = 00000000-0000-0000-0000-000000000000
ROM = 000000000000
```

The serial/board/UUID/ROM values are public placeholders and must be replaced for a private production EFI. `ProcessorType=1537` is recorded as the current snapshot value; the displayed AMD CPU name is separately influenced by RestrictEvents/NVRAM presentation.

## Boot arguments

Current:

```text
keepsyms=1 debug=0x100 npci=0x2000 alcid=97 revblock=media revpatch=cpuname,sbvmm,auto AMDBacklight=1
```

### `keepsyms=1`

Preserves kernel symbols in panic/backtrace output. Retained because the project is still diagnosing GPU and power failures.

### `debug=0x100`

Retains diagnostic panic behavior rather than using a minimal production-debug posture.

### `npci=0x2000`

Retained because this target configuration depends on it for boot reliability.

### `alcid=97`

Selects AppleALC layout 97 for the ALC257 path.

### `revblock=media`

RestrictEvents block configuration used by this snapshot.

### `revpatch=cpuname,sbvmm,auto`

Enables RestrictEvents presentation/compatibility patches used by the platform.

### `AMDBacklight=1`

Enables the NootedRed AMD backlight module used by the PNLF/macOS brightness control path.

## ACPI Add

All listed entries are enabled.

| Order | Table | Configuration comment |
|---:|---|---|
| 1 | `SSDT-CPUR.aml` | `SSDT-CPUR.aml` |
| 2 | `SSDT-EC.aml` | `SSDT-EC.aml` |
| 3 | `SSDT-HPET.aml` | `SSDT-HPET.aml` |
| 4 | `SSDT-PLUG.aml` | `SSDT-PLUG.aml` |
| 5 | `SSDT-PNLF.aml` | `AMD panel backlight device` |
| 6 | `SSDT-USBX.aml` | `SSDT-USBX.aml` |
| 7 | `SSDT-XOSI.aml` | `SSDT-XOSI.aml` |

## ACPI Patch

Three binary patches are enabled.

| Patch | Find | Replace |
|---|---|---|
| RTC IRQ 8 Patch | `2200017900` | `2200007900` |
| NBCF=1 for brightness key forwarding | `084e4243460a00` | `084e4243460a01` |
| `_OSI to XOSI rename - requires SSDT-XOSI.aml` | `5f4f5349` | `584f5349` |

See `PREBOOT-COMPATIBILITY.md` for interpretation.

## Kernel Add

All entries below are enabled in the public normal profile.

| Order | Bundle |
|---:|---|
| 1 | `Lilu.kext` |
| 2 | `VirtualSMC.kext` |
| 3 | `AppleMCEReporterDisabler.kext` |
| 4 | `EmeraldSDHC.kext` |
| 5 | `NootedRed.kext` |
| 6 | `NVMeFix.kext` |
| 7 | `AMDRyzenCPUPowerManagement.kext` |
| 8 | `RestrictEvents.kext` |
| 9 | `USBMap.kext` |
| 10 | `VoodooPS2Controller.kext` |
| 11 | `VoodooInput.kext` plugin |
| 12 | `VoodooPS2Keyboard.kext` plugin |
| 13 | `VoodooPS2Trackpad.kext` plugin |
| 14 | `RealtekRTL8111.kext` |
| 15 | `AppleALC.kext` |
| 16 | `BrightnessKeys.kext` |
| 17 | `ECEnabler.kext` |
| 18 | `ForgedInvariant.kext` |
| 19 | `SMCBatteryManager.kext` |
| 20 | `SMCProcessorAMD.kext` |
| 21 | `SMCRadeonSensors.kext` |
| 22 | `AirportItlwm.kext` |
| 23 | `IntelBTPatcher.kext` |
| 24 | `IntelBluetoothFirmware.kext` |
| 25 | `BlueToolFixup.kext` |

## Kernel quirks

Enabled/non-default items relevant to the snapshot:

```text
DisableLinkeditJettison = true
PanicNoKextDump = true
ProvideCurrentCpuInfo = true
SetApfsTrimTimeout = -1
```

## Kernel Emulate

```text
DummyPowerManagement = true
```

No custom `Cpuid1Data` or `Cpuid1Mask` values are populated.

## Kernel patches

There are:

```text
22 total patch entries
20 enabled
2 disabled
```

The exact table is intentionally separated into `KERNEL-PATCHES.md`.

## DeviceProperties

Current injected properties include:

```text
Audio controller:
  alc-layout-id = 0x61 = decimal 97

Network-related PCI path:
  built-in = 0x01

GPU path:
  model = AMD Radeon Vega 10
```

Device-property paths are hardware-specific. Do not transplant them to another board solely because the component names match.

## NVRAM

### RestrictEvents vendor namespace

```text
revcpuname = Quad-Core AMD Ryzen 7 PRO
revcpu = 1
```

### Apple boot namespace

```text
SystemAudioVolume = 46
boot-args = keepsyms=1 debug=0x100 npci=0x2000 alcid=97 revblock=media revpatch=cpuname,sbvmm,auto AMDBacklight=1
csr-active-config = 03000000
run-efi-updater = No
```

`csr-active-config=03000000` means the configuration does not use Apple's default fully protected SIP state. See `SECURITY.md`.

The NVRAM delete section includes `boot-args`, which is relevant when applying config changes because stale stored boot arguments should not be assumed to survive independently of the plist.

## UEFI Drivers

Enabled:

```text
AudioDxe.efi
HfsPlus.efi
OpenCanopy.efi
OpenRuntime.efi
Ps2KeyboardDxe.efi
ResetNvramEntry.efi
```

## UEFI Audio

Exact current settings:

```text
AudioCodec = 0
AudioDevice = PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x6)
AudioOutMask = 1
AudioSupport = true
DisconnectHda = false
MaximumGain = -15
MinimumAssistGain = -30
MinimumAudibleGain = -55
PlayChime = Enabled
ResetTrafficClass = false
SetupDelay = 0
```

This configuration establishes the UEFI audio attempt. It does not by itself prove audible chime output.

## UEFI APFS

```text
EnableJumpstart = true
HideVerbose = true
MinDate = -1
MinVersion = -1
```

The `-1` version/date values broaden APFS driver acceptance and should be understood as a compatibility choice rather than a hardened policy.

## UEFI quirks

Relevant values:

```text
EnableVectorAcceleration = true
RequestBootVarRouting = true
ResizeGpuBars = -1
```

## Booter quirks

Enabled/non-default items:

```text
AvoidRuntimeDefrag = true
EnableSafeModeSlide = true
EnableWriteUnprotector = true
ProtectSecureBoot = true
ProvideCustomSlide = true
ResizeAppleGpuBars = -1
SetupVirtualMap = true
```

## Misc Boot

```text
HibernateMode = None
HibernateSkipsPicker = false
HideAuxiliary = true
LauncherOption = Full
PickerAttributes = 17
PickerMode = External
PollAppleHotKeys = true
ShowPicker = true
Timeout = 5
```

## Misc Security

```text
AllowSetDefault = true
AuthRestart = true
BlacklistAppleUpdate = true
DmgLoading = Signed
ExposeSensitiveData = 6
ScanPolicy = 0
SecureBootModel = Disabled
Vault = Optional
```

These are compatibility/development settings and are not equivalent to an Apple secure-boot baseline. See `SECURITY.md`.

## Misc Debug

```text
AppleDebug = true
ApplePanic = true
DisableWatchDog = false
DisplayLevel = 2147483714
LogModules = *
SysReport = false
Target = 67
```

The snapshot remains diagnostic-oriented because two primary platform issues are still open.

## Installer profile

`EFI/OC/Config-Profiles/config-install-no-wifi.plist` is intended for the macOS installation environment.

Its functional difference from the normal profile is:

```text
AirportItlwm.kext
normal profile: Enabled = true
installer profile: Enabled = false
```

No other functional change should be introduced into that profile without updating the documentation and validation script.

## Configuration invariants

The following pairs should be changed together:

```text
_OSI -> XOSI rename
SSDT-XOSI.aml
```

```text
SSDT-PNLF.aml
AMDBacklight=1
BrightnessKeys.kext
NBCF forwarding patch
```

```text
NootedRed.kext
compatible Lilu.kext
```

```text
IntelBluetoothFirmware.kext
IntelBTPatcher.kext
BlueToolFixup.kext
```

Treat each set as a dependency group rather than independent toggles.

## Development versus release posture

This public snapshot intentionally retains diagnostic settings because the project is not fully closed.

Once GPU and sleep are resolved, a separate hardening pass should reassess:

- `debug=0x100`;
- `keepsyms=1`;
- Misc Debug settings;
- SIP state;
- SecureBootModel;
- Vault;
- ScanPolicy;
- ExposeSensitiveData.

Do not conflate current diagnostic convenience with a final security baseline.
