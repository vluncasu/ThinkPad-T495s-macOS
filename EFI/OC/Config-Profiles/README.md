# OpenCore configuration profiles

The normal public configuration is:

```text
../config.plist
```

The profile in this directory exists for a narrowly scoped installation problem.

## `config-install-no-wifi.plist`

Purpose:

```text
boot the macOS installer without AirportItlwm when the Intel AX200 path is unavailable or destabilizes/crashes the installer environment
```

Intended functional difference from the normal public profile:

```text
Kernel -> Add -> AirportItlwm.kext -> Enabled
normal public config: true
installer profile:    false
```

No other functional difference is intended.

`Scripts/validate_release.py` compares the profiles and fails if another difference is introduced without updating the invariant.

## After installation

Return to the normal `config.plist`, where AirportItlwm is enabled for the user-confirmed post-install Wi-Fi path.

## SMBIOS warning

Both files in the public repository use sanitized placeholder identifiers. Do not overwrite a private personalized production configuration with the public placeholders.

See:

```text
Docs/INSTALLATION.md
Docs/NETWORKING.md
Docs/SECURITY.md
PRIVACY.md
```
