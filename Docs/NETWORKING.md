# Networking

## Overview

The target contains:

```text
Wi-Fi: Intel AX200
Bluetooth: Intel USB controller
Ethernet: Realtek RTL8111 family
```

The normal installed-system configuration and the macOS installer configuration are intentionally different for Wi-Fi.

## Wi-Fi - installed system

Normal production profile:

```text
AirportItlwm.kext
version 2.3.0
Enabled = true
```

The machine owner confirmed post-install Wi-Fi operation.

This is a user-confirmed result.

The public diagnostic archive is not a formal throughput/roaming certification suite.

## Wi-Fi - installer stage

Known target-specific issue:

```text
during macOS installation:
  Wi-Fi may be unavailable
  AirportItlwm path can destabilize/crash the installer
```

This must be listed in all installation documentation because it affects initial deployment even though the installed OS can use Wi-Fi afterward.

## Installer no-Wi-Fi profile

Path:

```text
EFI/OC/Config-Profiles/config-install-no-wifi.plist
```

Design requirement:

```text
normal config: AirportItlwm Enabled = true
installer config: AirportItlwm Enabled = false
```

The profile should not accumulate unrelated differences.

That constraint is checked by the repository validation script.

## Installation network strategy

Preferred:

```text
Ethernet
```

or:

```text
offline/full macOS installer
```

Then restore the normal production profile after installation.

Do not troubleshoot installer Wi-Fi as if it were proof that AX200 support is broken in the installed OS.

## Bluetooth hardware

Captured USB device:

```text
Bluetooth USB Host Controller
Vendor ID: 0x8087
Product ID: 0x0029
Built-In: yes
```

## Bluetooth stack

Current production kexts:

```text
IntelBTPatcher.kext 2.4.0
IntelBluetoothFirmware.kext 2.4.0
BlueToolFixup.kext 2.6.8
```

Diagnostics show the Intel Bluetooth firmware driver matched the device.

## Bluetooth status language

Supported claims:

```text
USB controller enumerates
firmware stack is configured/loaded
```

The public archive does not contain a complete formal pairing, reconnect, audio-device and long-duration reliability matrix.

Therefore the documentation does not claim exhaustive Bluetooth stability.

## Bluetooth and sleep

The controlled sleep test logged:

```text
com.apple.bluetooth.sleep is slow (506 ms)
```

This is a useful isolation clue.

It does not establish Bluetooth as the root cause of failed wake.

A valid future test is to disable the entire Intel Bluetooth stack and repeat the same sleep procedure with no other changes.

## Ethernet

Current:

```text
RealtekRTL8111.kext
version 2.4.2
```

The driver is present in the normal production configuration.

The public evidence archive does not contain a dedicated:

- link-negotiation matrix;
- sustained throughput result;
- sleep/wake reconnect result.

Therefore status is `Configured`, not an artificially inflated `fully validated`.

## Network regression plan

### Wi-Fi

Test:

1. cold boot;
2. associate to known network;
3. DHCP;
4. DNS;
5. 30-minute traffic;
6. reconnect after interface toggle;
7. reconnect after display sleep;
8. reconnect after native sleep once sleep is fixed.

### Bluetooth

Test:

1. controller present in System Information;
2. toggle on/off;
3. pair keyboard/mouse;
4. disconnect/reconnect;
5. 30-minute use;
6. wake behavior;
7. optional audio device separately.

### Ethernet

Test:

1. link at expected speed;
2. DHCP;
3. sustained traffic;
4. large file transfer;
5. reconnect after cable unplug;
6. wake reconnect.

## Failure isolation rule

Do not update:

```text
AirportItlwm
IntelBluetoothFirmware
BlueToolFixup
RealtekRTL8111
```

simultaneously while diagnosing one network issue.

Keep Wi-Fi, Bluetooth and Ethernet as separate experiment domains.
