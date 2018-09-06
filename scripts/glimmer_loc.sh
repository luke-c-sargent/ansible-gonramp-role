#!/usr/bin/env bash

TOOLDEPDIR=""
TOOLDATADIR=""
CONF_XML=""

function usage
{
	echo "usage: ./glimmer_loc.sh [-t directory] [-d directory] [-c file]"
	echo "	-t: tool dependency directory"
	echo "	-d: tool data directory"
	echo "	-c: tool_data_table_conf file"
}

#parse args
if [ $# -lt 1 ]; then
	echo "insufficient number of arguments..."
	usage
	exit 1
fi

while [ "$1" != "" ]; do
	case $1 in
		-t | --tool_dependencies )	shift
						TOOLDEPDIR=$1
						;;
		-d | --tool_data )		shift
						TOOLDATADIR=$1
						;;
		-c | --conf_xml )		shift
						CONF_XML=$1
						;;
		-h | --help )			usage
						exit
						;;
		* )				usage
						exit 1
	esac
	shift
done

#ensure variable files / directories exist
if [ ! -d "$TOOLDEPDIR" ]; then
	echo "Tool dependency directory:"
	echo "$TOOLDEPDIR"
	echo "... does not exist, exiting"
	exit 1
fi

if [ ! -d "$TOOLDATADIR" ]; then
	echo "Tool data directory:"
	echo "$TOOLDATADIR"
	echo "... does not exist, exiting"
	exit 2
elif [ ! -f "$TOOLDATADIR/glimmer_hmm.loc" ]; then
	echo "glimmer_hmm.loc not found in:"
	echo "$TOOLDATADIR"
	echo "... exiting"
	exit 1
fi

if [ ! -f "$CONF_XML" ]; then
	echo "Tool data table configuration file:"
	echo "$CONF_XML"
	echo "... does not exist, exiting"
	exit 3
fi

TRAINEDDIR=$(sudo find $TOOLDEPDIR/glimmerhmm -name trained_dir -type d)
if [ ! "$?" ]; then
	echo "trained_dir not found in directory:"
	echo "$TOOLDEPDIR/glimmerhmm/"
	echo "... exiting"
	exit 1
fi


GLIMMERLOC="
# GENERATED BY G-OnRamp
human	Human	$TRAINEDDIR/human
celegans	Celegan	$TRAINEDDIR/Celegans
arabidopsis	Arabidopsis	$TRAINEDDIR/arabidopsis
rice	Rice	$TRAINEDDIR/rice
zebrafish	Zebrafish	$TRAINEDDIR/zebrafish
"

# sed has stringent newline requirements for replacement text
GLIMMER_CONF='\
	<!-- glimmer_hmm trained_dir -->\
	<table name="glimmer_hmm_trained_dir" comment_char="#">\
	  <columns>value, name, path</columns>\
	  <file path="tool-data/glimmer_hmm.loc" />\
	</table>\
'

#GALAXYDR="/home/galaxy/galaxy"
LOC_FILE="$TOOLDATADIR/glimmer_hmm.loc"
#CONF_XML="$GALAXYDR/config/tool_data_table_conf.xml.sample"


# write glimmer
echo "$GLIMMERLOC" >| "$LOC_FILE"

# insert configuration xml to tool
sed -i.bak 's@</tables>@'"$GLIMMER_CONF"'</tables>@g' "$CONF_XML"
rm -f "$CONF_XML".bak
