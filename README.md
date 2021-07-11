# snap

**WIP** Window Snapping Utility for Openbox

## Idea

I long for easily resizing and snapping windows with key bindings in Openbox. The available Openbox Window Actions for moving and resizing windows just does not work well. I have yet to find a well-working alternative solution with existing packages in ArchLinux or the AUR.

So I write my own. Language TBD.

## Mandatory Features

- Key Bindings to move/snap windows to any side of each screen and any corner of each screen.
- Memory of original location for unsnapping.
- Support for dual/multi-monitor setups.
- Work properly with varying taskbar and window decoration sizes.
- Smooth and Fast

## Nice to Haves

- Ability to resize/snap to top/bottom edge in middle of screen, essentially making a 3x2 grid rather than a 2x2 grid.

```
    ___________________                   ___________________
    |     |     |     |                   |        |        |
    |_____|_____|_____|    rather than    |________|________|       
    |     |     |     |                   |        |        |
    |_____|_____|_____|                   |________|________|       

```