#!/bin/bash
#
# Window Snapping Utility for Openbox
#
# Makes some assumptions about multi-monitor setups:
# - screens arranged horizontally
# - screens have same resolutions
# - panels are present on every screen, in the same location, and of the same size

function usage() {
    echo "Syntax: snap.sh [l|r|u|d]"
    echo "  l  snap left"
    echo "  r  snap right"
    echo "  u  snap up"
    echo "  d  snap down"
    echo 
    echo "  ______________________________________________"
    echo "  |              |              |              |"
    echo "  |   top-left   |   full top   |   top-right  |"
    echo "  |______________|______________|______________|"
    echo "  |              |              |              |"
    echo "  |  full left   |   original   |  full right  |"
    echo "  |______________|______________|______________|"
    echo "  |              |              |              |"
    echo "  |  bottom-left | full bottom  | bottom right |"
    echo "  |______________|______________|______________|"
    echo
    echo "Thinking of each monitor as a 3x3 grid:"
    echo " - Each window, regardless of starting position,"
    echo "   will start in the 'original' unsnapped position."
    echo " - Movement in any specific direction will snap the"
    echo "   window to the appropriate grid."
    echo " - To return a window to its unsnapped position,"
    echo "   simply snap it back to the 'original' position."
    echo 
}

function get_monitor_count() {
    num_monitors=$(xrandr -q | grep -c " connected")
    echo "Num Monitors: $num_monitors"
}

function get_screen_geometry() {
    screen_dimensions=$(xprop -root _NET_WORKAREA | sed 's/,//g' | cut -d' ' -f3-)

    screen_x_start=$(echo $screen_dimensions | cut -d' ' -f1)
    screen_y_start=$(echo $screen_dimensions | cut -d' ' -f2)
    let screen_width=$(echo $screen_dimensions | cut -d' ' -f3)/num_monitors
    screen_height=$(echo $screen_dimensions | cut -d' ' -f4)
    
    echo "Screen Geometry:"
    echo "  X Start: $screen_x_start"
    echo "  Y Start: $screen_y_start"
    echo "  Width:   $screen_width"
    echo "  Height:  $screen_height"
}

function get_active_window() {
    window=$(xdotool getactivewindow)
    echo "Active Window: $window"
}

function get_window_state() {
    xprop -id $window | grep "_SNAP_STATE" >/dev/null
    if [ $? == 0 ]; then
        echo "Window is already snapped."
        window_state=$(xprop -id $window _SNAP_STATE | sed 's/,//g' | cut -d' ' -f3-)
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
        echo "Original Geometry = $orig_x, $orig_y, $orig_w, $orig_h"
        echo "Current Geometry =  $last_x, $last_y, $last_w, $last_h"
    else
        echo "Window is not yet snapped."
        orig_x=$curr_x
        orig_y=$curr_y
        orig_w=$curr_w
        orig_h=$curr_h
        let last_x_quad=0
        let last_y_quad=0
        echo "Original Geometry: $orig_x, $orig_y, $orig_w, $orig_h"
    fi
}

function get_window_monitor() {
    monitor=1
    
    if [ "$orig_x" -gt "$screen_width" ]; then
        monitor=2
    fi
}

