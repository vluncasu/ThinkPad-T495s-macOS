# Third-party components and attribution boundary

This repository integrates third-party bootloader components, UEFI drivers and kernel extensions. Those components remain governed by their own upstream copyright notices and license terms.

The presence of a binary in this repository does not transfer its copyright to this project and does not imply blanket relicensing under the terms used for project-local documentation or helper scripts.

## Major integrated projects

| Component/project | Upstream organization/project | Local role |
|---|---|---|
| OpenCorePkg | Acidanthera | OpenCore bootloader, runtime, picker, UEFI drivers/audio resources. |
| Lilu | Acidanthera | Kernel patching framework. |
| VirtualSMC | Acidanthera | SMC framework and battery plugin ecosystem. |
| AppleALC | Acidanthera | Runtime ALC257 audio patch path. |
| NVMeFix | Acidanthera | NVMe compatibility/power support. |
| VoodooPS2 | Acidanthera | PS/2 keyboard and Elan touchpad path. |
| BrightnessKeys | Acidanthera | Brightness key event path. |
| RestrictEvents | Acidanthera | macOS compatibility/restriction patches. |
| NootedRed | ChefKiss | AMD integrated-GPU enablement/patching. |
| ForgedInvariant | ChefKiss | AMD timing/invariant support included by the project. |
| SMCRadeonSensors | ChefKiss | Radeon sensor reporting. |
| AirportItlwm / itlwm | OpenIntelWireless | Intel AX200 Wi-Fi. |
| IntelBluetoothFirmware / IntelBTPatcher | OpenIntelWireless | Intel Bluetooth firmware/patching. |
| BlueToolFixup | BrcmPatchRAM ecosystem | Bluetooth compatibility component. |
| AMDRyzenCPUPowerManagement | AMD macOS community project | Ryzen power-management support. |
| SMCProcessorAMD | AMD macOS community project | AMD processor sensor/SMC integration. |
| RealtekRTL8111 | third-party Hackintosh driver ecosystem | Realtek Ethernet path. |
| ECEnabler | 1Revenger1 | EC access support. |
| EmeraldSDHC | third-party Hackintosh driver ecosystem | SD host-controller support. |
| USBMap | Generated hardware map | T495s-specific USB personality/map data. |

The exact bundled versions and bundle identifiers are recorded in [`Docs/COMPONENTS.md`](Docs/COMPONENTS.md).

## License verification requirement

Before redistributing a modified release:

1. inspect the license/copyright metadata shipped with each upstream project;
2. confirm that redistribution of the exact bundled binary is allowed under those terms;
3. preserve notices required by the upstream license;
4. do not imply endorsement by an upstream maintainer;
5. do not alter an upstream component's license through this repository's documentation.

Because third-party licensing can change between releases, this document intentionally does not replace the license files distributed by the upstream projects.

## Project-local material

Project-local documentation, configuration commentary, diagnostic shell scripts and the T495s-specific brightness overlay source are separate from the third-party binaries. Their inclusion next to third-party software does not modify the third-party software's legal status.

## References

Upstream repository links are collected in [`Docs/REFERENCES.md`](Docs/REFERENCES.md).
