---
title: "A mouse that disconnects, and the wrong branch"
description: "No device-arrival event in the log ruled out the cable, the port and the socket. What remained was the radio link or the power policy above it, and a Windows update landing on the same day made the second one look obvious. It was the first one."
summary: "An elimination that held, a correlation that did not, and why two faults at once look like neither."
---

In late June 2026 a 2.4 GHz wireless mouse began dropping out while it was
being moved.

## The empty log held up

Windows records device arrival and removal under Kernel-PnP, event IDs 410
and 411. A device that loses contact through its connector produces them.
Across the whole period there were none — not a handful, not one.

That absence removes the cable, the port and the socket, because any of
those failing would have been written down. What it leaves is the radio
link, or the power policy sitting above it.

This step was right, and it is the only part of the diagnosis that
survived.

## The correlation that did not

Nothing physical had changed in two years: same receiver, same port, same
desk. So the question became which piece of software had changed and when,
and there was an answer waiting.

`2026-06-22 12:37` — KB5094126 installed, and in the same minute the USB
and HID driver stack was replaced: `usbxhci`, `usbhub3`, `usb.inf`,
`input.inf`, `hidusb`. The symptom began that day.

USB audio had been misbehaving in the same period, which seemed to settle
it. One cause under two symptoms is a better theory than two unrelated
faults, and a driver stack that both devices sit on is exactly such a
cause.

So USB selective suspend went off, along with the per-device flag that
lets Windows power a device down. The disconnects stopped, and that was
taken as confirmation.

## It was the other branch

The mouse had a failing battery, and a wooden board had been placed where
it stood between the receiver and the mouse. Either alone is a marginal
2.4 GHz link. Together they are a link that drops when the hand moves.

Both are fixed, the mouse is fine, and it has been fine while the power
settings sat at their Windows defaults — where they have been since the
July cumulative update replaced the USB stack a second time and put them
back:

| measured 2026-08-02 | |
|---|---|
| USB selective suspend, AC and DC | `1`, the Windows default |
| USB devices allowed to power off | 13 of 13 |

A month of normal behaviour with the setting reverted is the measurement
that the original fix never got.

## Why the wrong branch was convincing

**Two faults at once show neither signature.** A weak battery gives
dropouts that track the battery. An obstruction gives dropouts that track
position. Both at once gives dropouts that track nothing legible, which
reads as a fault below the physical layer.

**A monthly update is always available as a cause.** Something replaces
part of Windows most months. A symptom starting in late June will find an
update in late June, and the minute-level match adds no evidence beyond
the day-level one.

**An intermittent fault confirms whatever you did last.** The dropouts
came in stretches. Any change followed by a good stretch reads as a fix,
and there was no plan for how long a good stretch had to be.

**Two symptoms were assumed to share a cause.** The audio trouble is what
made a common driver stack attractive. Whether it had anything to do with
the mouse was never established, and it still has not been.
