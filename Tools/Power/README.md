# Historical lid-continuity workaround

## Status

This directory preserves a workaround that was part of the development history. It is not native sleep, is not a solution to the current wake failure and is not installed by the v17 default installer.

## What `Enable-Continuity.command` does

The script deliberately configures macOS to avoid system suspend:

```text
disablesleep = 1
sleep = 0
standby = 0
autopoweroff = 0
hibernatemode = 0
powernap = 0
tcpkeepalive = 0
proximitywake = 0
ttyskeepawake = 0
womp = 0
```

It also:

- cancels scheduled `pmset` repeats;
- removes `/var/vm/sleepimage` when possible;
- installs a root lid-power policy daemon;
- installs a user lid-continuity agent;
- requires password immediately after screensaver/lock;
- locks the session and turns the display off when lid closure is detected.

The practical goal was continuity after closing/reopening the lid **without entering the unreliable native suspend path**.

## Safety consequence

The computer remains powered while the lid is closed.

Do not place the machine in a bag or other thermally constrained environment assuming it is asleep.

## Why this is not native sleep

A native sleep implementation must suspend the platform and later restore CPU, GPU, display, USB, network and other device state.

This workaround intentionally prevents that transition. It therefore cannot be used as evidence that sleep/wake is fixed.

## Default v17 behavior

`Tools/Install.command` installs:

```text
trackpad preferences
v17 brightness overlay
```

and explicitly reports:

```text
Power and sleep settings: unchanged
```

It does not call `Enable-Continuity.command`.

## Disabling historical continuity

`Disable-Continuity.command` removes the installed user/root agents and writes a generic macOS sleep configuration:

```text
disablesleep = 0
sleep = 10
standby = 1
autopoweroff = 1
hibernatemode = 3
powernap = 0
tcpkeepalive = 0
proximitywake = 0
ttyskeepawake = 1
```

Important: these are hard-coded restoration values. They should not be described as an exact restoration of whatever custom `pmset` state existed before continuity mode. The enable script stores `pmset-before-continuity.txt`, but the disable script does not automatically replay that file.

## Native sleep investigation

Use the evidence and procedure in:

```text
Docs/POWER-SLEEP.md
Docs/DIAGNOSTICS.md
```

The current status remains:

```text
sleep entry: observed
some successful wake transitions: observed
repeatable native suspend/resume: unresolved
normal lid close/open: unresolved
```
