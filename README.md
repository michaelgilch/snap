# snap

Window Snapping Utility for Openbox

I could not find a Window snapping utility for Openbox that I was happy with, so I wrote my own.

## Installation

- Place `snap` in your path.
- Add Keybindings to Openbox via your Openbox rc.xml.
```xml
<!-- Keybindings for snap: Example using Super+Arrow -->
<keybind key="W-Left">
    <action name="Execute">
        <command>snap -sl</command>
    </action>
</keybind>
<keybind key="W-Right">
    <action name="Execute">
        <command>snap -sr</command>
    </action>
</keybind>
<keybind key="W-Up">
    <action name="Execute">
        <command>snap -su</command>
    </action>
</keybind>
<keybind key="W-Down">
    <action name="Execute">                                                                   
        <command>snap -sd</command>
    </action>
</keybind>
<keybind key="W-C-Left">
    <action name="Execute">
        <command>snap -ml</command>
    </action>
</keybind>
<keybind key="W-C-Right">
    <action name="Execute">
        <command>snap -mr</command>
    </action>
</keybind>
```

## How it works

```
Usage: snap [-s <l|r|u|d>] [-m <l|r>]
 -s     snap direction
        supports left, right, up, and down
 -m     move direction
        supports left and rught
```

Think of each monitor as a 3x3 grid, with a special case of maximized...

                   ________________
                   |              |
                   |   maximized  |
                   |     0,2      |
    _______________|______________|_______________
    |              |              |              |
    |   top-left   |   full top   |   top-right  |
    |     -1,1     |     0,1      |     1,1      |
    |______________|______________|______________|
    |              |              |              |
    |  full left   |   original   |  full right  |
    |     -1,0     |     0,0      |     1,0      |
    |______________|______________|______________|
    |              |              |              |
    |  bottom-left | full bottom  | bottom right |
    |    -1,-1     |     0,-1     |     1,-1     |
    |______________|______________|______________|

- Each window, regardless of its starting position, is initially in its _original_, unsnapped position at (0,0).
- Moving a window using `snap -s <direction>` will snap the window to the appropriate grid position, with each of the 4 _full_ grid positions taking up the entire half of the screen.
- After being snapped to a _full_ position, a window can be snapped further to a corner position.
- To return a window to its original position, simply snap it back to the _original_ (0,0) grid location.
- Additionally, manually moving a window from its snapped position (dragging, for example) will remove its stored snapped state.
- You can move a window from one monitor to another using `snap -m <direction>`. Doing so will mvoe the original position to that monitor.

## Limitations

For multi-monitor setups, the following assumptions are made:
- Only 2 monitors are present.
- Monitors are arranged horizontally.
- Monitors all have the same resolution.
- Panels are present on every monitor, in the same location, and of the same size.

## Future Improvements

- Support more than 2 monitors.
- Support monitors of differring sizes.
- Support monitors of differring resolutions.
- Support for varying panel sizes and locations.
- Automated installer.
- Ability to resize/snap to thirds, rather than halfs.
