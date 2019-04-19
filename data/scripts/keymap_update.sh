#!/bin/sh

PATH="/usr/bin:/bin:/usr/sbin:/sbin"

KEYMAP_CACHE_FILE_PATH="/var/lib/xkb/"
BUILTIN_KEYMAP_CACHE_FILE_PATH="/usr/share/X11/xkb/"
KEYMAP_CACHE_VERSION_FILE="${KEYMAP_CACHE_FILE_PATH}cache_version.txt"
TZ_BUILD_CONF_FILE="/etc/tizen-build.conf"

function get_current_keymap_time() {
	_current_date="$(date -r ${KEYMAP_CACHE_FILE_PATH}dummy.xkb "+%Y%m%d")_1"
	eval "$1='${_current_date}'"
}

function get_current_build_time() {
	_current_date="$(date -r ${BUILTIN_KEYMAP_CACHE_FILE_PATH}tizen_key_layout.txt "+%Y%m%d")_1"
	eval "$1='${_current_date}'"
}

function get_keymap_version() {
	if [ -e ${KEYMAP_CACHE_VERSION_FILE} ]
	then
		_tizen_keymap_version=`cat ${KEYMAP_CACHE_VERSION_FILE}`
	else
		get_current_keymap_time _tizen_keymap_version
	fi

	eval "$1='${_tizen_keymap_version}'"
}

function get_build_version() {
	if [ -e ${TZ_BUILD_CONF_FILE} ]; then
		_tizen_build_version=`grep "TZ_BUILD_DATE" ${TZ_BUILD_CONF_FILE} | awk -F '[=]' '{ print $2 }'`
	else
		get_current_build_time _tizen_build_version
	fi
	eval "$1='${_tizen_build_version}'"
}

function create_build_version_file() {
	if [ -e ${KEYMAP_CACHE_VERSION_FILE} ]
	then
		rm -rf ${KEYMAP_CACHE_VERSION_FILE}
	fi

	get_build_version version

	echo "${version}" > ${KEYMAP_CACHE_VERSION_FILE}
}

function copy_builtin_cache_file() {
	if [ -e ${BUILTIN_KEYMAP_CACHE_FILE_PATH}*.xkb ]
	then
		echo "Copy builtin keymap cache file"
		cp ${BUILTIN_KEYMAP_CACHE_FILE_PATH}*.xkb ${KEYMAP_CACHE_FILE_PATH}
	fi
}

function remove_cache_files() {
	_path="$1"
	for _cache_file in ${_path}*.xkb; do
		if [ ${_cache_file} == "${KEYMAP_CACHE_FILE_PATH}dummy.xkb" ]; then
			continue
		fi
		rm "${_cache_file}"
	done
}

function find_cache_files() {
	_path="$1"
	_value=0
	for _cache_file in ${_path}*.xkb; do
		if [ ${_cache_file} == "${KEYMAP_CACHE_FILE_PATH}dummy.xkb" ]; then
			continue
		else
			_value=1
			break
		fi
	done
	return "${_value}"
}

# Create a keymap cache file directory
mkdir -p ${KEYMAP_CACHE_FILE_PATH}/compiled/

if [ -e ${KEYMAP_CACHE_FILE_PATH}/compiled/ ]
then
	:
else
# There are some problems in system if mkdir is failed.
# sometimes some partition is not mounted, in that case do not make cache
	echo "keymap_update is failed. cannot create ${KEYMAP_CACHE_FILE_PATH}/"
	echo "This system couldn't use keymap cache, so booting time will be increase"
# Altought cannot using keymap cache, enlightenment will be processed successfully,
# so return true in this script
	exit 0
fi

get_build_version _current_build_version
get_keymap_version _current_keymap_version

echo "build: ${_current_build_version}"
echo "keymap: ${_current_keymap_version}"

if [ -e ${KEYMAP_CACHE_VERSION_FILE} ]
then
	echo "We have a keymap cache version file"
	if [ ${_current_build_version} != ${_current_keymap_version} ]
	then
		#Platform Update
		echo "Current keymap is built in the past. Remove a keymap cache file."
		remove_cache_files ${KEYMAP_CACHE_FILE_PATH}

		create_build_version_file
		copy_builtin_cache_file
	else
		#find_cache_files ${KEYMAP_CACHE_FILE_PATH}
		#cache_exist=$?
		#if [ "${cache_exist}" == "0" ]
		#then
			# User remove cache file
		#else
			# Normal booting
		#fi
		:
	fi
else
	#First Booting
	echo "We do not have a keymap cache version file"
	create_build_version_file
	remove_cache_files ${KEYMAP_CACHE_FILE_PATH}
	copy_builtin_cache_file
fi
