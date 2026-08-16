# Bundled components

## Scope

This inventory is generated from the kext `Info.plist` files bundled in the current public EFI.

A bundled component is not automatically classified as fully working. Runtime validation status is documented in `STATUS.md`.

### Version-source rule

The version table below is derived from each bundled kext's `Contents/Info.plist`. OpenCore `Kernel -> Add -> Comment` strings are descriptive metadata only and are not treated as authoritative version fields. Some retained comments originated in earlier development states and are stale even though the bundled binary was updated. For example, the current `Info.plist` metadata reports VirtualSMC 1.3.3, AppleALC 1.9.1, RestrictEvents 1.1.4 and SMCBatteryManager 1.3.3.

When the OpenCore comment and the bundled kext metadata disagree, this documentation uses the bundled kext metadata.

## Kernel extensions

| Component | Version | Bundle identifier | Role in this project |
|---|---:|---|---|
| `AMDRyzenCPUPowerManagement.kext` | 0.7.1 | `wtf.spinach.AMDRyzenCPUPowerManagement` | AMD CPU power-management telemetry/control support. |
| `AirportItlwm.kext` | 2.3.0 | `com.zxystd.AirportItlwm` | Intel AX200 Wi-Fi integration in installed macOS. |
| `AppleALC.kext` | 1.9.1 | `as.vit9696.AppleALC` | Realtek ALC257 runtime audio path. |
| `AppleMCEReporterDisabler.kext` | 1.2 | `org.xlnc.disabler.MCEReporter` | Disables Apple MCE reporter behavior incompatible with non-Intel CPU assumptions. |
| `BlueToolFixup.kext` | 2.6.8 | `as.acidanthera.BlueToolFixup` | Bluetooth stack compatibility on newer macOS Bluetooth architecture. |
| `BrightnessKeys.kext` | 1.0.3 | `as.acidanthera.BrightnessKeys` | Converts supported laptop brightness-key events into the macOS brightness control path. |
| `ECEnabler.kext` | 1.0.4 | `com.1Revenger1.ECEnabler` | Embedded-controller field access compatibility used by laptop telemetry/battery path. |
| `EmeraldSDHC.kext` | 0.1.2 | `fish.goldfish64.EmeraldSDHC` | SD host-controller support path. |
| `ForgedInvariant.kext` | 1.0.0 | `com.ChefKiss.ForgedInvariant` | AMD timing/invariant support used by the AMD macOS stack. |
| `IntelBTPatcher.kext` | 2.4.0 | `com.zxystd.IntelBTPatcher` | Intel Bluetooth compatibility patching. |
| `IntelBluetoothFirmware.kext` | 2.4.0 | `com.zxystd.IntelBluetoothFirmware` | Firmware loader for Intel Bluetooth controller. |
| `Lilu.kext` | 1.7.2 | `as.vit9696.Lilu` | Kernel patching framework required by NootedRed and other Lilu plugins. |
| `NVMeFix.kext` | 1.1.1 | `org.acidanthera.NVMeFix` | NVMe compatibility and power-management fixes. |
| `NootedRed.kext` | 0.9.0 | `org.ChefKiss.NootedRed` | AMD iGPU enablement/patching for the Vega 10 path. |
| `RealtekRTL8111.kext` | 2.4.2 | `com.insanelymac.RealtekRTL8111` | Realtek Ethernet driver. |
| `RestrictEvents.kext` | 1.1.4 | `as.vit9696.RestrictEvents` | Platform compatibility and CPU-name presentation patches. |
| `SMCBatteryManager.kext` | 1.3.3 | `ru.usrsse2.SMCBatteryManager` | Battery information through VirtualSMC. |
| `SMCProcessorAMD.kext` | 1.0.1 | `as.lorys89.SMCProcessorAMD` | AMD CPU sensor integration into SMC-compatible consumers. |
| `SMCRadeonSensors.kext` | 2.1.0 | `com.ChefKiss.SMCRadeonSensors` | Radeon sensor reporting. |
| `USBMap.kext` | 1.1 | `com.dhinakg.USBToolBox.map` | Hardware-specific USB port property map. |
| `VirtualSMC.kext` | 1.3.3 | `as.vit9696.VirtualSMC` | Apple SMC compatibility layer. |
| `VoodooPS2Controller.kext` | 2.3.5 | `as.acidanthera.voodoo.driver.PS2Controller` | PS/2 controller, keyboard and touchpad framework. |

