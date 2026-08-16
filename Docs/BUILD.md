# Build, validation and public-release procedure

This repository is a hardware-specific OpenCore snapshot plus documentation, diagnostic helpers and one custom user-space brightness component. A reproducible release therefore has two distinct build domains:

1. EFI assembly and configuration validation;
2. target-side compilation of the macOS user-space brightness overlay.

No repository document should imply that the bundled third-party EFI binaries are built from source by this project.

## 1. Release inputs

A release is assembled from the following classes of input:

| Input class | Examples | Treatment |
|---|---|---|
| OpenCore configuration | `EFI/OC/config.plist` | Project-maintained configuration; public copy is sanitized. |
| ACPI tables | `EFI/OC/ACPI/*.aml` | Bundled compiled tables; their enabled paths must match `config.plist`. |
| Third-party EFI drivers | `EFI/OC/Drivers/*.efi` | Bundled binaries; upstream projects remain authoritative. |
| Third-party kexts | `EFI/OC/Kexts/*.kext` | Bundled binaries; versions are inventoried in `COMPONENTS.md`. |
| Public configuration profile | `EFI/OC/Config-Profiles/config-install-no-wifi.plist` | Derived from the normal public config with AirportItlwm disabled. |
| Project scripts | `Tools/**/*.command` | Shell scripts retained as source. |
| Brightness source | `Tools/Brightness/src/T495sBrightnessOverlay.m` | Compiled locally on the target macOS installation. |
| Documentation | `README.md`, `Docs/*.md` | Must match the actual repository snapshot and archived evidence. |
| Sanitized evidence | `Docs/Evidence/*`, benchmark images | Public evidence only; private identifiers must not be present. |

## 2. Brightness overlay build

The v17 visual brightness extension is not shipped as a precompiled macOS executable. `Tools/Brightness/Install.command` builds it on the target machine.

The installer resolves the active Apple compiler and SDK with:

```bash
xcrun --find clang
xcrun --sdk macosx --show-sdk-path
```

It compiles:

```text
Tools/Brightness/src/T495sBrightnessOverlay.m
```

with:

```text
minimum deployment target: macOS 13.0
Objective-C ARC: enabled
optimization: -O2
frameworks: AppKit, CoreGraphics, IOKit
```

The resulting executable is installed as:

```text
~/Library/Application Support/T495s/T495sBrightnessOverlay
```

and started by the per-user LaunchAgent:

```text
~/Library/LaunchAgents/com.terabitlab.t495s-brightness-overlay.plist
```

The build requires Apple Command Line Tools or Xcode because `clang` and the macOS SDK are required.

## 3. Brightness migration behavior

The v17 installer intentionally removes the obsolete v15/v16 gamma bridge before loading the new overlay.

It performs the following migration operations:

```text
bootout old gamma LaunchAgent
bootout current overlay LaunchAgent if already loaded
terminate T495sBrightnessBridge
terminate T495sBrightnessOverlay
remove old gamma LaunchAgent and old bridge executable
install new overlay executable
invoke new overlay with --restore-only
write and bootstrap the v17 LaunchAgent
```

`--restore-only` calls `CGDisplayRestoreColorSyncSettings()` once. This restores the system ColorSync transfer state after the previous experimental gamma bridge. The running v17 overlay does not continuously install custom gamma transfer curves.

This distinction is important and is documented in detail in [`BRIGHTNESS.md`](BRIGHTNESS.md).

## 4. EFI consistency validation

The release validator checks the relationships that can be verified without booting the target machine:

```bash
python3 Scripts/validate_release.py
```

The validator performs at least the following checks:

1. parses every XML/binary plist that Python `plistlib` can read;
2. confirms all enabled ACPI entries exist on disk;
3. confirms all enabled UEFI driver entries exist on disk;
4. confirms all enabled kext bundle paths exist on disk;
5. confirms the public SMBIOS values are placeholders rather than production identifiers;
6. confirms the installer no-Wi-Fi profile differs from the normal public profile only by `AirportItlwm.kext -> Enabled = false`;
7. confirms the current kernel patch inventory contains the expected 22 entries, of which 20 are enabled;
8. confirms the v17 brightness source does not contain the rejected continuous-gamma API `CGSetDisplayTransferByFormula`;
9. confirms the default post-install script does not install the historical lid-continuity power workaround or modify `pmset`;
10. validates local Markdown links;
11. rejects emoji code points in documentation/source metadata covered by the validator;
12. scans public text for selected private-path patterns;
13. verifies `MANIFEST.sha256` when present.

These checks are repository-integrity checks. They are not a substitute for physical hardware validation.

