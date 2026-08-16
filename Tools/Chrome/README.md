# Chrome software-rendering containment path

## Status

Accelerated Google Chrome is an unresolved reproducer for the primary GPU-stability problem on this T495s.

The user explicitly confirmed that Chrome operates when hardware acceleration is disabled. This is classified as `PASS-USER` for that containment mode, not as proof that the underlying AMD graphics stack is stable.

## Captured accelerated failure

The retained GPU reset evidence identifies:

```text
Event: GPU Reset
Application: Google Chrome Helper
Graphics Hardware: AMD Radeon Vega 10
SubmitContext: Metal
Restart Channel: GFX
IOAcceleratorFamily2: hardware error/restart path
AMDRadeonX5000: channel 0 GFX timeout/hang
```

See [`../../Docs/GRAPHICS.md`](../../Docs/GRAPHICS.md) and [`../../Docs/Evidence/GPU-RESET-EXCERPT.txt`](../../Docs/Evidence/GPU-RESET-EXCERPT.txt).

A completed Geekbench Metal run does not contradict this result. The two workloads exercise different command sequences and stability characteristics.

## Preferred persistent Chrome setting

In Chrome:

```text
Settings
-> System
-> disable "Use graphics acceleration when available"
-> relaunch Chrome
```

The exact UI wording can change between Chrome releases. The required state is hardware graphics acceleration disabled.

## Safe launcher

For an explicit one-shot software-rendered launch:

```bash
./Tools/Chrome/Launch-Safe.command
```

The script closes an existing Chrome process and starts the installed Chrome binary with:

```text
--disable-gpu
--disable-gpu-compositing
--disable-accelerated-video-decode
```

It does not modify OpenCore, NootedRed, system graphics kexts or the user's EFI.

## What this workaround proves

It supports the following engineering classification:

```text
accelerated Chrome -> reproduces graphics failure
software-rendered Chrome -> user-confirmed functional
```

This strengthens the diagnosis that the failing path is GPU/graphics-stack dependent.

It does **not** prove:

- NootedRed is generally stable;
- every non-Chrome accelerated application is safe;
- video decode is hardware accelerated;
- Metal is safe for long-duration workloads;
- the GPU hang is caused by Chrome itself rather than the driver path exposed by Chrome.

## Regression isolation with brightness

The rejected v15/v16 gamma bridge independently caused a display/GPU-interaction regression: disabling that bridge removed the bridge-specific Chrome freeze.

After the gamma bridge was removed, accelerated Chrome still produced serious artifacts and a later total system hang. The documentation therefore separates two findings:

1. continuous custom gamma programming was an avoidable instability source and was removed;
2. an independent accelerated Chrome/NootedRed/AMDRadeonX5000 failure remains.

The v17 AppKit overlay must still be independently revalidated; it is not used as evidence that the GPU issue is fixed.
