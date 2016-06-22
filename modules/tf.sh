#!/bin/bash
trap "echo 'Server stopped.'" SIGINT
while :; do
	tf2/srcds_run -game tf -autoupdate +sv_pure -1 +randommap +host_thread_mode 2 +threadpool_affinity 0 +maxplayers 24 -replay -steam_dir /home/teamfortress/ -steamcmd_script /home/teamfortress/tf2_ds.txt +sv_shutdown_timeout_minutes 360
	read -p "Press enter to resume the server, enter quit then press enter to terminate screen..."$'\n' input
	if [[ "$input" = quit ]]; then
		break
	fi
done
