# Glossary

This glossary defines project terminology precisely. It is intended to prevent ambiguous phrases such as "Windows emulation", "brightness works" or "GPU works" from hiding important technical distinctions.

| Term | Meaning in this repository |
|---|---|
| ACPI | Advanced Configuration and Power Interface tables/methods supplied by firmware and modified/interposed by the pre-boot layer where required. |
| AMD kernel patches | Binary XNU/kernel patches required for the AMD Ryzen CPU to boot and operate in macOS. They are distinct from NootedRed GPU patches. |
| AppleALC | Runtime macOS audio patching kext used for the ALC257 path. It is separate from UEFI startup-chime audio. |
| AppleBacklightDisplay | macOS display/backlight service class used when a panel is exposed through an Apple-like brightness path. |
| AppKit brightness overlay | v17 user-space visual dimming mechanism. It draws a black, click-through overlay and does not create additional physical PWM levels. |
| Brightness control plane | The software-facing path from brightness keys/slider to the brightness property exposed to macOS. A functional control plane does not prove a continuous physical backlight response. |
| Continuous gamma bridge | Rejected v15/v16 user-space implementation that repeatedly wrote display transfer curves. It produced additional perceived dimming but was isolated as an instability source. |
| DarkWake | macOS power-management wake state that may occur before a full interactive wake. Its presence does not by itself prove reliable lid-close/resume behavior. |
| EFI | In this repository, the OpenCore boot directory containing ACPI tables, drivers, kexts, resources and `config.plist`. |
| Emulation | Used only with a qualifier. `ACPI OS-interface response emulation` means firmware queries receive controlled compatibility responses; it does not mean Windows itself is emulated. |
| Framebuffer | Display output path presented by the graphics stack. A working framebuffer can exist without reliable 3D/Metal acceleration. |
| FullWake | Interactive macOS wake state. A single FullWake event is evidence of one successful transition, not proof of repeatable native sleep. |
| GPU acceleration | Use of the AMD graphics driver/Metal path instead of basic unaccelerated framebuffer rendering. This repository currently classifies it as functional but not reliable. |
| GPU reset | macOS/driver recovery path triggered after graphics command processing stops responding. On this target, a Chrome Metal workload is captured in a GFX-channel hang report. |
| Hibernation | Disk-backed sleep/resume mode explored experimentally. It did not solve the T495s resume problem. |
| Lid continuity | Historical workaround that deliberately prevents native system suspend, locks the session and turns the display off when the lid closes. It is not sleep. |
| Metal | Apple's graphics/compute API. Successful Geekbench Metal execution proves the API path works for that test; it does not prove general GPU stability. |
| Native brightness | Continuous physical panel-backlight control comparable to an Apple-supported laptop. This is not achieved on the target T495s. |
| Native sleep | Actual system suspend followed by repeatable hardware/software resume. Display-off, screen lock and `displaysleepnow` are not native sleep. |
| NootedRed | AMD integrated-GPU compatibility kext used to expose/patch the Vega 10 path under macOS. |
| OEM Windows ACPI behavior | Lenovo firmware logic written/tested around Windows-oriented `_OSI` responses and device expectations. |
| OpenCore | Bootloader and pre-boot orchestration layer used to inject ACPI, kernel patches, kexts, Apple platform identity and UEFI services. |
| PNLF | ACPI device/interface commonly used to expose a laptop panel backlight path to macOS. In this project it contributes to the control plane but does not guarantee continuous hardware PWM. |
| Pre-boot compatibility layer | OpenCore-controlled transformation applied before normal macOS userspace: ACPI mediation, AMD kernel patches, platform identity, kext injection and UEFI services. |
| PWM | Pulse-width modulation used by hardware to control physical panel-backlight power. The target currently exposes only approximately two useful effective physical brightness levels through the macOS path. |
| Safe Chrome mode | Chrome launched/configured with GPU acceleration disabled. It is a containment workaround for the accelerated GFX hang, not a repair of NootedRed/AMDRadeonX5000. |
| Sanitized config | Public `config.plist` in which production serial/MLB/UUID/ROM values were replaced with placeholders. |
| S3 | ACPI suspend-to-RAM state. This repository avoids asserting that every observed T495s sleep transition is specifically S3 unless the evidence establishes it. |
| SMBIOS identity | Apple platform identity presented through OpenCore. The selected product identity is `MacBookPro16,3`; public serial-class identifiers are placeholders. |
| Software dimming | Reduction of perceived luminance without proportionally reducing physical backlight power. The v17 overlay is software dimming. |
| Touchscreen bridge | Experimental user-space HID-to-pointer bridge for the Windows-identified `1A86:E5E3` controller. It cannot operate while the physical device remains absent from macOS IOUSB/IOHID enumeration. |
| XOSI | Project ACPI interposition method paired with the `_OSI -> XOSI` rename. It controls how selected firmware OS-interface queries are answered without changing the actual operating system. |

## Status terms

| Status term | Definition |
|---|---|
| Observed working | Directly exercised on the target and supported by observation or captured diagnostic evidence. |
| User-confirmed | Explicitly tested by the target-machine user but not necessarily represented by a dedicated public artifact. |
| Configured | Required component/settings are present; end-to-end behavior is not fully validated. |
| Implemented, pending revalidation | Replacement code exists but has not completed the required sustained target-machine validation. |
| Working with workaround | User-facing task is usable only under a documented containment measure. |
| Unresolved | Failure remains reproducible or repeatability is not established. |
| Experimental | Research path intentionally excluded from the default production path. |
| Not tested | No adequate evidence was supplied for an end-to-end claim. |
