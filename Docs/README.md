# Documentation index

This directory is the technical record for the ThinkPad T495s 20QK macOS Ventura project.

The documentation separates:

- observed runtime behavior;
- configuration-derived facts;
- source-code-derived behavior;
- target-machine user observations;
- unresolved failures;
- experimental code.

A component is not marked working solely because its kext or ACPI table is present.

## Recommended reading order

1. [`STATUS.md`](STATUS.md) - complete current status and evidence classification.
2. [`HARDWARE.md`](HARDWARE.md) - exact target hardware.
3. [`ARCHITECTURE.md`](ARCHITECTURE.md) - compatibility layers and boot flow.
4. [`PREBOOT-COMPATIBILITY.md`](PREBOOT-COMPATIBILITY.md) - `_OSI -> XOSI`, Windows-oriented ACPI mediation and Apple SMBIOS identity.
5. [`CONFIGURATION.md`](CONFIGURATION.md) - exact production OpenCore configuration.
6. [`KERNEL-PATCHES.md`](KERNEL-PATCHES.md) - enabled AMD XNU patch set.
7. [`COMPONENTS.md`](COMPONENTS.md) - bundled kext versions and roles.
8. [`GRAPHICS.md`](GRAPHICS.md) - NootedRed, Metal, GPU reset evidence and Chrome workaround.
9. [`BRIGHTNESS.md`](BRIGHTNESS.md) - native control path, physical limitation and userspace dimming.
10. [`POWER-SLEEP.md`](POWER-SLEEP.md) - native suspend/resume diagnostics.
11. [`INPUT.md`](INPUT.md) - PS/2 keyboard, Elan touchpad and tuning.
12. [`TOUCHSCREEN.md`](TOUCHSCREEN.md) - experimental touch-controller investigation.
13. [`NETWORKING.md`](NETWORKING.md) - Wi-Fi, Bluetooth, Ethernet and installer behavior.
14. [`STORAGE-USB.md`](STORAGE-USB.md) - NVMe, USB map, internal hub, camera and SD path.
15. [`AUDIO.md`](AUDIO.md) - runtime audio and pre-boot chime.
16. [`BOOT-PICKER.md`](BOOT-PICKER.md) - pre-boot input and picker design.
17. [`INSTALLATION.md`](INSTALLATION.md) - installation and post-install procedure.
18. [`SECURITY.md`](SECURITY.md) - security-relevant OpenCore settings and public-SMBIOS handling.
19. [`BENCHMARKS.md`](BENCHMARKS.md) - retained measured results.
20. [`DEVELOPMENT-HISTORY.md`](DEVELOPMENT-HISTORY.md) - v2 through v17 chronology.
21. [`EVIDENCE.md`](EVIDENCE.md) - evidence provenance and interpretation limits.
22. [`METHODOLOGY.md`](METHODOLOGY.md) - validation rules.
23. [`TEST-MATRIX.md`](TEST-MATRIX.md) - current subsystem test matrix.
24. [`KNOWN-ISSUES.md`](KNOWN-ISSUES.md) - unresolved issues.
25. [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - failure-oriented procedures.
26. [`DIAGNOSTICS.md`](DIAGNOSTICS.md) - data-collection commands.
27. [`BUILD.md`](BUILD.md) - helper build and release validation.
28. [`REFERENCES.md`](REFERENCES.md) - upstream primary projects and related issue references.
29. [`GLOSSARY.md`](GLOSSARY.md) - terminology.
30. [`CHANGELOG.md`](CHANGELOG.md) - repository evolution.

## Severity model

### Primary platform blocker

A failure that compromises the general expectation of a laptop platform and cannot currently be made native and reliable.

Current blockers:

1. accelerated GPU stability;
2. native suspend/resume.

### Scoped limitation

A failure limited to a subsystem for which the rest of the platform remains usable.

Examples:

- physical continuous backlight PWM;
- installer-stage Intel Wi-Fi;
- touchscreen enumeration.

### Experimental subsystem

Code retained for investigation but not enabled in the normal production path.

Current example:

- touchscreen userspace bridge.

## Evidence labels

The documentation uses these labels consistently.

| Label | Definition |
|---|---|
| Observed working | Exercised successfully on the target machine with direct observation or diagnostic evidence. |
| User-confirmed | Machine owner explicitly reported successful behavior. |
| Configured | Configuration is present and may be loaded, but end-to-end test evidence is incomplete. |
| Implemented, pending revalidation | A replacement implementation exists but has not completed sustained target validation. |
| Working with workaround | User-facing function is usable only under a documented containment measure. |
| Unresolved | Failure remains reproducible or reliability is insufficient. |
| Experimental | Isolated development path, not enabled in the normal release. |

## Reproducibility rule

When a document states a number, path, OpenCore setting, kext version or diagnostic event, it should be derivable from the repository snapshot or from the sanitized evidence record.

Claims that are only user observations are stated as such.

## Public repository rule

Never publish the private production SMBIOS values. The public `config.plist` is intentionally sanitized and must be personalized by each user.