function get_window_geometry() {
    eval $(xwininfo -id $window |
            sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/x=\1/p" \
                   -e "s/^ \+Absolute upper-left Y: \+\([0-9]\+\).*/y=\1/p" \
                   -e "s/^ \+Width: \+\([0-9]\+\).*/w=\1/p" \
                   -e "s/^ \+Height: \+\([0-9]\+\).*/h=\1/p" \
                   -e "s/^ \+Relative upper-left X: \+\([0-9]\+\).*/b=\1/p" \
                   -e "s/^ \+Relative upper-left Y: \+\([0-9]\+\).*/t=\1/p" )
    
    echo "Current Window Geometry:"
    echo "  Abs X:   $x"
    echo "  Abs Y:   $y"
    echo "  Rel X:   $b"
    echo "  Rel Y:   $t"
    echo "  Width:   $w"
    echo "  Height:  $h"

    let curr_x=$x-$b
    let curr_y=$y-$t
    let curr_w=$w+$b
    let curr_h=$h+$t+$b

    echo "Calcuated Window Geometry:"
    echo "  Curr X:  $curr_x"
    echo "  Curr Y:  $curr_y"
    echo "  Curr W:  $curr_w"
    echo "  Curr H:  $curr_h"
}

function get_window_frame() {
    window_frame=$(xprop -id $window _NET_FRAME_EXTENTS | sed 's/,//g' | cut -d' ' -f3-)
    left_frame=$(echo $window_frame | cut -d' ' -f1)
    right_frame=$(echo $window_frame | cut -d' ' -f2)
    top_frame=$(echo $window_frame | cut -d' ' -f3)
    bottom_frame=$(echo $window_frame | cut -d' ' -f4)

    echo "Window Frame Geometry:"
    echo "  Left:   $left_frame"
    echo "  Right:  $right_frame"
    echo "  Top:    $top_frame"
    echo "  Bottom: $bottom_frame"
}

function reset_stored_geometry() {
    echo "Removing xprop _SNAP_STATE"
    xprop -id "$window" -remove _SNAP_STATE
}

DEBUG=false
DIRECTION=""

if [ $# -eq 0 ] || [ $# -gt 1 ]; then
   usage
   exit
fi

case $1 in
    l|r|u|d) DIRECTION="$1"
        ;;
    *)
        usage; exit
        ;;
esac
          
get_monitor_count
get_screen_geometry
get_active_window

get_window_geometry
get_window_frame
get_window_state
get_window_monitor


new_x_quad=$last_x_quad
new_y_quad=$last_y_quad

if [ $DIRECTION == 'l' ]; then
    let new_x_quad=$last_x_quad-1
elif [ $DIRECTION == 'r' ]; then
    let new_x_quad=$last_x_quad+1
elif [ $DIRECTION == 'u' ]; then
    let new_y_quad=$last_y_quad+1
elif [ $DIRECTION == 'd' ]; then
    let new_y_quad=$last_y_quad-1
fi

if [ $new_x_quad -gt 1 ] || [ $new_x_quad -lt -1 ]; then
    new_x_quad=$last_x_quad
    echo "x out of range"
fi

if [ $new_y_quad -gt 1 ] || [ $new_y_quad -lt -1 ]; then
    new_y_quad=$last_y_quad
    echo "y out of range"
fi

if [ $new_x_quad -eq 0 ] && [ $new_y_quad -eq 0 ]; then
    echo "Returning to original position"
    new_x=$orig_x
    new_y=$orig_y
    let new_w=$orig_w-$b
    let new_h=$orig_h-$top_frame-$bottom_frame
    
    reset_stored_geometry
else
    case $new_x_quad in
        -1)
            let new_x=$screen_x_start
            let new_w=$screen_width/2-$left_frame-$right_frame
            ;;
        0)
            let new_x=$screen_x_start
            let new_w=$screen_width-$left_frame-$right_frame
            ;;
        1)
            let new_x=$screen_width/2+1
            let new_w=$screen_width/2-$left_frame-$right_frame
            ;;
    esac
    
    case $new_y_quad in 
        -1)
            let new_y=$screen_height/2+$top_frame+$bottom_frame+1
            let new_h=$screen_height/2-$top_frame-$bottom_frame
            ;;
        0)
            let new_y=$screen_y_start
            let new_h=$screen_height-$top_frame-$bottom_frame-1
            ;;
        1)
            let new_y=$screen_y_start
            let new_h=$screen_height/2-$top_frame-$bottom_frame
            ;;
    esac
    
    get_window_monitor

    if [ "$monitor" == 2 ]; then
        let new_x=$new_x+$screen_width
    fi

    xprop -id $window -f _SNAP_STATE 32i -set _SNAP_STATE "$orig_x, $orig_y, $orig_w, $orig_h, $new_x_quad, $new_y_quad, $new_x, $new_y, $new_w, $new_h"
fi

echo "Snapping to:"
echo "  Quadrant: $new_x_quad, $new_y_quad"
echo "  New X:    $new_x"
echo "  New Y:    $new_y"
echo "  New W:    $new_w"
echo "  New H:    $new_h"
    
xdotool windowmove $window $new_x $new_y
xdotool windowsize $window $new_w $new_h

get_window_geometry