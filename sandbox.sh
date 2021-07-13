#!/bin/bash
#
# Sandbox for initial experimentations
#
# packages: wmctrl xdotool xorg-xwininfo
#
# My panel extends both monitors at 26 px.
# My window decoractions = 24px (typically)
#   Still need to check apps like Chrome and gtk3

# -----
# Work Area Calculations
# -----

x_start=''
y_start=''
x_size=''
y_size=''

function get_screen_area() {
    # `xprop -root _NET_WORKAREA` returns comma separated values for
    # x_start, y_start, x_size, y_size of entire work area (multiple screens)
    # Example:
    #   _NET_WORKAREA(CARDINAL) = 0, 20, 3840, 1060, ...
    # TODO not sure why the 4 values repeat a number of times
    workarea_data=$(xprop -root _NET_WORKAREA | awk -F '[ ,]' '{ print $3, $5, $7, $9 }')

    x_start=$(echo $workarea_data | cut -d' ' -f1)
    y_start=$(echo $workarea_data | cut -d' ' -f2)
    x_size=$(echo $workarea_data | cut -d' ' -f3)
    y_size=$(echo $workarea_data | cut -d' ' -f4)

    echo "X_START = " $x_start
    echo "X_SIZE  = " $x_size 
    echo "Y_START = " $y_start "    <== My tint2 panel size"  
    echo "Y_SIZE  = " $y_size
    echo ""
}

desktopdims=$(wmctrl -d)
echo "Desktop dimensions =" 
echo "$desktopdims"
echo ""

get_screen_area

# -----
# Window Calculations 
# -----

GetActiveWinGeo() {
    wingeo1=$(xdotool getwindowgeometry $window)
    echo "Active Window Geometry (xdotool) = $wingeo1"
    echo ""

    windowHex=$(echo "obase=16; $window" | bc | tr '[:upper:]' '[:lower:]')
    echo $windowHex
    wingeo2=$(wmctrl -liG | grep $windowHex)
    echo "Active Window Geometry (wmctrl) = $wingeo2"
    echo ""

    wingeo3=$(xwininfo -id 0x$windowHex)
    echo "Active Window Geometry (xwininfo) = $wingeo3"
    echo ""
}


window=$(xdotool getactivewindow)
echo "Active Window = $window"
echo ""

# Pre-Move geometry
#GetActiveWinGeo

# Move
#echo "-> moving window to upper right"
#xdotool windowmove $window 0 0
#echo ""

# Post-Move geometry
#GetActiveWinGeo
