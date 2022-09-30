#!/bin/bash
#
# Copyright (c) 2009    Kevin Porter / Advanced Web Construction Ltd
#                       (http://coding.tinternet.info, http://webutils.co.uk)
# Copyright (c) 2010-2014     Ruediger Meier <sweet_f_a@gmx.de>
#                             (https://github.com/rudimeier/)
#
# License: BSD-3-Clause, see LICENSE file
#
# Simple INI file parser.
#
# See README for usage.
#

unset INI_ALL
declare -A INI_ALL

function show_array()
{
	KEYS_VAR=`echo "\\\${!${1}[@]}"`
	KEYS=`eval echo "$KEYS_VAR"`
	
	for key in $KEYS
	do
		echo -n "key  : $key, "
		VALUE_VAR=`echo "\\\${${1}[$key]}"`
		eval echo "value: $VALUE_VAR"
	done
}

function to_array()
{
	KEYS_VAR=`echo "\\\${!${1}[@]}"`
	KEYS=`eval echo "$KEYS_VAR"`
	
	echo -n "("
	
	for key in $KEYS
	do
		VALUE_VAR=`echo "\\\${${1}[$key]}"`
		val=`eval "echo \"$VALUE_VAR\""`
		
		if [ "$BOOLEANS" = 1 ]
		then
			case "$val" in
				yes | true | on )
					val=1
				;;
				no | false | off )
					val=0
				;;
			esac
		fi

		echo -n "[$key]=$val "
	done
	
	echo ")"
}

function exist_section()
{
	KEYS_VAR=`echo "\\\${!${1}[@]}"`
	KEYS=`eval echo "$KEYS_VAR"`
	
	for key in $KEYS
	do
		if [ "$key" = "$2" ]
		then
			return 1
		fi
	done
}

function exist_key()
{
	exist_section "$1" "$2"
	if [ $? -eq 1 ]
	then
		ARRAY_STR=`eval echo "\\\${${1}[$2]}"`
		declare -A ARRAY
		eval ARRAY=$ARRAY_STR
		
		for key in ${!ARRAY[@]}
		do
			if [ "$key" = "$3" ]
			then
				return 1
			fi
		done
	fi
}

function get_value()
{
	exist_section "$1" "$2"
	if [ $? -eq 1 ]
	then
		ARRAY_STR=`eval echo "\\\${${1}[$2]}"`
		declare -A ARRAY
		eval ARRAY=$ARRAY_STR
		
		for key in ${!ARRAY[@]}
		do
			if [ "$key" = "$3" ]
			then
				echo "${ARRAY[$3]}"
				break
			fi
		done
	fi
}



function check_ini_file()
{
	if [ -z "$INI_FILE" ] ;then
		echo -e "Usage: read_ini [-b 0| -b 1]] FILE [SECTION]" >&2
		return 1
	fi
	
	if [ ! -r "$INI_FILE" ] ;then
		echo "read_ini: '${INI_FILE}' doesn't exist or not readable" >&2
		return 1
	fi
}

	
# Set defaults
INI_FILE=""
INI_SECTION=""
BOOLEANS=1

SECTION="_default"

function command_args()
{
	#Deal with command line args
	# Available options:
	#	--boolean		Whether to recognise special boolean values: ie for 'yes', 'true'
	#				and 'on' return 1; for 'no', 'false' and 'off' return 0. Quoted
	#				values will be left as strings
	#				Default: on
	#
	#	First non-option arg is filename, second is section name

	while [ $# -gt 0 ]
	do

		case $1 in
			--booleans | -b )
				shift
				BOOLEANS=$1
			;;

			* )
				if [ -z "$INI_FILE" ]
				then
					INI_FILE=$1
				else
					if [ -z "$INI_SECTION" ]
					then
						INI_SECTION=$1
					fi
				fi
			;;

		esac

		shift
	done
	
	# Sanitise BOOLEANS - interpret "0" as 0, anything else as 1
	if [ "$BOOLEANS" != "0" ]
	then
		BOOLEANS=1
	fi

	#END Deal with command line args
}


function read_ini()
{
	command_args $@
	
	if ! check_ini_file ;then
		cleanup_bash
		return 1
	fi

	local LINE_NUM=0
	# IFS is used in "read" and we want to switch it within the loop
	local IFS=$' \t\n'
	local IFS_OLD="${IFS}"
	
	while read -r line || [ -n "$line" ]
	do
		((LINE_NUM++))

		# Skip blank lines and comments
		if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
		then
			continue
		fi

		# Section marker?
		if [[ "${line}" =~ ^\[[a-zA-Z0-9_]{1,}\]$ ]]
		then
			if [  -n "$INI_SECTION" -a "$SECTION" == "$INI_SECTION" -o -z "$INI_SECTION" ]
			then
				sec=`to_array "INI__${SECTION}"`
				eval "INI_ALL[$SECTION]=\"\$sec\""
			fi

			# Set SECTION var to name of section (strip [ and ] from section marker)
			SECTION="${line#[}"
			SECTION="${SECTION%]}"
			
			eval "declare -A INI__$SECTION"
			continue
		fi

		# Are we getting only a specific section? And are we currently in it?
		if [ ! -z "$INI_SECTION" ]
		then
			if [ "$SECTION" != "$INI_SECTION" ]
			then
				continue
			fi
		fi
		
		# Valid var/value line? (check for variable name and then '=')
		if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
		then
			eval "INI__${SECTION}[$line]=\"\""
#			eval "echo -e \"\t\tINI__${SECTION}[@]}=\"\${INI__${SECTION}[@]}\"\""
#			eval "echo -e \"\t\t!INI__${SECTION}[@]}=\"\${!INI__${SECTION}[@]}\"\""
			
			continue
		fi	
		
		# split line at "=" sign
		IFS="="
		read -r KEY VAL <<< "${line}"
		IFS="${IFS_OLD}"

		# delete spaces around the equal sign (using extglob)
		KEY="${KEY%%+([[:space:]])}"
		VAL="${VAL##+([[:space:]])}"
		KEY=$(echo $KEY)

		eval "INI__${SECTION}[$KEY]=\"$VAL\""

	done  <"${INI_FILE}"
	
	eval "INI_ALL[$SECTION]=\"\${INI__${SECTION}[@]}\""
	
	#show_array "INI_ALL"
	#to_array "INI_ALL"
}


# #example

# eval X=${INI_ALL[rename]}
# echo ${!X[@]}
# echo ${X[@]}

# eval y=${X[model1]}
# echo $y