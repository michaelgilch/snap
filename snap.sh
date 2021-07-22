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
    screen_dimensions=$(xprop -root _NET_WORKAREA | sed 's/,//g' | cut -d' ' -f3-)

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
function get_window_state() {
    xprop -id $window | grep "_SNAP_STATE" >/dev/null
    if [ $? == 0 ]; then
        #eval window_state=$(xprop -id $window _SNAP_STATE | awk '{print $3}')
        #window_state=$(xprop -id $window _SNAP_STATE | awk '{print $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' | sed 's/,//g')
        window_state=$(xprop -id $window _SNAP_STATE | sed 's/,//g' | cut -d' ' -f3-)
    else
        eval window_state="N/A"
    fi
    echo "Window State = $window_state"
}

function get_window_monitor() {
    screen=1
    
    if [ "$orig_x" -gt 1920 ]; then
        screen=2
    fi
    echo "SCREEN: $screen"
}

get_monitor_count
get_screen_geometry
get_active_window
#dev_test
get_window_state



orig_x_quad=0
orig_y_quad=0

# Window State stored as:
# x_quad, y_quad, orig_x, orig_y, orig_w, orig_h
case $window_state in
    "N/A" )
        echo "Window has not yet been snapped. Starting at Quadrant [0,0]"

        eval $(xwininfo -id $(xdotool getactivewindow) |
                sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/x=\1/p" \
                       -e "s/^ \+Absolute upper-left Y: \+\([0-9]\+\).*/y=\1/p" \
                       -e "s/^ \+Width: \+\([0-9]\+\).*/w=\1/p" \
                       -e "s/^ \+Height: \+\([0-9]\+\).*/h=\1/p" \
                       -e "s/^ \+Relative upper-left X: \+\([0-9]\+\).*/b=\1/p" \
                       -e "s/^ \+Relative upper-left Y: \+\([0-9]\+\).*/t=\1/p" )
            let orig_x=$x-$b
            let orig_y=$y-$t
            let orig_w=$w+2*$b
            let orig_h=$h+$t+$b

            echo "Original Geometry: $orig_x, $orig_y, $orig_w, $orig_h"

            let last_x_quad=0
            let last_y_quad=0
        ;;
    * )
        echo "Window has been found!"
        echo "$window_state"
        let orig_x=$(echo $window_state | cut -d' ' -f1)
        let orig_y=$(echo $window_state | cut -d' ' -f2)
        let orig_w=$(echo $window_state | cut -d' ' -f3)
        let orig_h=$(echo $window_state | cut -d' ' -f4)
        let last_x_quad=$(echo $window_state | cut -d' ' -f5)
        let last_y_quad=$(echo $window_state | cut -d' ' -f6)
        let last_x=$(echo $window_state | cut -d' ' -f7)
        let last_y=$(echo $window_state | cut -d' ' -f8)
        let last_w=$(echo $window_state | cut -d' ' -f9)
        let last_h=$(echo $window_state | cut -d' ' -f10)
        ;;
esac

get_window_monitor


new_x_quad=$last_x_quad
new_y_quad=$last_y_quad

cmd=$1
if [ $cmd == 'l' ]; then
    let new_x_quad=$last_x_quad-1
elif [ $cmd == 'r' ]; then
    let new_x_quad=$last_x_quad+1
elif [ $cmd == 'u' ]; then
    let new_y_quad=$last_y_quad+1
elif [ $cmd == 'd' ]; then
    let new_y_quad=$last_y_quad-1
fi

echo "$new_x_quad"
if [ $new_x_quad -gt 1 ] || [ $new_x_quad -lt -1 ]; then
    new_x_quad=$last_x_quad
    echo "x out of range"
fi

echo "$new_y_quad"
if [ $new_y_quad -gt 1 ] || [ $new_y_quad -lt -1 ]; then
    new_y_quad=$last_y_quad
    echo "y out of range"
fi

if [ $new_x_quad -eq 0 ] && [ $new_y_quad -eq 0 ]; then
    echo "Returning to original position"
    new_x=$orig_x
    new_y=$orig_y
    new_width=$orig_w
    new_height=$orig_h
    xprop -id "$window" -remove _SNAP_STATE
else
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
            let new_height=1054-24-1
            ;;
        1)
            let new_y=26
            let new_height=1054/2-22-2
            ;;
    esac
    
    get_window_monitor

    echo "Screen = $screen"
    if [ "$screen" == 2 ]; then
        let new_x=new_x+1920
    fi

    echo "$last_x_quad,$last_y_quad --> $new_x_quad,$new_y_quad"
    echo "$orig_w,$orig_h --> $new_width,$new_height"
fi
xprop -id $window -f _SNAP_STATE 32i -set _SNAP_STATE "$orig_x, $orig_y, $orig_w, $orig_h, $new_x_quad, $new_y_quad, $new_x, $new_y, $new_width, $new_height"

xdotool windowmove $window $new_x $new_y
xdotool windowsize $window $new_width $new_height

