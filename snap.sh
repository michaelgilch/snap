#!/bin/bash
#
# Window Snapping Utility for Openbox

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

dev_test

get_window_state
echo "State: $WINDOW_STATE"

case $WINDOW_STATE in
    "N/A" )
        echo "Window has not yet been snapped. Starting at [0,0]"
        ;;
    "test" )
        echo "Window has been found!"
        ;;
esac