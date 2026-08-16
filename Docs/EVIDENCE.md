# Evidence and provenance

## Purpose

This document records what evidence exists and what each item can legitimately support.

The public repository does not include complete raw diagnostic archives because those files can contain:

- local usernames;
- hostnames;
- application paths;
- unrelated process data;
- device serials;
- other private identifiers.

Instead, the public `Docs/Evidence/` directory contains focused sanitized excerpts.

## Evidence classes

### Configuration evidence

Source:

```text
EFI/OC/config.plist
kext Info.plist files
USBMap.kext Info.plist
helper source code
installer scripts
```

Supports statements such as:

```text
a component is configured
a boot argument is present
a source function exists
a kext version is bundled
```

Does not by itself support:

```text
feature is stable
hardware endpoint works
```

### Runtime diagnostic evidence

Sources include:

```text
system_profiler
IORegistry
kmutil
pmset
unified log
gpuRestart
panic reports
```

Supports statements about actual observed runtime state.

### Benchmark evidence

Sources:

```text
Cinebench R23 screenshot
Geekbench Metal screenshots
```

Supports the recorded score and displayed environment.

### User-confirmed evidence

Explicit machine-owner reports are used where no formal diagnostic artifact is required or available.

Examples:

```text
Chrome works without hardware acceleration
post-install Wi-Fi works
Elan touchpad works
```

These are intentionally labeled `User-confirmed`, not silently upgraded to instrumented validation.

## Graphics evidence

Primary source bundle:

```text
T495s-Chrome-After-20260801-035133
```

Public excerpt:

```text
Docs/Evidence/GPU-RESET-EXCERPT.txt
```

Supported observations:

```text
Event = GPU Reset
Application = Google Chrome Helper
Graphics Hardware = AMD Radeon Vega 10
Restart Channel = 13 GFX
SubmitContext = Metal
AMDRadeonX5000 GFX timeout/hang
IOAcceleratorFamily2 hardware error path
```

Additional captured panic reports show AMD graphics diagnosis/restart backtraces.

The raw public release omits personal path/hostname data.

## Sleep evidence

Primary source bundles:

```text
T495s-sleep-before-20260801-032728
T495s-sleep-after-20260801-033044
T495s-sleep-diagnostics-20260801-002820
```

Public excerpt:

```text
Docs/Evidence/SLEEP-EXCERPT.txt
```

Supported observations:

```text
SleepDisabled = 0
03:28:14 sleep entry
03:28:19 slow Bluetooth/apsd acknowledgements
no completed wake before restart
earlier successful HID DarkWake -> FullWake
```

The evidence also shows Screen Sharing and external-media assertions around the test environment.

Documentation treats these as confounders/observations, not automatically as causes.

## Touchscreen evidence

Focused probe sets were collected repeatedly.

Public excerpt:

```text
Docs/Evidence/TOUCHSCREEN-EXCERPT.txt
```

Key result from later probe:

```text
Expected:
  VID 0x1A86
  PID 0xE5E3
  USB2IIC_CTP_CONTROL

Result:
  target not enumerated by macOS
```

The same probe shows:

```text
Genesys 05E3:0610 internal hub present
AzureWave 13D3:5406 camera present
Intel Bluetooth 8087:0029 present
```

The bridge probe opens IOHIDManager successfully but receives no target device match.

## Historical NootedRed dependency evidence

Early log:

```text
Lilu 1.6.8 loaded
NootedRed requested compatible Lilu 1.7.0
dependency resolution failed
```

Current bundled pair:

```text
Lilu 1.7.2
NootedRed 0.9.0
```

This supports the development-history statement that an early graphics failure was a dependency mismatch rather than proof that NootedRed could never work on the machine.

## Binary comparison evidence - v13 brightness experiment

Direct comparison of v12 and v13 NootedRed binaries shows:

```text
exactly 7 changed bytes
offset 0x203e through 0x2044
```

Hashes:

```text
baseline:
ee6cc4b5a58c282556d82391c948d3d5931e0ace1e06df917e807c92c64604a0

v13:
9e73468a843845890edac625a655eb6d0201017ab52292f907c3411b410b6c64
```

v15 restored the baseline hash.

This proves the experimental patch was removed.

## Benchmark evidence

### Cinebench

```text
R23 CPU Multi Core = 3141
```

### Geekbench Metal

```text
11179
5164
```

No Geekbench CPU artifact is present.

## Evidence quality rules

### Strong claim

Example:

```text
Chrome accelerated path generated a GPU reset
```

Basis:

```text
gpuRestart report names Google Chrome Helper and Metal submit context
```

### Moderate claim

Example:

```text
Bluetooth stack is configured and controller enumerates
```

Basis:

```text
USB enumeration + loaded firmware stack
```

This does not become:

```text
Bluetooth is perfectly stable
```

without pairing/reconnect tests.

### Unsupported claim

Example:

```text
startup chime is audible
```

Configuration exists, but public proof is not archived.

Therefore status remains `Configured`.

## Sanitization rule

Before adding new public evidence:

1. copy only the minimum relevant section;
2. remove usernames;
3. remove hostnames;
4. remove unrelated process/application data;
5. remove device serials unless technically essential and non-private;
6. remove private SMBIOS values;
7. state source bundle/date;
8. preserve timestamps and technical strings required for interpretation;
9. never alter technical failure wording to make the result look better.

## Reproducibility

A future maintainer should be able to map:

```text
claim
  -> evidence class
  -> source file
  -> exact configuration state
```

If that mapping is impossible, the claim should be weakened or marked unvalidated.
