#!/bin/bash

# This program is for use with maps generated by TopologicalMapMaker and
# assumes the same naming conventions used there.
# "Usage: ./lucie_start_navigation.sh name_of_topological_map"

# User defined variables
$HOSTNAME=localhost
$HEADCAM=True
$HEADCAM_HOSTNAME=luciel
$CHESTCAM=True
$CHESTCAM_HOSTNAME=lucie
$NAV_CAM=head_xtion

if [ -z $1 ]; then
echo "This program is for use with TopologicalMapMaker Maps"
echo "Usage: ./lucie_start_navigation.sh name_of_topological_map";
exit;
fi

# Generated Variables
SESSION=$USER
WAITRESS_HOME=$HOME/Waitress
ROBOT_FILES=$WAITRESS_HOME/robot_files
NAV_MAP=$ROBOT_FILES/$1.yaml
DATABASE=$WAITRESS_HOME/mongodb_store/$1/
WAYPOINTS=$1

tmux -2 new-session -d -s $SESSION
# Setup a window for tailing log files
tmux new-window -t $SESSION:0 -n 'roscore'
tmux new-window -t $SESSION:1 -n 'mongo'
tmux new-window -t $SESSION:2 -n 'robot_bringup'
tmux new-window -t $SESSION:3 -n 'cameras'
tmux new-window -t $SESSION:4 -n 'strands_ui'
tmux new-window -t $SESSION:5 -n 'strands_navigation'
tmux new-window -t $SESSION:6 -n 'RViz'

tmux select-window -t $SESSION:0
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "roscore" C-m
tmux resize-pane -U 30
tmux select-pane -t 1
tmux send-keys "htop" C-m

tmux select-window -t $SESSION:1
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "roslaunch mongodb_store mongodb_store.launch db_path:=$DATABASE port:=62345"
tmux resize-pane -D 20
tmux select-pane -t 1
tmux send-keys "robomongo"
tmux select-pane -t 0

tmux select-window -t $SESSION:2
tmux send-keys "roslaunch strands_bringup strands_robot.launch machine:=$HOSTNAME user:=$USER with_mux:=False js:=/dev/input/js0 laser:=/dev/ttyUSB0 scitos_config:=/opt/ros/indigo/share/scitos_mira/resources/SCITOSDriver.xml"

tmux select-window -t $SESSION:3
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "roslaunch strands_bringup strands_cameras.launch machine:=$HOSTNAME user:=$USER head_camera:=$HEADCAM head_ip:=$HEADCAM_HOSTNAME head_user:=$USER chest_camera:=$CHESTCAM chest_ip:=$CHESTCAM_HOSTNAME chest_user:=$USER"
tmux resize-pane -D 10
tmux select-pane -t 1
tmux send-keys "roslaunch perception_people_launch people_tracker_robot.launch"
tmux select-pane -t 0

tmux select-window -t $SESSION:4
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "roslaunch strands_bringup strands_ui.launch"
tmux resize-pane -U 30
tmux select-pane -t 1
tmux send-keys "firefox $HOSTNAME:8090 &"
tmux select-pane -t 0

tmux select-window -t $SESSION:5
tmux send-keys "roslaunch strands_bringup strands_navigation.launch with_camera:=True camera:=$NAV_CAM map:=$NAV_MAP with_no_go_map:=False no_go_map:=$ROBOT_FILES/no_go_map.yaml with_mux:=False topological_map:=$WAYPOINTS"

tmux select-window -t $SESSION:6
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "rosrun rviz rviz -d $WAITRESS_HOME/tsc_config.rviz"
tmux resize-pane -U 30
tmux select-pane -t 1
tmux send-keys "rosrun topological_navigation nav_client.py WayPoint1"
tmux select-pane -t 0


# Set default window
tmux select-window -t $SESSION:0

# Attach to session
tmux -2 attach-session -t $SESSION

tmux setw -g mode-mouse on
