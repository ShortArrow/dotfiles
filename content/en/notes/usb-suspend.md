---
title: "A wireless mouse that kept disconnecting, and the diagnosis that went wrong"
description: "The Windows event log ruled out the cable, the port and the socket, which left the radio link or the USB power policy. A Windows update on the same day made the power policy look like the answer, and turning it off seemed to work. The real causes were a weak battery and a board between the mouse and its receiver."
summary: "An elimination step that was right, a correlation that was wrong, and why two faults at once look like neither of them."
---

In late June 2026 a 2.4 GHz wireless mouse started to disconnect for a
moment whenever it was being moved.

## The elimination step that held

Windows records the arrival and removal of devices under Kernel-PnP, as
events 410 and 411. A device that loses contact at its connector produces
them. There was not a single such event in the log for the whole period.

That rules out the cable, the USB port and the socket: if any of those had
been failing, the events would be there. What remains is the radio link
between the mouse and its receiver, or the USB power policy, which can
power the receiver down.

This step was correct, and it is the only part of the original diagnosis
that survived.

## The correlation that did not hold

Nothing physical had changed in two years: same receiver, same port, same
desk. So the next question was what software had changed and when, and
there was a candidate immediately.

On 2026-06-22 at 12:37, update KB5094126 was installed, and in the same
minute the USB and HID driver stack was replaced: `usbxhci`, `usbhub3`,
`usb.inf`, `input.inf` and `hidusb`. The disconnects began that day.

USB audio had also been misbehaving during the same period, and that seemed
to settle it. One cause explaining two symptoms is usually a better theory
than two unrelated faults, and a driver stack that both devices depend on
is exactly that kind of cause.

So I turned off USB selective suspend, and the per-device setting that
allows Windows to power the receiver down. The disconnects stopped, and I
took that as confirmation.

## The actual cause

The mouse's battery was failing, and a wooden board had been placed on the
desk between the mouse and its receiver. Either one on its own weakens a
2.4 GHz link; together they produce a link that drops whenever the hand
moves.

Both have been fixed and the mouse works normally. It has also been working
normally while the USB power settings sat at their Windows defaults, because
the July cumulative update replaced the USB stack again and reset them:

| measured 2026-08-02 | |
|---|---|
| USB selective suspend, AC and DC | `1`, the Windows default |
| USB devices allowed to power off | 13 of 13 |

A month of normal behaviour with the setting back at its default is the
check the original fix never received.

## Why the wrong explanation was convincing

Two faults at the same time show neither one's pattern. A weak battery
alone produces disconnects that follow the battery level. An obstruction
alone produces disconnects that follow the mouse's position. Both together
produce disconnects that follow nothing recognisable, which looks like a
fault somewhere below the physical layer.

A monthly update is always available as a cause. Some part of Windows is
replaced almost every month, so a symptom that starts in late June will
always find an update in late June. A match to the minute is no more
evidence than a match to the day.

An intermittent fault appears to confirm whatever was done last. The
disconnects came in stretches with quiet periods between them. Any change
followed by a quiet period looks like a fix, and I had not decided in
advance how long a quiet period would have to be to count.

Two symptoms were assumed to share a cause. The audio trouble is what made
a common driver stack attractive. Whether it had anything to do with the
mouse was never checked, and it still has not been.
