# Native power management, sleep and resume

## Current conclusion

Native suspend/resume is the second primary unresolved platform issue.

The evidence does not support either extreme statement:

```text
sleep is disabled
```

or:

```text
sleep works normally
```

The supported conclusion is:

> macOS can enter a native sleep transition and successful wake transitions have occurred, but suspend/resume is not repeatable or reliable on the current firmware, AMD graphics and driver stack.

## Firmware constraint

The target BIOS is:

```text
R13ET56W 1.30
```

The photographed `Config -> Power` page does not expose a Linux S3 / Windows Modern Standby selector.

Therefore this repository must not instruct the target user to select a BIOS sleep-state option that is not present.

## Production power policy

The current v17 default `Tools/Install.command` states:

```text
Power and sleep settings: unchanged
```

It does not install the historical continuity agents.

Native sleep testing should therefore be performed against the actual macOS power-management path, not against the old display-off workaround.

## Controlled test preparation

The controlled 2026-08-01 pre-sleep capture showed:

```text
SleepDisabled = 0
```

and `pmset` settings including:

```text
standby = 0
hibernatemode = 0
sleep = 10
tcpkeepalive = 0
powernap = 0
proximitywake = 0
ttyskeepawake = 0
lidwake = 1
```

These values were part of the diagnostic state, not a permanent recommendation for every future configuration.

## Assertions before the controlled test

The pre-test environment contained assertions from:

```text
screensharingd
powerd external media
```

Notably:

```text
PreventSystemSleep: Remote user is connected
ExternalMedia: com.apple.powermanagement.externalmediamounted
```

The Screen Sharing assertion is a confounding condition and should normally be removed from a sleep test.

However, the timeline records that the Screen Sharing `PreventSystemSleep` assertion was released before the actual sleep entry.

Therefore Screen Sharing alone is not a sufficient explanation for the failed resume.

## Controlled failed-resume timeline

Relevant events:

```text
03:27:43
  screensharingd PreventSystemSleep still present
  external media assertion present

03:27:56
  screensharingd PreventSystemSleep released

03:28:11
  screensharingd UserIsActive client died

03:28:14
  Entering Sleep state due to 'Software Sleep'
  TCPKeepAlive=disabled
  battery charge 82%

03:28:19
  Delays to Sleep notifications:
    com.apple.bluetooth.sleep slow: 506 ms
    com.apple.apsd slow: 4859 ms

03:29:51
  software-initiated shutdown / new boot context appears
```

There is no completed wake event between:

```text
03:28:14 sleep entry
```

and:

```text
03:29:51 restart/new boot context
```

The test therefore confirms successful entry into the sleep transition but failed/unfinished resume from the user's perspective.

## Successful wake evidence

Earlier logs contain a successful short transition:

```text
00:30:55 Entering Sleep state
00:30:59 DarkWake from Invalid due to HID Activity
00:31:00 DarkWake to FullWake due to HID Activity
00:31:00 WakeTime: 0.541 sec
```

Another recorded sequence includes:

```text
01:22:47 Entering DarkWake
01:29:56 DarkWake to FullWake due to UserActivity Assertion
WakeTime: 1.831 sec
```

These observations matter because they disprove the simpler hypothesis that the platform can never execute any wake transition.

## Interpretation

The current evidence supports:

```text
sleep entry capability: yes
some wake transitions: yes
repeatable normal resume: no
lid-close native sleep reliability: no
```

The failure may occur in:

- device power-state callbacks;
- graphics/display resume;
- USB/Bluetooth resume;
- platform/ACPI state;
- another driver callback;
- a combination of those.

The current evidence is not sufficient to assign a single root cause.

## Graphics relevance

NootedRed/AMD graphics remain a plausible participant because:

- GPU stability is independently unresolved;
- graphics power-state callbacks are part of suspend/resume;
- an upstream NootedRed issue documents a separate AMD laptop case with a wake transition timeout involving `IOGraphicsFamily`.

That upstream issue is supporting context, not proof that this T495s has the identical root cause.

The T495s sleep evidence must remain primary.

## Bluetooth and apsd observations

The controlled sleep transition records:

```text
Bluetooth sleep acknowledgement: 506 ms
apsd sleep acknowledgement: 4859 ms
```

These are slow acknowledgements.

They are diagnostic observations, not proven root causes.

A future isolation test can remove Bluetooth from the boot profile and compare behavior.

## External media observation

The pre-test assertions include mounted external media.

Future clean tests should remove all unnecessary:

- USB storage;
- docks;
- hubs;
- HDMI devices;
- remote desktop sessions.

Again, the external-media assertion is a test confounder, not an established cause.

## Historical sleep experiments

### Early wake testing

Once the v8 accelerated baseline existed, v9 and later packages began isolating wake/display behavior.

