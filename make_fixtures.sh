#!/bin/bash
# Bash script template, based on http://www.pro-linux.de/artikel/2/111/ein-shellskript-template.html
# modifications by Ingmar Vierhaus <mail@ingmar-vierhaus.de>
set -o nounset
set -o errexit
# Script: new_script
# Global variables
SCRIPTNAME="make_fixtures.sh"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
OPTFILE=""
ONLY_BASE="n"
MYDIR=`dirname $0`



# function definitions 
function usage {
 echo "Usage: $SCRIPTNAME [-options] [file] ..." >&2
 echo "Creates fixtures for tests by combining base data with data for test"
 echo "If no file is given, runs for testdata_*"
 echo "Files are expected to have a name like testdata_X_name.sql"
 echo "Runs in two steps:"
 echo "1) Creates dumps structure.sql and base.sql from"
 echo "main database"
 echo "2) For each file testdata_X_name.sql loads a clean database with"
 echo " - structure.sql"
 echo " - base.sql"
 echo " - basedata_X.sql"
 echo " - testdata_X_name.sql"
 echo "and saves result in fixture_name.sql"
 echo ""
 echo "Options: "
 echo " -h        show this help"
 echo " -v        verbose mode"
 echo " -b        only get structure.sql and base.sql from main"
 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}
# List of Arguments. Option flags followed by a ":" require an option, flags not followed by an ":" are optionless
while getopts ':o:vhb' OPTION ; do
 case $OPTION in
 v) VERBOSE=y
 ;;
 o) OPTFILE="$OPTARG"
 ;;
 b) ONLY_BASE="y"
 ;;
 h) usage $EXIT_SUCCESS
 ;;
 \?) echo "Option \"-$OPTARG\" not recognized." >&2
 usage $EXIT_ERROR
 ;;
 :) echo "Option \"-$OPTARG\" requires an argument." >&2
 usage $EXIT_ERROR
 ;;
 *) echo "Something impossible happened, stand by for implosion of space time continuum."
>&2
 usage $EXIT_BUG
 ;;
 esac
done
# Shift over used up arguments
shift $(( OPTIND - 1 ))
# Test for valid number of arguments
#if (( $# < 1 )) ; then
# echo "At least one argument required." >&2
# usage $EXIT_ERROR
#fi
# Loop over all arguments
for ARG ; do
 if [[ $VERBOSE = y ]] ; then
     echo -n "Argument: "
     echo $ARG
 fi
done

# Load parameter file
source params_local.sh

# Update structure dump
echo "Updating structure from dev"
$MYDIR/dump.sh -s dev all structure.sql 

# Update base dump
echo ""
echo "Updating base from dev"
$MYDIR/dump.sh -dp dev base base.sql 
echo ""

# Leave if only_base flag set
if [[ "$ONLY_BASE" = "y" ]] ; then
    exit $EXIT_SUCCESS    
fi

if [ $# -ne 1 ]; then
    files=`ls testdata_*sql`
else
    files=$1
fi


for i in $files; do

    name=`echo $i | cut -f 3 -d "_" | cut -f 1 -d "."`
    X=`echo $i | cut -f 2 -d "_"`
    target="fixture_"$name".sql"
    basedata="basedata_"$X".sql"

    echo ""
    echo "Building fixture for test $name"

    echo "Cleaning db"
    $MYDIR/clear_database.sh
    echo "Loading:"
    echo " - structure"
    $MYDIR/load.sh structure.sql
    echo " - base"
    $MYDIR/load.sh base.sql
    echo " - basedata from "$basedata
    $MYDIR/load.sh $basedata
    echo " - testdata from "$i
    $MYDIR/load.sh $i
    echo "Dumping into "$target
    $MYDIR/dump.sh testing all $target
done


exit $EXIT_SUCCESS
