# Test matrix

This table records the present validation state, not the intended design.

## Legend

- PASS-OBSERVED: directly observed on target.
- PASS-USER: explicitly confirmed by target-machine user.
- PASS-WORKAROUND: usable with required workaround.
- CONFIGURED: configuration is present but end-to-end test evidence is incomplete.
- PENDING-REVALIDATION: implementation changed and requires sustained retest.
- FAIL-UNRESOLVED: reproducible native failure remains.
- EXPERIMENTAL: isolated research path.
- NOT-TESTED: no adequate evidence in the public archive.

## Matrix

| ID | Subsystem | Test | Result | Evidence / note |
|---|---|---|---|---|
| BOOT-01 | Boot | OpenCore reaches Ventura | PASS-OBSERVED | Current development machine boots 13.7.8. |
| BOOT-02 | Picker | PS/2 keyboard navigation | PASS-OBSERVED | Keyboard-first picker retained. |
| BOOT-03 | Picker | PS/2 mouse pointer | FAIL-UNRESOLVED / removed | Earlier driver produced inverted pointer behavior; removed rather than retained. |
| CPU-01 | CPU | 4C/8T operation | PASS-OBSERVED | Cinebench identifies 4 cores, 8 threads. |
| CPU-02 | CPU | Cinebench R23 multi-core completion | PASS-OBSERVED | 3141 points. |
| CPU-03 | CPU | Geekbench CPU | NOT-TESTED | No standalone Geekbench CPU result supplied. |
| GPU-01 | GPU | Internal framebuffer | PASS-OBSERVED | 1920x1080 60 Hz. |
| GPU-02 | GPU | Metal API | PASS-OBSERVED | Geekbench Metal completes. |
| GPU-03 | GPU | Geekbench Metal run A | PASS-OBSERVED | 11179. |
| GPU-04 | GPU | Geekbench Metal run B | PASS-OBSERVED | 5164. |
| GPU-05 | GPU | Accelerated Chrome | FAIL-UNRESOLVED | GPU reset/GFX hang captured. |
| GPU-06 | GPU | Chrome with acceleration disabled | PASS-USER | User explicitly confirmed functional operation with hardware acceleration disabled. |
| GPU-07 | GPU | Long-duration general acceleration | FAIL-UNRESOLVED | Chrome failure invalidates a general stability claim. |
| BR-01 | Brightness | Fn brightness event path | PASS-OBSERVED | macOS brightness control path responds. |
| BR-02 | Brightness | Native slider/property | PASS-OBSERVED | `IODisplayConnect` brightness property readable. |
| BR-03 | Brightness | Continuous physical PWM | FAIL-UNRESOLVED | Approximately two effective levels. |
| BR-04 | Brightness | v13 PWM binary patch | FAIL-UNRESOLVED / rejected | No useful range improvement; reverted. |
| BR-05 | Brightness | v15/v16 gamma visual bridge | PASS visual / FAIL stability | Extended visual range but isolated as instability source. |
| BR-06 | Brightness | v17 AppKit overlay | PENDING-REVALIDATION | Replacement implementation present; no sustained target validation artifact yet. |
| IN-01 | Input | Keyboard | PASS-OBSERVED | PS/2 path. |
| IN-02 | Input | Elan touchpad | PASS-USER | User-confirmed. |
| IN-03 | Input | Tap-to-click preference | CONFIGURED | Installer writes preference. |
| IN-04 | Input | Right-click preference | CONFIGURED | Installer writes preference. |
| IN-05 | Input | No post-typing quiet interval | CONFIGURED | `QuietTimeAfterTyping=0`. |
| IN-06 | Input | External mouse does not disable trackpad | CONFIGURED | Related flags disabled. |
| NET-01 | Wi-Fi | Installed Ventura | PASS-USER | User-observed post-install operation. |
| NET-02 | Wi-Fi | macOS installer | FAIL-UNRESOLVED scoped | Can be unavailable/crash installer. |
| NET-03 | Wi-Fi | No-Wi-Fi installer profile | CONFIGURED | AirportItlwm disabled in alternate profile. |
| NET-04 | Bluetooth | USB enumeration | PASS-OBSERVED | Intel `8087:0029`. |
| NET-05 | Bluetooth | Firmware kext load | PASS-OBSERVED | Relevant stack appears loaded. |
| NET-06 | Bluetooth | Long-duration pairing reliability | NOT-TESTED | No formal evidence archive. |
| NET-07 | Ethernet | Driver load/configuration | CONFIGURED | RealtekRTL8111 2.4.2. |
| NET-08 | Ethernet | Throughput benchmark | NOT-TESTED | No result supplied. |
| AUD-01 | Audio | ALC257 AppleALC configuration | CONFIGURED | `alcid=97`. |
| AUD-02 | Audio | Runtime speaker/headphone endpoint matrix | NOT-TESTED | No formal public test artifact. |
| AUD-03 | Audio | Startup chime configuration | CONFIGURED | AudioDxe enabled. |
| AUD-04 | Audio | Audible startup chime | NOT-TESTED | No formal public confirmation retained. |
| USB-01 | USB | XHC mapping | PASS-OBSERVED | Internal/external devices enumerate. |
| USB-02 | USB | Genesys hub | PASS-OBSERVED | `05E3:0610`. |
| USB-03 | USB | Camera enumeration | PASS-OBSERVED | `13D3:5406`. |
| USB-04 | USB | External USB 3 storage | PASS-OBSERVED | Captured in profiler. |
| STO-01 | Storage | NVMe boot | PASS-OBSERVED | Installed OS running from target NVMe. |
| STO-02 | SD | EmeraldSDHC inclusion | CONFIGURED | Kext present. |
| STO-03 | SD | Card read/write | NOT-TESTED | No result supplied. |
| PWR-01 | Power | Sleep entry | PASS-OBSERVED | 03:28:14 event. |
| PWR-02 | Power | Controlled native wake | FAIL-UNRESOLVED | No completed Wake before restart. |
| PWR-03 | Power | Earlier HID wake | PASS-OBSERVED | DarkWake -> FullWake in 0.541 s. |
| PWR-04 | Power | Repeatable lid close/open | FAIL-UNRESOLVED | Second primary issue. |
| PWR-05 | Power | Historical display-off continuity | PASS as workaround | Deliberately disables sleep; not native. |
| TOUCH-01 | Touchscreen | Internal hub enumeration | PASS-OBSERVED | Hub present. |
| TOUCH-02 | Touchscreen | `1A86:E5E3` IOUSB enumeration | FAIL-UNRESOLVED | Not observed. |
| TOUCH-03 | Touchscreen | `1A86:E5E3` IOHID match | FAIL-UNRESOLVED | Not observed. |
| TOUCH-04 | Touchscreen | Userspace bridge build/probe | PASS-OBSERVED as probe | Probe executable opens HID manager and waits for target. |
| TOUCH-05 | Touchscreen | Actual touch input | EXPERIMENTAL / blocked | Device must enumerate first. |

## Interpretation

A PASS in a synthetic GPU benchmark is not equivalent to PASS for long-duration GPU stability.

A CONFIGURED result is not equivalent to a functional PASS.

A userspace workaround is not relabeled as native hardware support.