## 5. macOS-side syntax validation

Before public release, shell scripts should also be syntax-checked on macOS or a compatible `zsh` environment:

```bash
find . -name '*.command' -print0 | while IFS= read -r -d '' file; do
    zsh -n "$file"
done
```

All plist files should be validated on macOS with:

```bash
find . -name '*.plist' -print0 | while IFS= read -r -d '' file; do
    plutil -lint "$file"
done
```

The Python validator remains useful in CI because it does not depend on macOS-only tools.

## 6. OpenCore semantic validation

`plistlib` and `plutil` prove that a plist is syntactically valid; they do not prove that every OpenCore key/value pair is semantically valid for the bundled OpenCore build.

Before an EFI release, run the `ocvalidate` executable from the same OpenCore version used by the package against:

```text
EFI/OC/config.plist
```

and, separately, against any bootable profile intended to replace it.

Do not treat a successful XML parse as equivalent to `ocvalidate` success.

## 7. Public SMBIOS sanitization

The GitHub copy must never contain the target machine's production Apple identifiers.

The public snapshot intentionally contains:

```text
SystemSerialNumber = C02DEMO00000
MLB                = C02DEMO0000000000
SystemUUID         = 00000000-0000-0000-0000-000000000000
ROM                = 00 00 00 00 00 00
```

Before publishing:

1. inspect `EFI/OC/config.plist`;
2. inspect every config profile;
3. inspect Markdown, text evidence and screenshots;
4. remove user names and absolute home-directory paths from public diagnostics;
5. ensure benchmark images do not expose the original serial number;
6. re-run `Scripts/validate_release.py`.

The public placeholders are intentionally unsuitable for a production Apple-services identity. Each user must generate their own values before booting the public EFI.

See [`SECURITY.md`](SECURITY.md) and [`../PRIVACY.md`](../PRIVACY.md).

## 8. Evidence minimization

Raw diagnostic archives often contain more information than is necessary for a public issue report. The release therefore publishes minimal evidence excerpts instead of complete private bundles when possible.

Public evidence should retain only what is needed to support the documented claim, for example:

```text
GPU reset event
submitting process
graphics hardware
restart channel
relevant timeout/hang lines
```

or:

```text
sleep entry timestamp
wake timestamp when present
forced-restart boundary
relevant power assertions
```

See [`EVIDENCE.md`](EVIDENCE.md).

## 9. Manifest generation

`MANIFEST.sha256` is a repository-content integrity index, not a cryptographic signature of authorship.

Generate it from the repository root after all content is final:

```bash
find . -type f \
  ! -path './MANIFEST.sha256' \
  ! -name '*.zip' \
  -print0 \
  | sort -z \
  | xargs -0 shasum -a 256 \
  > MANIFEST.sha256
```

The manifest must be regenerated after any documentation, script, plist or binary change.

## 10. ZIP release generation

Create the archive from the parent directory so that one top-level project folder is preserved:

```bash
REPO_DIR="$(basename "$PWD")"
cd ..
zip -qry ThinkPad-T495s-macOS-v17.1-GitHub-Documentation-Final.zip "$REPO_DIR"
```

Then verify archive integrity:

```bash
unzip -t ThinkPad-T495s-macOS-v17.1-GitHub-Documentation-Final.zip
```

For the strongest check, extract the ZIP into a new empty directory and run the repository validator again from the extracted copy.

## 11. What build validation cannot prove

Repository validation cannot prove any of the following:

- long-duration GPU stability;
- successful native sleep/resume;
- actual touchscreen enumeration;
- speaker/headphone routing;
- startup-chime audibility;
- Bluetooth pairing reliability;
- Ethernet throughput;
- SD-card read/write behavior;
- the final v17 overlay's sustained behavior on the physical target.

Those are runtime claims and must remain classified according to the evidence in [`STATUS.md`](STATUS.md) and [`TEST-MATRIX.md`](TEST-MATRIX.md).

## 12. Release acceptance criteria

A documentation/publication release is acceptable only when:

```text
repository validator: pass
plist syntax validation: pass
OpenCore ocvalidate: pass on target release tooling
all enabled paths present: pass
no production SMBIOS identifiers: pass
no broken local documentation links: pass
no emoji in maintained documentation: pass
installer profile invariant: pass
manifest verification: pass
ZIP integrity: pass
fresh-extraction validation: pass
runtime limitations: explicitly documented, not hidden
```

A documentation release does not change the runtime status of a subsystem. A subsystem moves from `Configured`, `Pending revalidation`, `Experimental` or `Unresolved` only after new target-machine evidence is collected.
