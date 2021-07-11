#!/bin/bash
#
# Sandbox for initial experimentations
#
# packages: wmctrl xdotool

desktopdims=$(wmctrl -d)
echo "Desktop dimensions =" 
echo "$desktopdims"

window=$(xdotool getactivewindow)
echo "Active Window = $window"

echo " - moving window to upper right"
xdotool windowmove $window 0 0