## VoodooPS2 bundled plugins

The active OpenCore entries also load:

```text
VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext
VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext
VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext
```

The production configuration does not load VoodooI2C for the touchpad.

## UEFI drivers

Enabled:

| Driver | Role |
|---|---|
| `AudioDxe.efi` | OpenCore pre-boot audio output path. |
| `HfsPlus.efi` | HFS+ filesystem access during boot. |
| `OpenCanopy.efi` | External graphical OpenCore picker. |
| `OpenRuntime.efi` | OpenCore runtime services. |
| `Ps2KeyboardDxe.efi` | Pre-boot PS/2 keyboard input. |
| `ResetNvramEntry.efi` | Auxiliary Reset NVRAM entry. |

## ACPI tables

Enabled:

```text
SSDT-CPUR.aml
SSDT-EC.aml
SSDT-HPET.aml
SSDT-PLUG.aml
SSDT-PNLF.aml
SSDT-USBX.aml
SSDT-XOSI.aml
```

## Dependency relationships

### NootedRed

```text
NootedRed
  requires compatible Lilu
  patches Apple AMD graphics stack
  supplies AMD backlight support when AMDBacklight=1
```

A previous development state failed because NootedRed requested Lilu 1.7.0 compatibility while the loaded Lilu was 1.6.8. The current snapshot uses Lilu 1.7.2.

### VirtualSMC family

```text
VirtualSMC
  -> SMCBatteryManager
  -> SMCProcessorAMD
  -> SMCRadeonSensors
```

These plugins serve different sensor/telemetry functions.

### Intel Bluetooth family

```text
IntelBluetoothFirmware
IntelBTPatcher
BlueToolFixup
```

Treat them as a versioned stack rather than independent random kexts.

### Brightness control

```text
SSDT-PNLF
NBCF ACPI patch
BrightnessKeys
NootedRed AMDBacklight=1
v17 userspace overlay
```

Only the final userspace overlay is custom project code. The upstream components provide the control-plane path.

## USB map contents

The bundled `USBMap.kext` contains model-specific personalities for `MacBookPro16,3`.

Relevant production mapping includes:

### XHC0

```text
HS01  connector 9
HS02  connector 3
HS03  connector 3
HS04  connector 9
SS01  connector 9
SS02  connector 3
SS03  connector 3
SS04  connector 9
```

### XHC1

```text
HS01  connector 255
HS02  connector 255
SS01  connector 255
```

An additional controller personality maps `PRT1`.

Connector values are recorded as configured values. They should not be generalized to another machine without physical port testing.

## Updating components

Update one dependency group at a time.

For NootedRed:

1. preserve current bootable EFI;
2. update NootedRed and required Lilu together;
3. validate boot;
4. validate internal display;
5. run a short Metal test;
6. reproduce or disprove the Chrome accelerated workload;
7. collect `gpuRestart`/panic evidence;
8. test sleep separately.

For Intel wireless:

1. test post-install Wi-Fi;
2. test Bluetooth separately;
3. do not infer installer safety from installed-system operation.

For VoodooPS2:

1. preserve Elantech tuning;
2. validate typing plus touchpad interaction;
3. validate tap/right click;
4. validate TrackPoint/buttons separately.

## License handling

Upstream licenses remain authoritative for third-party binaries.

This repository's documentation does not relicense bundled upstream projects. See `../THIRD_PARTY.md`.
