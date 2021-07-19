#!/bin/bash
#
# Window Snapping Utility for Openbox
#
# Makes some assumptions about multi-monitor setups:
# - screens arranged horizontally
# - screens have same resolutions
# - panels are present on every screen, in the same location, and of the same size

function get_monitor_count() {
    num_monitors=$(xrandr -q | grep -c " connected")
    echo "Num Monitors = $num_monitors"
}

function get_screen_geometry() {
    screen_dimensions=$(xprop -root _NET_WORKAREA | awk -F '[ ,]' '{print $3, $5, $7, $9}')

    screen_x_start=$(echo $screen_dimensions | cut -d' ' -f1)
    screen_y_start=$(echo $screen_dimensions | cut -d' ' -f2)
    let screen_width=$(echo $screen_dimensions | cut -d' ' -f3)/num_monitors
    screen_height=$(echo $screen_dimensions | cut -d' ' -f4)
    
    echo "Screen Geometry = $screen_x_start, $screen_y_start, $screen_width, $screen_height"
}

function get_active_window() {
    window=$(xdotool getactivewindow)
    echo "Active Window = $window"
}

function dev_test() {
    xprop -id $window -f _SNAP_STATE 8s -set _SNAP_STATE "test"
}

# Stores the _SNAP_STATE xprop value in WINDOW_STATE
# If no _SNAP_STATE property is found, stores "N/A"
# Example: _SNAP_STATE(STRING) = "test"
function get_window_state() {
    xprop -id $window | grep "_SNAP_STATE" >/dev/null
    if [ $? == 0 ]; then
        eval window_state=$(xprop -id $window _SNAP_STATE | awk '{print $3}')
    else
        eval window_state="N/A"
    fi
    echo "Window State = $window_state"
}

get_monitor_count
get_screen_geometry
get_active_window
#dev_test
get_window_state


orig_x_quad=0
orig_y_quad=0

case $window_state in
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

case $new_x_quad in
    -1)
        let new_x=0
        let new_width=1920/2
        ;;
    0)
        let new_x=0
        let new_width=1920
        ;;
    1)
        let new_x=1920/2
        let new_width=1920/2
        ;;
esac

case $new_y_quad in 
    -1)
        let new_y=1054/2+22+2
        let new_height=1054/2-22
        ;;
    0)
        let new_y=26
        let new_height=1054
        ;;
    1)
        let new_y=26
        let new_height=1054/2-22-2
        ;;
esac

if [ "$screen" -eq 2 ]; then
    let new_x=new_x+1920
fi

echo "$orig_x_quad,$orig_y_quad --> $new_x_quad,$new_y_quad"
echo "$orig_w,$orig_h --> $new_width,$new_height"

# xdotool windowmove $WINDOW $new_x $new_y
# xdotool windowsize $WINDOW $new_width $new_height

