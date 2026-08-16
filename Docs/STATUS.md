# Current status

## Platform

| Item | State | Basis |
|---|---|---|
| Target | Lenovo ThinkPad T495s 20QK | Hardware-specific repository |
| BIOS | R13ET56W 1.30 | Target firmware |
| OS | macOS Ventura 13.7.8 build 22H730 | Benchmarks and diagnostics |
| SMBIOS | MacBookPro16,3 | Current `config.plist` |
| OpenCore public SMBIOS | Sanitized placeholders | Publication policy |

## Critical issues

| Priority | Issue | State | Technical basis |
|---|---|---|---|
| 1 | Accelerated GPU stability | Unresolved | Chrome Metal workload generated a GPU reset; `AMDRadeonX5000` reported a GFX channel timeout/hang; two panic reports include the AMD diagnosis/restart path. |
| 2 | Native suspend/resume | Unresolved | Sleep entry is recorded, but the controlled failure contains no completed wake before restart; successful wake examples prove the path is not universally broken. |

No third issue is currently classified at the same platform-blocker severity. Secondary panic observations in AMD CPU/SMC helper paths are retained as diagnostic observations because their independent reproducibility has not been established.

## Boot and firmware compatibility

| Function | State | Qualification |
|---|---|---|
| OpenCore boot | Observed working | Current snapshot reaches Ventura userspace. |
| Lenovo ACPI mediation | Configured and required by current design | `_OSI -> XOSI` plus `SSDT-XOSI`. |
| Apple platform identity | Configured | `MacBookPro16,3`. |
| Reset NVRAM entry | Configured | `ResetNvramEntry.efi`. |
| External OpenCanopy picker | Configured | Keyboard-first. |
| Pre-boot PS/2 keyboard | Observed working | `Ps2KeyboardDxe.efi` retained. |
| Pre-boot mouse | Not used | Earlier pointer experiment was removed because of inverted behavior. |

## CPU

| Function | State | Qualification |
|---|---|---|
| 4C/8T CPU operation | Observed working | Cinebench R23 completes. |
| AMD XNU compatibility | Observed working | 20 enabled kernel patches plus required quirks reach userspace. |
| CPU model presentation | Configured | RestrictEvents/NVRAM presentation uses `Quad-Core AMD Ryzen 7 PRO`. |
| CPU power-management kext | Configured and loaded | `AMDRyzenCPUPowerManagement 0.7.1`. |
| Long-duration CPU stability | Not independently characterized | Two secondary panic reports touched AMD CPU/SMC helper paths; causality remains unproven, so no separate long-duration CPU-stability claim is made. |

## Graphics

| Function | State | Qualification |
|---|---|---|
| Internal framebuffer | Observed working | 1920x1080 60 Hz. |
| Vega 10 identification | Observed working | `1002:15D8`, ROM `113-PICASSO-117` in diagnostic output. |
| NootedRed accelerator | Observed working | AMD Vega 10 accelerator class present. |
| Metal | Observed working | Geekbench Metal completes. |
| Hardware-accelerated Chrome | Unresolved | Reproducible GFX hang / GPU reset. |
| Chrome software rendering | User-confirmed working | Graphics acceleration disabled. |
| General accelerated workload stability | Unresolved | Synthetic benchmark success is not sufficient to establish stability. |

## Display and brightness

| Function | State | Qualification |
|---|---|---|
| Built-in display | Observed working | 1920x1080, 60 Hz, online. |
| Brightness keys | Observed working | Key path reaches macOS control plane. |
| macOS brightness slider/property | Observed working | `IODisplayConnect` brightness property used by helper. |
| Apple-style backlight interface | Configured | `SSDT-PNLF` plus NootedRed `AMDBacklight=1`. |
| Continuous physical backlight PWM | Unresolved limitation | Approximately two effective hardware levels. |
| v13 NootedRed PWM experiment | Rejected | Seven-byte patch did not solve range; reverted. |
| v15/v16 gamma bridge | Rejected | Visual dimming worked, but bridge was isolated as a source of instability. |
| v17 AppKit overlay | Implemented, pending revalidation | No continuous custom gamma writes; target-machine sustained test still required. |

## Input

