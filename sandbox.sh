#!/bin/bash
#
# Sandbox for initial experimentations
#
# packages: wmctrl xdotool

GetActiveWinGeo() {
    wingeo1=$(xdotool getwindowgeometry $window)
    echo "Active Window Geometry (xdotool) = $wingeo1"
    echo ""

    windowHex=$(echo "obase=16; 44042839" | bc | tr '[:upper:]' '[:lower:]')
    wingeo2=$(wmctrl -liG | grep $windowHex)
    echo "Active Window Geometry (wmctrl) = $wingeo2"
    echo ""
}

desktopdims=$(wmctrl -d)
echo "Desktop dimensions =" 
echo "$desktopdims"
echo ""

window=$(xdotool getactivewindow)
echo "Active Window = $window"
echo ""

GetActiveWinGeo

echo "-> moving window to upper right"
xdotool windowmove $window 0 0
echo ""

GetActiveWinGeo
