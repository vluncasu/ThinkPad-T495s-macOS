# Scope

Describe one subsystem or one tightly coupled experiment. State why the change is required.

## Runtime files changed

List every changed runtime file, for example:

```text
EFI/OC/config.plist
EFI/OC/ACPI/...
EFI/OC/Kexts/...
Tools/...
```

Write `documentation only` when no runtime file changes.

## Hypothesis

State the specific technical hypothesis being tested. Avoid broad claims such as "improves stability" without a measurable failure mode.

## Evidence before change

Describe the baseline failure and link/summarize sanitized evidence.

## Evidence after change

State exactly what was retested and for how long.

## Status classification

Select the strongest status the evidence actually supports:

- [ ] Configured only
- [ ] Observed working
- [ ] User-confirmed
- [ ] Implemented, pending revalidation
- [ ] Working with workaround
- [ ] Unresolved
- [ ] Experimental

## Required checks

- [ ] `python3 Scripts/validate_release.py` passes
- [ ] Relevant plist(s) pass syntax validation
- [ ] Matching OpenCore `ocvalidate` passes for config changes
- [ ] Boot tested when runtime EFI changed
- [ ] One-subsystem experimental discipline was preserved
- [ ] No real SMBIOS values are present
- [ ] No unreviewed personal logs/screenshots are present
- [ ] `README.md` / `Docs/STATUS.md` / `Docs/TEST-MATRIX.md` were updated if status changed
- [ ] `Docs/DEVELOPMENT-HISTORY.md` records a rejected or superseded experiment when applicable
- [ ] `MANIFEST.sha256` was regenerated after final content changes

## Regression domains

Explicitly state whether the change can affect each domain:

```text
AMD kernel boot
GPU / NootedRed
native sleep / power
brightness
keyboard / touchpad
touchscreen
USB
Wi-Fi / Bluetooth
Ethernet
audio / UEFI chime
NVMe / SD
OpenCore picker
```

## Rollback

State the exact rollback path or previous known bootable configuration.
