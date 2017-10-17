#!/bin/sh

source /usr/share/upgrade/rw-update-macro.inc
get_version_info

if [ $OLD_VER = "3.0" ]; then
rm -rf /var/lib/xkb

mkdir -p /var/lib/xkb

fi

