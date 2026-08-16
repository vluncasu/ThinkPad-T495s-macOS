# AMD XNU kernel patch inventory

## Scope

The current `config.plist` contains 22 kernel patch entries.

```text
Enabled: 20
Disabled: 2
```

This document records the configuration comments, target scopes and purpose categories. It does not claim authorship of the upstream patches.

## Enabled patches

| Index | Attribution/comment | Target/base | Kernel range | Functional category |
|---:|---|---|---|---|
| 0 | algrey - force `cpuid_cores_per_package` constant, 10.13-10.14 | `kernel`, `_cpuid_set_info` | 17.0.0-18.99.99 | CPUID topology |
| 1 | algrey - force `cpuid_cores_per_package` constant, 10.15-11.0 | `kernel`, `_cpuid_set_info` | 19.0.0-20.99.99 | CPUID topology |
| 2 | algrey - force `cpuid_cores_per_package` constant, 12.0-13.2 | `kernel`, `_cpuid_set_info` | 21.0.0-22.3.99 | CPUID topology |
| 3 | algrey - force `cpuid_cores_per_package` constant, 13.3+ | `kernel`, `_cpuid_set_info` | 22.4.0-23.99.99 | CPUID topology |
| 4 | algrey - `_commpage_populate`, remove `rdmsr` | kernel | 17.0.0-23.99.99 | Unsupported MSR access removal |
| 5 | algrey - `_cpuid_set_cache_info`, set CPUID proper instead of 4 | kernel | 17.0.0-23.99.99 | CPUID/cache |
| 6 | algrey - `_cpuid_set_generic_info`, remove `wrmsr(0x8B)` | kernel | 17.0.0-23.99.99 | Unsupported MSR write removal |
| 7 | algrey - `_cpuid_set_generic_info`, replace `rdmsr(0x8B)` with constant 186 | kernel | 17.0.0-23.99.99 | Unsupported MSR read substitution |
| 8 | algrey - `_cpuid_set_generic_info`, set flag=1 | kernel | 17.0.0-23.99.99 | CPU feature setup |
| 9 | algrey - `_cpuid_set_generic_info`, disable check to allow leaf 7 | kernel | 17.0.0-23.99.99 | CPUID feature leaf |
| 10 | algrey - GenuineIntel to AuthenticAMD, 10.13-11.0 | `kernel`, `_cpuid_set_info` | 17.0.0-20.99.99 | CPU vendor compatibility |
| 11 | Goldfish64/algrey - bypass GenuineIntel check panic, 12.0+ | `kernel`, `_cpuid_set_info` | 21.0.0-23.99.99 | CPU vendor compatibility |
| 12 | algrey - force `CPUFAMILY_INTEL_PENRYN`, 10.13-11.2 | kernel | 17.0.0-20.3.0 | CPU-family compatibility |
| 13 | algrey - force `CPUFAMILY_INTEL_PENRYN`, 11.3+ | `kernel`, `_cpuid_set_info` | 20.4.0-23.99.99 | CPU-family compatibility |
| 14 | algrey - `_i386_init`, remove 3 `rdmsr` calls | kernel | 17.0.0-23.99.99 | Unsupported MSR access removal |
| 15 | algrey/XLNC - remove version check and panic | kernel | 17.0.0-23.99.99 | Kernel compatibility guard |
| 16 | CaseySJ - `IOPCIBridge::probeBusGated`, disable 10-bit tags | `com.apple.iokit.IOPCIFamily` | 21.0.0-23.99.99 | PCI compatibility |
| 18 | Visual - remove non-monotonic time panic in thread paths | kernel | 21.0.0-23.99.99 | AMD timing compatibility |
| 19 | Visual - remove non-monotonic time panic in dispatch paths | kernel | 21.0.0-23.99.99 | AMD timing compatibility |
| 21 | Shaneee - `_mtrr_update_action`, Fix PAT | kernel | 17.0.0-23.99.99 | PAT/MTRR memory-type compatibility |

## Disabled patches retained in configuration

| Index | Comment | State | Reason in current snapshot |
|---:|---|---|---|
| 17 | CaseySJ - `IOPCIIsHotplugPort`, AM5 PCI bus enumeration | Disabled | Target is Picasso mobile, not an AM5 platform; entry is not active. |
| 20 | algrey - `_mtrr_update_action`, fix PAT | Disabled | Alternative PAT implementation; Shaneee PAT patch at index 21 is active instead. |

## Patch categories

### CPUID and CPU-family adaptation

Indexes:

```text
0, 1, 2, 3, 5, 8, 9, 10, 11, 12, 13
```

These remove Intel-only assumptions or provide the CPU topology/family semantics required for XNU to progress on this AMD processor.

### MSR access adaptation

Indexes:

```text
4, 6, 7, 14
```

These remove or substitute model-specific register operations that cannot be executed in the same way on the target AMD CPU.

### Kernel guard/timing adaptation

Indexes:

```text
15, 18, 19
```

These bypass compatibility checks or panics that are not valid for the AMD timing/runtime behavior being used.

### PCI adaptation

Index:

```text
16
```

This alters the Apple PCI bridge path related to 10-bit tags.

### PAT/MTRR adaptation

Active:

```text
21 - Shaneee PAT
```

Inactive alternative:

```text
20 - algrey PAT
```

Only one of the two alternative PAT patch entries is active in this snapshot.

## Why kernel-range scoping matters

The patch set contains version-specific variants because XNU machine code changes across Darwin releases.

A patch that matches Ventura does not automatically apply safely to:

- Sonoma;
- Sequoia;
- later macOS releases;
- future security updates that change the target bytes.

The current primary target is:

```text
macOS Ventura 13.7.8
Darwin 22.6.0
build 22H730
```

Do not expand patch `MaxKernel` values merely to make a newer OS boot without first validating the target instructions.

## Relationship to CPU power-management kexts

The binary patch set makes XNU compatible enough to execute on AMD.

It does not replace:

```text
AMDRyzenCPUPowerManagement.kext
SMCProcessorAMD.kext
ForgedInvariant.kext
```

Those components address different runtime/support functions.

## Secondary panic observations

The Chrome diagnostic archive contains two additional panic reports in which backtraces include:

- an `AMDRyzenCPUPowerManagement` timer callback;
- `SMCProcessorAMD` stop logic.

These are retained as secondary observations.

They are not currently promoted to a third primary platform defect because:

- the panics were collected during a period of severe GPU/system instability;
- independent reproduction has not been established;
- a single backtrace appearance is not sufficient to establish root cause.

The correct next step for those panics is isolated reproduction, not removal of the kexts based solely on correlation.
