#!/bin/bash
#
# Sandbox for initial experimentations
#
# packages: wmctrl xdotool xorg-xwininfo
#
# My panel extends both monitors at 26 px.
# My window decoractions = 24px (typically)
#   Still need to check apps like Chrome and gtk3

echo 
echo -----
echo "Work Area Calculations"
echo -----
echo

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

    echo "X_START = " $x_start
    echo "X_SIZE  = " $x_size 
    echo "Y_START = " $y_start "    <== My tint2 panel size"  
    echo "Y_SIZE  = " $y_size
    echo ""

echo 
echo -----
echo "Quadrant Calculations"
echo -----
echo

echo "-------------------------"
echo "|       |       |       |"
echo "|  -1,1 |  0,1  |  1,1  |"
echo "|_______|_______|_______|"
echo "|       |       |       |"
echo "|  -1,0 |  0,0  |  1,0  |"
echo "|_______|_______|_______|"
echo "|       |       |       |"
echo "| -1,-1 |  0,-1 |  1,-1 |"
echo "|_______|_______|_______|"
echo


# screen, x_quad, y_quad
get_quadrant_info() {
    screen=$1
    x_quad=$2
    y_quad=$3
    echo "Screen: " $screen 
    echo "X_Quad: " $x_quad
    echo "Y_Quad: " $y_quad

    let new_x_quad=$x_quad+1
    echo "New X_Quad: " $new_x_quad

    # Quadrant Values = x_start, y_start, width, height
    if [ x_quad == -1 ]; then
        x_start=0
    elif [ x_quad == 1 ]; then
        x_start='screen width / 2'
    fi

    echo $x_start
}

get_quadrant_info 0 -1 1


echo 
echo -----
echo "Window Calculations"
echo -----
echo

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

windowFrame=$(xprop -id "$window" _NET_FRAME_EXTENTS)
echo $windowFrame "  <== 24 = Openbox Titlebar"

echo
echo -----
echo "Window Movements"
echo -----
echo

# Pre-Move geometry
#GetActiveWinGeo

# Move
#echo "-> moving window to upper right"
#xdotool windowmove $window 0 0
#echo ""

# Post-Move geometry
#GetActiveWinGeo

