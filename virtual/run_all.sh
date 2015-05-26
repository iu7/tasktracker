#!/bin/sh

PATH_TO_SWITCH=/tmp/switch.ctl

VDE_SWITCH=vde_switch
pgrep $VDE_SWITCH >/dev/null
if [[ $? != 0 ]]; then
	vde_switch -s $PATH_TO_SWITCH --daemon
else
	echo $VDE_SWITCH already running
fi

SHARED_DIR=`pwd`/shared

perl run.pl --mac1=52:54:00:00:AA:02 \
	    --mac2=52:54:00:00:AA:04 \
	    --switch=$PATH_TO_SWITCH master_db.cow # 192.168.0.2

#perl run.pl --mac1=52:54:00:00:AA:06 \
	    #--mac2=52:54:00:00:AA:08 \
	    #--switch=$PATH_TO_SWITCH slave_db.cow  # 192.168.0.3

#perl run.pl --fwd=hostfwd=tcp:127.0.0.1:8080-10.0.0.4:80 \
	    #--mac1=52:54:00:00:AA:0A \
	    #--mac2=52:54:00:00:AA:0C \
	    #--switch=$PATH_TO_SWITCH graphite.cow # 192.168.0.4

perl run.pl --mem 384 --fwd=hostfwd=tcp:127.0.0.1:5002-10.0.0.5:8080 \
	    --mac1=52:54:00:00:aa:0E \
	    --mac2=52:54:00:00:aa:10 \
	    --switch=$PATH_TO_SWITCH users.cow # 192.168.0.5

#perl run.pl --fwd=hostfwd=tcp:127.0.0.1:5000-10.0.0.6:5000 \
	    #--mac1=52:54:00:00:aa:12 \
	    #--mac2=52:54:00:00:aa:14 \
	    #--switch=$PATH_TO_SWITCH session.cow # 192.168.0.6

#perl run.pl --from_to=127.0.0.1:2222-10.0.0.5:22 --mac=52:54:00:00:AA:0A --switch=$PATH_TO_SWITCH archlinux-base.cow
