######!/bin/bash

PATH="/usr/bin:/bin:/usr/sbin:/sbin"

function read_line_from_file()
{
	while IFS='' read -r line || [[ -n "$line" ]]; do
		dlogsend -p Info -t E20_MONITOR "$line"
		#echo "Text read from file: $line"
	done < "$1"
}

function get_enlightenment_status()
{
	estat=`ps -h -O stat "$1" | awk {'print $2'}`
	estat=${estat:0:1}
	echo "${estat}"
}

function display_server_check()
{
	epid=`pgrep enl`

	if [ "${epid}" = "" ]; then
	        dlogsend -p Error -t E20_MONITOR "## Enlightenment is not running ! ##"
		echo "0"
		return
	fi

	estat=$(get_enlightenment_status ${epid})

	if [ "$estat" = "S" ]; then
		wchan=`cat /proc/${epid}/wchan`
	        dlogsend -p Info -t E20_MONITOR "## Enlightenment (PID=$epid, STAT=$estat, WCHAN=$wchan) is running ! ##"
		echo "1"
		return
	fi

	#make the following files empty
	#: > /tmp/${epid}_status
	#: > /tmp/${epid}_wchan
	#: > /tmp/${epid}_stack

	dlogsend -p Info -t E20_MONITOR "## Enlightenment (PID=$epid, STAT=$estat, WCHAN=$wchan) locked up ##"

	#top -H -bn1 -p ${epid} > /tmp/${epid}_top
	ps -h -O stat ${epid} > /tmp/${epid}_status
	cat /proc/${epid}/wchan > /tmp/${epid}_wchan
	echo "" >> /tmp/${epid}_wchan
	cat /proc/${epid}/stack > /tmp/${epid}_stack

	#dlogsend -p Info -t E20_MONITOR "## Enlightenment : Top info ##"
	#read_line_from_file "/tmp/${epid}_top"
	dlogsend -p Info -t E20_MONITOR "## Enlightenment : Process Status ##"
	read_line_from_file "/tmp/${epid}_status"
	dlogsend -p Info -t E20_MONITOR "## Enlightenment : WCHAN ##"
	read_line_from_file "/tmp/${epid}_wchan"
	dlogsend -p Info -t E20_MONITOR "## Enlightenment : STACK info ##"
	read_line_from_file "/tmp/${epid}_stack"

	echo "1"
}

epid=`pgrep enl`

if [ "${epid}" = "" ]; then
        dlogsend -p Error -t E20_MONITOR "## Enlightenment is not ready ! ##"
	return
fi

INTERVAL="3"

if [ "$1" != "" ]; then
	INTERVAL="$1"
fi

while [ 1 ]; do
	sleep ${INTERVAL}

	checkup=$(display_server_check)

	#if [ "$checkup" = "0" ]; then
	#	exit 1
	#fi
done