This was necessary because a black display after wake can represent at least two different states:

```text
system did not resume
```

versus:

```text
system resumed but graphics/display did not return
```

The diagnostic design therefore uses `pmset`, unified logs and later panic timeout mechanisms rather than judging solely from the screen.

### v11 hibernation experiment

v11 tested a hibernation-oriented path with settings including:

```text
hibernatemode 25
```

and OpenCore hibernation-related configuration.

Result:

```text
did not solve reliable resume
```

The experiment was not retained as the production solution.

### v15/v16 lid continuity

When native suspend was still unreliable, a userspace continuity workaround was built.

`Tools/Power/Enable-Continuity.command` intentionally applies:

```text
disablesleep 1
sleep 0
standby 0
autopoweroff 0
hibernatemode 0
powernap 0
tcpkeepalive 0
proximitywake 0
ttyskeepawake 0
womp 0
```

It also installs:

```text
user LaunchAgent:
  com.terabitlab.t495s-lid-continuity

root LaunchDaemon:
  com.terabitlab.t495s-lid-power
```

### What lid continuity actually does

On lid close, the user agent:

- locks the session;
- invokes display sleep;
- keeps the machine from entering system suspend.

The root daemon can change low-power policy while the lid state changes.

Conceptually:

```text
lid close
  -> lock session
  -> turn display off
  -> system remains powered
```

This provides continuity but not native sleep.

It is unsafe to place the laptop in a bag while this mode is active because the CPU and other hardware remain powered.

### v17 production decision

v17 stopped installing continuity mode automatically.

This is the correct design because a workaround that prevents sleep must not silently masquerade as a native fix.

The scripts remain for historical/diagnostic use only.

## v16.2 power-timeout diagnostic profile

A dedicated diagnostic EFI enabled:

```text
PowerTimeoutKernelPanic = true
darkwake=0
swd_panic=1
```

The goal was to convert indefinite power-transition stalls into a diagnostic panic when possible.

This profile was an instrumentation build, not the normal production profile.

The current public production configuration has:

```text
PowerTimeoutKernelPanic = false
```

and does not include `darkwake=0 swd_panic=1` in normal boot arguments.

## Clean native sleep test protocol

### Preparation

1. boot normal production EFI;
2. disable Screen Sharing and Remote Management;
3. disconnect external storage;
4. disconnect HDMI/docks;
5. disable historical lid continuity;
6. confirm:

```bash
pmset -g
pmset -g custom
pmset -g assertions
```

7. record loaded relevant kexts;
8. confirm brightness gamma bridge is absent.

### Test A - Apple menu sleep

1. choose Apple menu -> Sleep;
2. wait 30 seconds;
3. trigger one wake event;
4. wait for full resume;
5. if screen remains black, determine whether SSH/ping/keyboard/audio response exists before forced shutdown;
6. collect logs after reboot.

### Test B - lid

Only after Test A is repeatable:

1. close lid;
2. wait 30 seconds;
3. reopen lid;
4. record full-wake behavior.

Do not start with lid testing if manual sleep is not stable.

### Test C - Bluetooth isolated

If failure persists:

- boot a profile with Intel Bluetooth stack disabled;
- repeat the same test without changing anything else.

### Test D - Wi-Fi isolated

Repeat with AirportItlwm disabled.

### Test E - graphics-focused

If the system wakes but the panel does not:

- test remote reachability;
- inspect `IOGraphics`, `AMDRadeonX5000`, `WindowServer`;
- collect power-timeout panic if available.

## Diagnostic commands

Before sleep:

```bash
pmset -g
pmset -g custom
pmset -g cap
pmset -g assertions
ioreg -r -k AppleClamshellState -d 4
kmutil showloaded
```

After forced restart:

```bash
pmset -g log
log show --last 45m --style compact
```

Relevant search terms:

```text
Sleep
Wake
DarkWake
FullWake
WakeTime
IOGraphics
AMDRadeon
NootedRed
IOUSB
Bluetooth
powerd
```

## Acceptance criteria for calling native sleep fixed

At minimum:

1. 10 manual sleep/wake cycles;
2. 10 lid close/open cycles;
3. tests on battery;
4. tests on AC;
5. Wi-Fi reconnect after wake;
6. Bluetooth remains usable;
7. audio remains usable;
8. touchpad and keyboard remain usable;
9. brightness path remains functional;
10. no `gpuRestart`;
11. no panic;
12. no forced shutdown;
13. no machine remaining powered indefinitely with lid closed;
14. sleep power draw consistent with real suspend rather than display-off.

Until all of these are satisfied, status remains:

```text
native suspend/resume unresolved
```

## Safety statement

Do not transport the laptop in a closed bag based on the assumption that closing the lid suspends it.

Until native lid sleep is proven, verify actual power state before transport.
