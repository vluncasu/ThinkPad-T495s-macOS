# GitHub publication checklist

## Repository integrity

- [ ] `python3 Scripts/validate_release.py` passes.
- [ ] All plist files parse successfully.
- [ ] The matching OpenCore `ocvalidate` passes for the published `config.plist`.
- [ ] Every enabled ACPI, kext, driver and tool path exists.
- [ ] `MANIFEST.sha256` is regenerated after the final file change.
- [ ] The release ZIP passes an archive integrity test.
- [ ] The release ZIP is extracted into a clean directory and validated again.

## Runtime evidence boundaries

- [ ] GPU acceleration is not described as stable while the Chrome/AMD GFX hang remains unresolved.
- [ ] Chrome software-rendering mode is described as a workaround, not a driver fix.
- [ ] Native sleep/resume is not marked working without repeatable lid-close/open and manual-sleep evidence.
- [ ] Lid continuity is not described as native sleep.
- [ ] Brightness overlay is distinguished from physical PWM backlight control.
- [ ] Touchscreen remains experimental unless IOUSB/IOHID enumeration and end-to-end touch input are demonstrated.
- [ ] Installer-stage Wi-Fi behavior is distinguished from post-install Wi-Fi behavior.

## Privacy and identifiers

- [ ] Public SMBIOS values are placeholders.
- [ ] No real serial, MLB, ROM or SystemUUID is present.
- [ ] No personal username, hostname or home-directory path is present.
- [ ] Screenshots do not expose private identifiers.
- [ ] Diagnostic excerpts contain only evidence required to support the documented claim.

## GitHub metadata

- [ ] `README.md` is current.
- [ ] `RELEASES/v17.1.md` matches the current status.
- [ ] `RELEASE-NOTES.md` matches the current status.
- [ ] `CHANGELOG.md` is current.
- [ ] `SECURITY.md`, `SUPPORT.md`, `PRIVACY.md`, `CONTRIBUTING.md` and `LICENSE.md` are present.
- [ ] Issue and pull-request templates are present.
- [ ] `.github/release.yml` is present.
- [ ] CI validation workflow is present.

## Repository SEO and discoverability

- [ ] Set repository description to: `OpenCore EFI for Lenovo ThinkPad T495s (20QK) | macOS Ventura on AMD Ryzen 7 PRO 3700U with Radeon Vega 10 GPU acceleration via NootedRed`
- [ ] Add GitHub Topics (Settings > General > Topics): `hackintosh`, `opencore`, `thinkpad`, `thinkpad-t495s`, `amd-hackintosh`, `vega10`, `nootedred`, `macos-ventura`, `ryzen`, `amd-laptop`, `lenovo`, `picasso`, `efi`, `radeon-vega`
- [ ] Verify the rendered README title contains "Hackintosh" and "Vega 10" (primary search terms).

## GitHub Release

- [ ] Create tag `v17.1` from the exact published commit.
- [ ] Create release title `ThinkPad T495s macOS v17.1 - documented research snapshot`.
- [ ] Use `RELEASES/v17.1.md` as the release body.
- [ ] Mark the release as a pre-release while the two primary blockers remain unresolved.
- [ ] Upload the ZIP asset.
- [ ] Upload the corresponding `.sha256` asset.
- [ ] Verify the uploaded asset hash after download.
