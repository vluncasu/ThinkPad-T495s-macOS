# Contributing

Contributions are accepted as engineering changes, not as unverified configuration dumps.

## Core rule

Every change must distinguish:

```text
configured
observed
user-confirmed
pending revalidation
unresolved
experimental
```

A kext being present is not evidence that the corresponding hardware feature works end to end.

## One subsystem per experiment

Prefer one isolated variable or one tightly coupled subsystem per change.

Examples:

```text
NootedRed version update
single ACPI patch change
single USB map hypothesis
single brightness implementation change
single sleep diagnostic flag
single wireless kext update
```

Avoid combining graphics, sleep, USB and input changes in one test EFI because regression attribution becomes ambiguous.

## Required bug-report context

Provide:

- exact ThinkPad machine type;
- BIOS version;
- macOS version and build;
- repository/EFI version;
- exact reproduction steps;
- whether Chrome hardware acceleration is enabled;
- whether the v17 brightness overlay is enabled;
- whether the test used the normal or no-Wi-Fi installer profile;
- whether external USB/HDMI/dock devices were connected;
- relevant sanitized evidence.

## Graphics reports

For a GPU hang, preserve when available:

```text
gpuRestart report
panic report
WindowServer/IOAccelerator/AMDRadeonX5000 log lines
application/process that submitted the failing work
Chrome acceleration state
```

Do not conclude that GPU stability is fixed because Geekbench Metal passes.

## Sleep reports

Record:

```bash
pmset -g
pmset -g custom
pmset -g assertions
pmset -g log
```

Also state:

```text
manual sleep or lid close
time spent asleep
wake stimulus
external devices connected
time before forced shutdown, if required
```

Do not classify screen lock, display sleep or the historical lid-continuity workaround as native sleep.

## Brightness reports

State separately:

```text
native slider/property response
physical panel-luminance response
v17 overlay enabled/disabled
Chrome GPU acceleration enabled/disabled
```

The v17 overlay must be disabled during root-cause isolation if display/windowing interaction is suspected.

## Touchscreen reports

Before proposing a production USB-map change, provide evidence that `1A86:E5E3` is actually present in macOS IOUSB or IOHID enumeration.

A Windows hardware identifier alone is not sufficient to declare the macOS USB port known.

## Network reports

For AX200 problems, distinguish:

```text
macOS installer environment
installed Ventura runtime
```

The known installer failure scope must not be generalized to post-install Wi-Fi without evidence.

## Privacy

Read [`PRIVACY.md`](PRIVACY.md) before attaching files.

Never publish real SMBIOS values, personal accounts, secrets or unreviewed raw diagnostics.

## Documentation requirement

Any PR that changes runtime behavior must update at least the relevant technical document and, when status changes, also update:

```text
README.md
Docs/STATUS.md
Docs/TEST-MATRIX.md
Docs/CHANGELOG.md
```

If a new failure mode is discovered, update `Docs/KNOWN-ISSUES.md`.

If an experiment is rejected, preserve the reason in `Docs/DEVELOPMENT-HISTORY.md` rather than deleting the historical record.

## Validation before submission

Run:

```bash
python3 Scripts/validate_release.py
```

On macOS also run plist and shell syntax checks described in [`Docs/BUILD.md`](Docs/BUILD.md).

For OpenCore configuration changes, use `ocvalidate` from the matching OpenCore release.