| Function | State | Qualification |
|---|---|---|
| Keyboard | Observed working | VoodooPS2 keyboard path. |
| Elan PS/2 touchpad | User-confirmed working | VoodooPS2 trackpad path. |
| Tap-to-click | Implemented | User preference written by installer. |
| Secondary click | Implemented | User preference written by installer. |
| Post-typing dead period mitigation | Configured | `QuietTimeAfterTyping=0`. |
| External mouse suppression disabled | Configured | USB/Bluetooth stop-trackpad flags false. |
| Force Touch emulation | Disabled intentionally | `ForceTouchMode=0`. |
| TrackPoint path | Configured through PS/2 stack | Dedicated behavioral test artifact not archived. |

## Audio

| Function | State | Qualification |
|---|---|---|
| ALC257 runtime configuration | Configured | AppleALC 1.9.1, `alcid=97`. |
| Speakers/headphone routing | Not formally archived | Do not infer complete endpoint validation from kext load alone. |
| Startup chime | Configured | `AudioDxe.efi`, `AudioSupport=true`, `PlayChime=Enabled`. |
| Chime audibility | Not formally archived | UEFI audio configuration does not itself prove speaker output. |

## Network

| Function | State | Qualification |
|---|---|---|
| Intel AX200 after installation | User-confirmed working | AirportItlwm enabled in normal profile. |
| Intel AX200 during installer | Known issue | Unavailable or can crash/destabilize installer. |
| Installer no-Wi-Fi profile | Implemented | AirportItlwm disabled only. |
| Intel Bluetooth USB enumeration | Observed | `8087:0029` present. |
| Bluetooth firmware stack | Configured and loaded | IntelBluetoothFirmware/IntelBTPatcher/BlueToolFixup. |
| Bluetooth end-to-end reliability | Not fully characterized | Treat any intermittent behavior as a separate test case. |
| Realtek Ethernet | Configured | RealtekRTL8111 2.4.2. |
| Ethernet throughput/stability | Not formally archived | No benchmark artifact in public evidence. |

## Storage and USB

| Function | State | Qualification |
|---|---|---|
| NVMe boot/storage | Observed working | Installed OS runs from target NVMe; NVMeFix present. |
| Internal USB map | Observed for enumerated devices | XHC0/XHC1 map in `USBMap.kext`. |
| Genesys internal hub | Observed | `05E3:0610`. |
| Integrated camera enumeration | Observed | `13D3:5406`. |
| Intel Bluetooth USB enumeration | Observed | `8087:0029`. |
| External USB 3 storage enumeration | Observed | Captured Phison-based USB mass-storage device. |
| SD reader support | Configured | EmeraldSDHC 0.1.2; no public read/write validation artifact. |

## Power

| Function | State | Qualification |
|---|---|---|
| Battery SMC path | Configured and loaded | SMCBatteryManager/ECEnabler. |
| Native sleep entry | Observed | `pmset` log records sleep entry. |
| Native resume | Unresolved | Not reliable. |
| Lid-close native sleep | Unresolved | No reliable production result. |
| Historical lid continuity | Available but not native | Prevents sleep and turns display off; not installed by v17 default installer. |
| Hibernation experiment | Rejected | Did not solve resume. |

## Touchscreen

| Function | State | Qualification |
|---|---|---|
| Windows-side controller identity | Known | `1A86:E5E3`, `USB2IIC_CTP_CONTROL`. |
| Internal hub enumeration | Observed | Hub and camera enumerate. |
| Target touch controller in macOS IOUSB | Not observed | Probe negative. |
| Target touch controller in macOS IOHID | Not observed | Probe negative. |
| Userspace HID bridge | Experimental | Cannot operate until physical device enumerates. |
| Production USB-map modification for touchscreen | Not enabled | Deliberate safety decision. |

## Installation

| Item | State | Qualification |
|---|---|---|
| Ventura installed system | Observed working | Primary target. |
| Installer Wi-Fi | Known issue | Use no-Wi-Fi profile if needed. |
| Default post-install script | Implemented | Trackpad preferences plus v17 brightness overlay. |
| Default post-install power mutation | None | Current installer explicitly leaves power settings unchanged. |
| Experimental touchscreen install | Manual only | Not part of production installer. |
