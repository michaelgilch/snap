#!/bin/bash
#
# Window Snapping Utility for Openbox

# These should be calculated dynamically later.
screen_x_start=0
screen_y_start=26
screen_x_total=3840
screen_y_total=1054

monitor1_x_start=0
monitor2_x_start=1920

# Stores the _SNAP_STATE xprop value in WINDOW_STATE
# If no _SNAP_STATE property is found, stores "N/A"
# Example: _SNAP_STATE(STRING) = "test"
function get_window_state() {
    xprop -id $WINDOW | grep "_SNAP_STATE" >/dev/null
    if [ $? == 0 ]; then
        eval WINDOW_STATE=$(xprop -id $WINDOW _SNAP_STATE | awk '{print $3}')
    else
        eval WINDOW_STATE="N/A"
    fi
}

#
# DEV TEST MANUALLY ADD _SNAP_STATE
#
function dev_test() {
    xprop -id $WINDOW -f _SNAP_STATE 8s -set _SNAP_STATE "test"
}
#
# END DEV TEST
#

WINDOW=$(xdotool getactivewindow)
echo "Window: $WINDOW"

#dev_test

get_window_state
echo "State: $WINDOW_STATE"

case $WINDOW_STATE in
    "N/A" )
        echo "Window has not yet been snapped. Starting at Quadrant [0,0]"
        ;;
    "test" )
        echo "Window has been found!"
        ;;
esac

cmd=$1
if [ $cmd == 'l' ]; then
    let new_x=$screen_x_start
    let new_y=$screen_y_start
elif [ $cmd == 'r' ]; then
    let new_x=$screen_x_total/4
    let new_y=$screen_y_start
fi

xdotool windowmove $WINDOW $new_x $new_y

