# Security and release posture

## Scope

This EFI is a compatibility and diagnostics snapshot, not a hardened Apple-equivalent security configuration.

The project still has open GPU and suspend/resume failures, so several diagnostic and permissive settings remain enabled.

## Public SMBIOS placeholders

The public repository contains:

```text
SystemSerialNumber = C02DEMO00000
MLB = C02DEMO0000000000
SystemUUID = 00000000-0000-0000-0000-000000000000
ROM = 000000000000
```

These values are intentionally unusable as personal platform identifiers.

Before booting a private production EFI, generate private values and do not commit them.

## SIP state

Current NVRAM value:

```text
csr-active-config = 03 00 00 00
```

This is not the default fully protected SIP configuration.

The repository therefore must not describe SIP as fully enabled.

A security-hardening pass should reconsider this only after verifying which compatibility features still require the current state.

## Secure boot

Current:

```text
SecureBootModel = Disabled
```

This disables OpenCore's Apple Secure Boot model emulation.

It is a compatibility choice in this snapshot, not a security recommendation.

## Vault

Current:

```text
Vault = Optional
```

The EFI is not operating as a strictly vaulted OpenCore deployment.

## Scan policy

Current:

```text
ScanPolicy = 0
```

This is permissive device/filesystem scanning and should be treated as development convenience.

## DMG loading

Current:

```text
DmgLoading = Signed
```

This is more restrictive than allowing arbitrary DMG images, but it does not negate the other permissive settings.

## ExposeSensitiveData

Current:

```text
ExposeSensitiveData = 6
```

The configuration intentionally exposes diagnostic information useful during development. This is not a minimum-disclosure release posture.

## Debug settings

Current:

```text
AppleDebug = true
ApplePanic = true
LogModules = *
Target = 67
keepsyms=1
debug=0x100
```

These settings improve failure analysis.

They also demonstrate that the EFI should be characterized as a diagnostic-capable engineering snapshot rather than a final hardened deployment.

## Update policy

Current values include:

```text
BlacklistAppleUpdate = true
run-efi-updater = No
```

This avoids handing firmware-update behavior to Apple's updater path on non-Apple firmware.

## OpenCore SecureBoot protection quirk

`ProtectSecureBoot=true` is a Booter quirk and should not be confused with:

```text
SecureBootModel = Disabled
```

The two settings are in different OpenCore domains and do not mean that Apple Secure Boot model validation is enabled.

## Authentication restart

```text
AuthRestart = true
```

This is present in the snapshot. Its practical security implications depend on the FileVault/authenticated-restart state of the actual installation and are not separately validated here.

## Public release hygiene

Never commit:

- real serial number;
- real MLB;
- real ROM;
- real SystemUUID;
- Apple ID or iCloud account information;
- FileVault recovery data;
- browser profiles;
- full raw diagnostic archives containing usernames or unrelated application data;
- unredacted screenshots containing private identifiers.

## Evidence sanitization

The public evidence directory intentionally contains excerpts rather than raw diagnostic archives.

Raw development archives included personal hostnames and paths. The public repository should retain only technical lines required to support documented conclusions.

## Hardening checklist after platform stabilization

After GPU and sleep are solved, perform a separate validation branch for:

1. remove unnecessary debug boot arguments;
2. reduce OpenCore debug exposure;
3. test default/full SIP if compatible;
4. select an appropriate SecureBootModel if feasible;
5. review Vault policy;
6. define a restrictive ScanPolicy;
7. review `ExposeSensitiveData`;
8. review APFS MinDate/MinVersion;
9. verify FileVault boot;
10. validate recovery boot;
11. retest installer/recovery Wi-Fi strategy;
12. retest NVRAM persistence and Reset NVRAM behavior.

Do not mix security hardening with an unresolved hardware-driver experiment. Change one risk domain at a time.
