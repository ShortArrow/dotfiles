---
title: "A mouse that disconnects, with nothing in the log"
description: "A 2.4 GHz mouse started dropping out mid-movement. Windows had recorded no device arrival and no device removal, which is what ruled out everything physical and pointed at USB selective suspend."
summary: "Using the absence of an event as evidence, and a fix that a later update quietly undid."
---

In late June 2026 a 2.4 GHz wireless mouse began dropping out while it was
being moved. USB audio started misbehaving in the same period.

## The empty log was the finding

Windows records device arrival and removal under Kernel-PnP, event IDs 410
and 411. A device that loses contact physically produces them. Across the
whole period there were none — not a handful, not one.

That single absence removes the cable, the port, the receiver and the
socket, because every one of those failing would have been written down.
What it leaves is the radio link, or the power policy sitting above it.

## Two years of nothing, then a date

The desk had not changed in two years: same receiver, same port, same
physical layout. So the question was which piece of software had changed,
and when.

`2026-06-22 12:37` — KB5094126 installed, and in the same minute the USB
and HID driver stack was replaced: `usbxhci`, `usbhub3`, `usb.inf`,
`input.inf`, `hidusb`. The symptom began that day.

A matching timestamp is not a cause. It was enough to say where to look,
and what it pointed at was the pair of settings the new stack now acted
on: USB selective suspend in the power plan, and the per-device flag that
lets Windows turn a device off to save power.

Turning both off stopped the disconnects.

## What the scripts do

`windows/usb/fix-usb.ps1` writes the AC and DC index of the USB selective
suspend setting to 0, then walks `MSPower_DeviceEnable` in `root/wmi` and
clears the flag on every instance whose name contains USB.

`restore-usb.ps1` puts the Windows defaults back. Each script only touches
devices in the state it is changing away from, so either can be run twice
with no effect the second time.

## It did not stay fixed

Measured on the same machine on 2026-08-02:

| | |
|---|---|
| USB selective suspend, AC and DC | `1` — the Windows default |
| USB devices allowed to power off | 13 of 13 |

Everything `fix-usb.ps1` changed is back where it started. The driver
files are dated 2026-07-15 — `hidusb.sys` 10.0.26100.8875, `usbxhci.sys`
10.0.26100.8521 — which is the July cumulative update replacing the stack
a second time.

The per-device flags are what makes this readable. Selective suspend
belongs to a power plan, so switching plans would explain that row and
leave the thirteen devices alone. All thirteen are back to default, which
points at the device stack being reinstalled rather than at anything to do
with power plans.

So the fix has a half-life measured in cumulative updates, and until now
nothing noticed when it expired. `windows/doctor.ps1` reports the two
values, which at least makes the expiry visible on the next run.
