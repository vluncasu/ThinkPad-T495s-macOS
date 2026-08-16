# Benchmarks

## Purpose

Benchmarks in this repository are retained as measured development evidence.

They are not used as proof of complete platform stability.

In particular:

```text
passing Geekbench Metal != stable long-duration GPU path
```

because accelerated Chrome later generated a reproducible GFX hang.

## Test platform

Captured benchmark metadata:

```text
Lenovo ThinkPad T495s 20QK
AMD Ryzen 7 PRO 3700U
AMD Radeon Vega 10
16 GB memory
macOS Ventura 13.7.8
build 22H730
SMBIOS MacBookPro16,3
```

## Cinebench R23

Observed CPU multi-core result:

```text
3141 pts
```

Screenshot-reported CPU:

```text
AMD Ryzen 7 PRO 3700U w/ Radeon Vega Mobile Graphics
4 cores
8 threads
2.3 GHz
single-core frequency line shows 3.3 GHz
```

Screenshot-reported OS:

```text
macOS Version 13.7.8
Build 22H730
```

![Cinebench R23 CPU multi-core](../assets/benchmarks/cinebench-r23-multicore.png)

### What this proves

It proves:

- the operating system can execute a sustained CPU rendering benchmark;
- 4C/8T topology is visible to the application;
- the measured multi-core score in that development state is 3141.

It does not prove:

- perfect CPU power management;
- native Apple CPU behavior;
- absence of every long-duration kernel issue.

## Geekbench 6 Metal - result A

Observed:

```text
Metal score: 11179
Geekbench 6.7.1 for macOS AVX2
macOS 13.7.8 build 22H730
MacBookPro16,3
upload date shown in screenshot: 2026-07-31
```

![Geekbench Metal 11179](../assets/benchmarks/geekbench-metal-11179.png)

### Interpretation

This is strong evidence that:

```text
Metal command submission works
Vega 10 is exposed as an accelerated device
```

It is not evidence that Chrome/WebGPU/WindowServer workloads are stable.

## Geekbench 6 Metal - result B

Observed later development result:

```text
Metal score: 5164
Geekbench 6.7.1 for macOS AVX2
macOS 13.7.8 build 22H730
MacBookPro16,3
upload date shown in screenshot: 2026-08-01
```

![Geekbench Metal 5164](../assets/benchmarks/geekbench-metal-5164.png)

## Why both Metal results are preserved

The repository intentionally retains both values.

A clean engineering record should not publish only the best score.

The difference:

```text
11179 -> 5164
```

is substantial and indicates that the runtime/configuration state changed materially or the GPU path exhibited inconsistent performance.

The available evidence does not establish one single cause for that score difference.

Therefore the documentation does not invent an explanation.

## Geekbench CPU

No standalone Geekbench CPU result is present in the supplied evidence archive.

Status:

```text
not available
```

The repository does not estimate a Geekbench CPU score from:

- Cinebench;
- online results;
- similar Ryzen 3700U machines.

A future result should be added only with the actual screenshot or result record from this target.

## Benchmark methodology for future releases

Record:

```text
EFI version
NootedRed version
Lilu version
boot arguments
macOS build
AC/battery state
thermal state
Chrome/brightness helper state
```

Run at least:

```text
Cinebench R23 multi-core
Geekbench CPU
Geekbench Metal x5
```

For GPU validation add:

```text
60-minute accelerated Chrome workload
video playback
WebGL/WebGPU if enabled
```

A benchmark release should report:

- all runs;
- mean;
- minimum;
- maximum;
- any crash/reset.

## Stability hierarchy

The project uses this hierarchy:

```text
API exposed
  < benchmark completes
  < repeated benchmark completes
  < application workload stable
  < sleep/wake stable
  < long-duration platform stable
```

The current Vega 10 reaches:

```text
Metal API exposed
benchmark completes
```

but does not yet satisfy:

```text
accelerated application workload stable
```

because of the Chrome GFX hang.

## Publication privacy

Benchmark screenshots in the public repository are selected/cropped to avoid publishing private production identifiers.

Do not replace them with unredacted screenshots containing:

- serial;
- private MLB;
- Apple account details;
- personal browser/session data.
