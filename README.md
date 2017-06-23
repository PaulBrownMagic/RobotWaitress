# Robot Waitress: Navigation
This repository contains the scripts and files necessary for running Topological Navigation on LUCIE. The main script is used as ```./lucie_start_navigation.sh name_of_topological_map```. It assumes the maps have been created with TopologicalMapMaker as it uses the ```name_of_topological_map``` variable following the naming conventions for the files created there. The script would need to be manually adapted for other maps. The tmux script can be launched and each session run. The final session gives the option of giving LUCIE a navigation objective.

## Tmux useful keys
- ```ctrl & B then 0``` change to session 0. Replace 0 with any number up to 7 to change between the sessions.
- ```ctrl & B then →``` change between panes using the arrow keys.
- ```ctrl & B then D``` exit the tmux session. Note the session is still running and needs to be killed. Run ./kill_tmux.sh to really exit.

## Sessions in Tmux
There are 6 sessions running in tmux, which are designed for the different tasks required to run navigation with a topological map.

### Session 0
This runs roscore and htop to monitor processes. Both of these scripts run automatically so if there are no errors then change to session 1.

### Session 1
The main pane runs mongodb, which will create your database at the path given and allow the WayPoints to be inserted once they have been created. Run it and leave it until you've finished.

The second pane contains the command to run robomongo, which allows you to view the database in more detail. It is not required.

### Session 2
This is robot_bringup and provides the lasers and joystick.

### Session 3
This is to enable the cameras. The locations of the cameras are set by the variables ```$HEADCAM_HOSTNAME``` and ```$CHESTCAM_HOSTNAME``` at the start of the script. There is also the option of not running the cameras, an alternative to using the headcam with the strands_cameras.launch file is included in the second pane.

The second pane gives the option of running a people tracking program, which can show where people are in Rviz. This should only be run if ```$HEADCAM = False``` to avoid conflict.

### Session 4
The first pane runs strands UI, which integrates with monitored navigation to ask for help when LUCIE is stuck.

The second pane is a convenient script to launch firefox at the correct url for the UI.

### Session 5
This launches the topological navigation, once this is run LUCIE can be sent navigation objectives. The camera used is set in ```$NAV_CAM``` at the top of the file.


### Session 6
The first pane brings up a customized Rviz that loads some useful topics. This makes it easy to set an estimated position (2D pose) for LUCIE, send her navigation goals that are not part of the topological map as well as edit WayPoints and the Edges between them.

The second pane contains the command to issue LUCIE with a navigation goal to reach WayPoint 1.

## Exiting
To exit, the running processes can be killed with ```ctrl & C```, tmux can be killed using the provided script: kill_tmux.sh.
