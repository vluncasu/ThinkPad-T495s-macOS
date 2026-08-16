# Privacy and public-release hygiene

The development machine's diagnostic material may contain identifiers that are not appropriate for a public GitHub repository. Public releases therefore use a deliberate sanitization process.

## Public SMBIOS placeholders

The public OpenCore configuration contains dummy values:

```text
PlatformInfo -> Generic -> SystemSerialNumber = C02DEMO00000
PlatformInfo -> Generic -> MLB                = C02DEMO0000000000
PlatformInfo -> Generic -> SystemUUID         = 00000000-0000-0000-0000-000000000000
PlatformInfo -> Generic -> ROM                = 00 00 00 00 00 00
```

These values are publication placeholders, not production Apple-services identifiers.

Before booting a public EFI, generate your own appropriate SMBIOS identifiers and keep the production copy private.

## Data that must not be committed

Do not publish:

- real `SystemSerialNumber`;
- real MLB;
- real ROM;
- real `SystemUUID`;
- Apple ID/iCloud credentials or account identifiers;
- recovery keys;
- browser profiles, cookies or local-storage databases;
- saved Wi-Fi credentials;
- unrelated private application logs;
- private conversations/screenshots;
- SSH keys, API tokens or secrets;
- absolute home-directory paths when they identify a person unnecessarily;
- raw diagnostic archives without inspecting their contents first.

## Diagnostic bundles

macOS diagnostic collections can include:

```text
user names
host names
volume names
mounted external media
application process names
network information
absolute file paths
hardware serials
third-party application content
```

Before attaching diagnostics to an issue:

1. extract the archive locally;
2. search for personal names and home paths;
3. search for serial/UUID/MLB values;
4. remove unrelated logs;
5. retain only the lines needed to support the technical claim;
6. prefer a minimal sanitized excerpt where possible.

The release uses [`Docs/Evidence/`](Docs/Evidence/) for this reason.

## Benchmark images

Benchmark screenshots can expose:

```text
serial number
account name
host name
browser/session information
```

Public benchmark images in `assets/benchmarks/` must be reviewed/cropped before publication. Their purpose is to preserve score/hardware/OS evidence without exposing the original machine identity.

## Repository validation

Run:

```bash
python3 Scripts/validate_release.py
```

before publication. The validator checks selected privacy hazards and the expected public placeholder values.

Automated privacy checks are defensive, not complete. Human inspection remains mandatory.

## Production EFI handling

Treat a personalized production `config.plist` as private configuration. Do not replace the sanitized GitHub file with a production copy for convenience.

Recommended model:

```text
public repository -> sanitized placeholders
private local EFI -> unique production SMBIOS values
```

The two copies should not be confused during release packaging.
