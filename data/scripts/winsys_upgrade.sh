#!/bin/sh

source /usr/share/upgrade/rw-update-macro.inc
get_version_info

if [ $OLD_VER == "2.4" ]; then
#Remove directories and files installed from the old version of platform
rm -rf /var/xkb
rm -rf /var/log/Xorg*.log*
rm -rf /opt/etc/dump.d/module.d/winsys_log_dump.sh
rm -rf /opt/home/app/.e

#Create Xkb cache directory
mkdir -p /var/lib/xkb

elif [ $OLD_VER = "3.0" ]; then
rm -rf /var/lib/xkb

mkdir -p /var/lib/xkb

fi

