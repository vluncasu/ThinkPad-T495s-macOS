# OpenCore startup-chime configuration

This directory documents the pre-boot audio configuration. Runtime macOS audio and OpenCore UEFI audio are separate paths.

## UEFI path

Enabled driver:

```text
AudioDxe.efi
```

Relevant current configuration:

```text
UEFI -> Audio -> AudioSupport = true
UEFI -> Audio -> AudioDevice = PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x6)
UEFI -> Audio -> AudioCodec = 0
UEFI -> Audio -> AudioOutMask = 1
UEFI -> Audio -> PlayChime = Enabled
UEFI -> Audio -> MaximumGain = -15
UEFI -> Audio -> MinimumAssistGain = -30
UEFI -> Audio -> MinimumAudibleGain = -55
UEFI -> Audio -> SetupDelay = 0
UEFI -> Audio -> ResetTrafficClass = false
```

This path exists before the macOS AppleALC stack is available.

## Runtime path

macOS runtime audio is configured independently through:

```text
AppleALC.kext 1.9.1
boot-arg alcid=97
codec: Realtek ALC257
```

A successful startup chime does not prove speaker/headphone runtime routing, and a working runtime audio endpoint does not prove the UEFI chime path.

## Evidence status

The public snapshot proves that the UEFI audio path is configured. It does not retain a formal target-machine artifact proving audible chime output.

Therefore the correct status is:

```text
startup chime: Configured
startup chime audibility: Not formally archived
runtime ALC257 path: Configured
speaker/headphone endpoint matrix: Not formally archived
```

See [`../../Docs/AUDIO.md`](../../Docs/AUDIO.md).
