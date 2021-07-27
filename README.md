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
        <command>snap l</command>
    </action>
</keybind>
<keybind key="W-Right">
    <action name="Execute">
        <command>snap r</command>
    </action>
</keybind>
<keybind key="W-Up">
    <action name="Execute">
        <command>snap u</command>
    </action>
</keybind>
<keybind key="W-Down">
    <action name="Execute">                                                                   
        <command>snap d</command>
    </action>
</keybind>
```

## How it works

Think of each monitor as a 3x3 grid...

    ______________________________________________
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
- Moving a window using `snap <direction>` will snap the window to the appropriate grid position, with each of the 4 _full_ grid positions taking up the entire half of the screen.
- After being snapped to a _full_ position, a window can be snapped further to a corner position.
- To return a window to its original position, simply snap it back to the _original_ (0,0) grid location.

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
- Snap up twice to get full screen.
