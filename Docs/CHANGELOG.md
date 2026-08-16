# Changelog

This changelog separates runtime EFI changes from documentation/publication changes. A documentation revision does not imply that a runtime subsystem has improved.

## 17.1-github-public-docs-r2

Documentation and release-integrity revision only.

### Documentation

- Re-audited the complete public repository against the actual `config.plist`, kext inventory, ACPI inventory, UEFI drivers, helper scripts, benchmark images and retained diagnostics.
- Added a strict evidence vocabulary and a full `What's working` table that distinguishes observed, user-confirmed, configured, pending-revalidation, unresolved and experimental states.
- Expanded the pre-boot architecture to describe `_OSI -> XOSI` interposition as ACPI OS-interface response emulation rather than generic Windows emulation.
- Documented the complete AMD compatibility split between XNU kernel patches and NootedRed graphics enablement.
- Added the exact 22-entry kernel patch inventory, including enabled/disabled state and the Shaneee PAT path.
- Documented all enabled ACPI tables and binary ACPI patches.
- Documented the public `MacBookPro16,3` identity and the sanitized SMBIOS publication policy.
- Expanded GPU documentation with the captured Chrome `gpuRestart`, Metal submit context, `IOAcceleratorFamily2` hardware-error path, `AMDRadeonX5000` GFX-channel timeout and related panic evidence.
- Reclassified Chrome without hardware acceleration as user-confirmed functional rather than proof that the underlying GPU defect is fixed.
- Reconstructed the brightness development history from the native control plane through v13 PWM experimentation, v15/v16 continuous gamma bridge and v17 AppKit overlay.
- Documented that v17 invokes `CGDisplayRestoreColorSyncSettings()` during migration/start/wake handling while avoiding continuous custom gamma programming.
- Classified v17 brightness overlay as implemented and pending sustained revalidation rather than fully working.
- Expanded Elan PS/2 touchpad tuning, input preferences and picker-input history.
- Added a dedicated experimental touchscreen document, exact VID/PID, internal hub evidence, negative IOUSB/IOHID probe result and bridge architecture.
- Expanded native sleep documentation with exact sleep/wake chronology, confounding assertions and the distinction between native suspend and the historical lid-continuity workaround.
- Documented the installer-only Wi-Fi failure scope and the exact no-Wi-Fi profile invariant.
- Added exact UEFI chime configuration while keeping audible chime status at `Configured/Not formally archived`.
- Expanded USB, NVMe, camera, Bluetooth, Ethernet and SD evidence boundaries to avoid inferring end-to-end behavior from kext presence alone.
- Added Cinebench R23 and both supplied Geekbench Metal results; explicitly recorded that no standalone Geekbench CPU result was supplied.
- Added development history from early diagnostic EFI states through v17.
- Added security, privacy, evidence, build/release, glossary and third-party boundary documentation.
- Removed decorative emoji from maintained documentation.

### Validation infrastructure

- Added `Scripts/validate_release.py` for cross-platform repository checks.
- Added GitHub Actions validation workflow.
- Added local Markdown-link validation.
- Added enabled-path checks for ACPI, UEFI drivers and kexts.
- Added public-SMBIOS placeholder verification.
- Added no-Wi-Fi profile differential validation.
- Added kernel-patch-count validation.
- Added source check preventing accidental reintroduction of the rejected continuous gamma API into the v17 brightness source.
- Added default-installer check preventing accidental reintroduction of historical lid-continuity power changes.
- Added manifest verification.

### Runtime status

No runtime limitation is reclassified by this documentation revision:

```text
Primary issue 1: accelerated GPU stability remains unresolved.
Primary issue 2: native sleep/resume remains unresolved.
v17 visual brightness overlay: implemented, pending sustained revalidation.
Touchscreen: experimental, physical controller not enumerated by macOS.
Installer Wi-Fi: known scoped issue; no-Wi-Fi installer profile remains the documented path.
```

## 17.1-github-public

- Created the initial public GitHub-oriented package.
- Sanitized SystemSerialNumber, MLB, SystemUUID and ROM.
- Added initial architecture, brightness, GPU, sleep, touchscreen and benchmark documentation.
- Added Chrome software-rendering launcher.
- Added installer no-Wi-Fi profile.
- Added public evidence excerpts.

## 17.0

- Removed the continuously programmed gamma-table brightness bridge from the current implementation.
- Added an AppKit overlay-based perceived-brightness extension.
- Added one-time/migration ColorSync restoration behavior.
- Stopped installing the historical lid-continuity workaround from the default installer.
- Retained the v16.1 EFI baseline.

## 16.2 diagnostic

- Enabled power-transition timeout diagnostics for sleep/wake investigation.
- Diagnostic profile used `PowerTimeoutKernelPanic=true`, `darkwake=0` and `swd_panic=1`.
- This was a diagnostic branch, not the normal production configuration.

## 16.1

- Added `AudioDxe.efi` and OpenCore UEFI-audio configuration.
- Enabled `PlayChime=Enabled` in the UEFI audio configuration.

## 16.0

- Replaced the failed Objective-C/ApplicationServices brightness build path with a C/CoreGraphics/IOKit build path using explicit SDK discovery.
- Removed global all-or-nothing installer failure behavior so power/brightness stages could be diagnosed independently.
- Added focused power/brightness diagnostic scripts.
- Continuous gamma programming was still used and was later rejected.

## 15.0

- Restored the upstream NootedRed binary after the v13 PWM experiment.
- Introduced a user-space continuous gamma bridge for additional perceived dimming.
- Added the historical lid-continuity workaround that deliberately prevented native suspend.
- Kept touchscreen work isolated from the production path.

## 14.x

- Investigated the internal USB hub and touchscreen enumeration path.
- Added/adjusted experimental USB exposure around the internal hub.
- Target `1A86:E5E3` touchscreen remained absent from macOS IOUSB/IOHID enumeration.

## 13.x

- Applied a seven-byte NootedRed binary experiment intended to alter brightness/PWM scaling.
- Physical brightness range did not materially improve.
- Patch was rejected and upstream binary restored later.

## 12.x

- Removed verbose boot from the daily-use profile.
- Retained a separate touchscreen diagnostic branch.
- Continued brightness and sleep investigation without changing the fundamental unresolved state.

## 11.x

- Expanded the brightness path with PNLF, BrightnessKeys, AMDBacklight and the Lenovo NBCF forwarding patch.
- Disabled conflicting I2C touchpad path and consolidated on VoodooPS2 for the Elan device.
- Tuned touchpad behavior including post-typing delay and external-mouse suppression.
- Tested hibernation-oriented resume; it did not solve the wake problem.

## 8-10

- Established the NootedRed-accelerated Vega 10 baseline.
- Verified framebuffer/Metal functionality.
- Began controlled backlight and wake investigation.

## 5-7

- Preserved a non-NootedRed control baseline.
- Integrated NootedRed.
- Identified and repaired an early Lilu/NootedRed dependency mismatch by moving to a compatible Lilu version.
- Normalized the bootable package layout.

## 2-4

- Early boot and diagnostic foundations.
- Compared NootedRed and non-NootedRed states.
- Established the basic AMD/OpenCore/ACPI path used by later versions.

For a detailed engineering narrative and the rationale for accepting/rejecting each branch, see [`DEVELOPMENT-HISTORY.md`](DEVELOPMENT-HISTORY.md).
