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

orig_x_quad=0
orig_y_quad=0

case $WINDOW_STATE in
    "N/A" )
        echo "Window has not yet been snapped. Starting at Quadrant [0,0]"


        # get orig window geometry
        entire=false
        orig_x=0 # x pos
        orig_y=0 # y pos
        orig_w=0 # width
        orig_h=0 # height
        orig_b=0 # border
        orig_t=0 # title

        eval $(xwininfo -id $(xdotool getactivewindow) |
                sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/x=\1/p" \
                       -e "s/^ \+Absolute upper-left Y: \+\([0-9]\+\).*/y=\1/p" \
                       -e "s/^ \+Width: \+\([0-9]\+\).*/w=\1/p" \
                       -e "s/^ \+Height: \+\([0-9]\+\).*/h=\1/p" \
                       -e "s/^ \+Relative upper-left X: \+\([0-9]\+\).*/b=\1/p" \
                       -e "s/^ \+Relative upper-left Y: \+\([0-9]\+\).*/t=\1/p" )
        if [ "$entire" == true ]; then
            let orig_x=$x-$b
            let orig_y=$y-$t
            let orig_w=$w+2*$b
            let orig_h=$h+$t+$b
        else
            let orig_x=$x
            let orig_y=$y
            let orig_w=$w
            let orig_h=$h
        fi

        screen=1
        echo "ORIG X: $orig_x"
        if [ $orig_x -gt  1920 ]; then
            screen=2
        fi
        echo "SCREEN: $screen"


        ;;
    "test" )
        echo "Window has been found!"
        ;;
esac


let new_x_quad=0
let new_y_quad=0

cmd=$1
if [ $cmd == 'l' ]; then
    let new_x_quad=$orig_x_quad-1
    # let new_x=$screen_x_start
    # let new_y=$screen_y_start
elif [ $cmd == 'r' ]; then
    let new_x_quad=$orig_x_quad+1
    # let new_x=$screen_x_total/4
    # let new_y=$screen_y_start
elif [ $cmd == 'u' ]; then
    let new_y_quad=$orig_y_quad+1
elif [ $cmd == 'd' ]; then
    let new_y_quad=$orig_y_quad-1
fi

if [ $screen == 2 ]; then
    let new_x=new_x+1920
fi

echo "$orig_x_quad,$orig_y_quad --> $new_x_quad,$new_y_quad"

# xdotool windowmove $WINDOW $new_x $new_y
# xdotool windowsize $WINDOW 1920 1031

