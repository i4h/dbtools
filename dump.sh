#/bin/bash
# Bash script template, based on http://www.pro-linux.de/artikel/2/111/ein-shellskript-template.html
# modifications by Ingmar Vierhaus <mail@ingmar-vierhaus.de>
set -o nounset
set -o errexit
# Script: new_script
# Global variables
SCRIPTNAME="dump.sh"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
OPTFILE=""
PW=""
DB="none"
WHAT="data and structure"
PRETTY=""
KEEP_AUTO_INCREMENT="n"
# function definitions 
function usage {
 echo "Usage: $SCRIPTNAME [options] sourcedb base|basedata|data|all [target.sql]" >&2
 echo "Dumps different kinds of data from the sourcedb"
 echo "Source databases need to be defined in params_local"
 echo "Removes auto increment if not told to keep them"
 echo ""
 echo "Options: "
 echo " -h        show this help"
 echo " -v        verbose mode"
 echo " -s        dump only structure "
 echo " -d        dump only data "
 echo " -p        make pretty data dumps "
 echo " -a        keep auto increment "
 echo " -w pw     use pw as password for mysql connection"



 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# Thanks to doubleDown on http://stackoverflow.com/questions/13219634/easiest-way-to-check-for-an-index-or-a-key-in-an-array
function exists(){
  if [ "$2" != in ]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi   
  eval '[ ${'$3'[$1]+muahaha} ]'  
}

# List of Arguments. Option flags followed by a ":" require an option, flags not followed by an ":" are optionless
while getopts ':w:vhsdp' OPTION ; do
 case $OPTION in
 s) WHAT="structure"
 ;;
 d) WHAT="data"
 ;;
 p) PRETTY="pretty"
 ;;
 a) KEEP_AUTO_INCREMENT="y"
 ;;
 v) VERBOSE=y
 ;;
 o) OPTFILE="$OPTARG"
 ;;
 w) PW="$OPTARG"
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
if (( $# != 3 )) ; then
 echo "Exactly three arguments required." >&2
 usage $EXIT_ERROR
fi
# Loop over all arguments
for ARG ; do
 if [[ $VERBOSE = y ]] ; then
     echo -n "Argument: "
     echo $ARG
 fi
done


SOURCE=$1
TABLES=$2
TARGET=$3

# Load parameter file
source params_local.sh


TARGET=$TARGET

# Set default parameters for connection
DB=$SOURCE
HOST="localhost"
USER="root"
PASSWORD=""


#Load parameters from script arguments / params file
if [[ $PW != "" ]] ; then
    PASSWORD=$PW
else
    if exists $SOURCE in  PASSWORDS  ; then
	PASSWORD=${PASSWORDS[$SOURCE]}
    else
	echo "WARNING: No password for $SOURCE given in params_local. Attempting to connect without password." >&2
    fi
fi
if exists $SOURCE in DBS  ; then
    DB=${DBS[$SOURCE]}
fi
if exists $SOURCE in USERNAMES  ; then
    USER=${USERNAMES[$SOURCE]}
fi
if exists $SOURCE in HOSTS  ; then
    HOST=${HOSTS[$SOURCE]}
fi

# Echo what we will do
echo "dump.sh: Dumping $PRETTY $WHAT from $TABLES tables in $SOURCE database ($DB on $USER@$HOST) to "$TARGET 

if [[ $VERBOSE = y ]] ; then
    echo "Connection: Host: $HOST, Database: $DB, Username: $USER, Password: $PASSWORD"
fi

# Get list of tables
tbls=""
case $TABLES in
    all ) ;;
    base ) file="base_tables.txt" 
    ;;
    basedata ) file="basedata_tables.txt" 
    ;;
    data ) file="data_tables.txt" 
    ;;
    *) echo "Second argument $TABLES not recognized (expecting base|basedata|data|all)" 
        usage $EXIT_ERROR
	;;
esac

if [ "$TABLES" != "all" ] ; then
    file=$file
    if [ ! -e "$file" ] ; then
	echo "Table list $file not found. Aborting."
	exit $EXIT_ERROR
    fi
    tbls=`tr  '\n' ' ' < $file` 
fi

# Make command

flags="-u "$USER
if [ "$PASSWORD" != "" ]; then
    flags=$flags" -p"$PASSWORD
fi

if [ "$WHAT" = "data" ] ; then
    flags=$flags" --no-create-info"
fi
if [ "$WHAT" = "structure" ] ; then
    flags=$flags" --no-data"
fi
if [ "$PRETTY" = "pretty" ] ; then
    flags=$flags" --extended-insert=FALSE --complete-insert"
fi


cmd="/usr/bin/mysqldump -h $HOST  $flags $DB $tbls"

if [[ $VERBOSE = y ]] ; then
     echo "Command: " $cmd" > "$TARGET
fi

# Run
if [ "$tbls" != "" ] || [ "$TABLES" == "all" ]; then 
    ($cmd) > $TARGET
else
    echo "dump.sh: Warning: No tables in selection $TABLES, creating empty dump file"
    echo ""> $TARGET
fi

#Remove auto_increment
if [[ $KEEP_AUTO_INCREMENT = "n" ]] ; then
    sed -i 's/ AUTO_INCREMENT=[0-9]*\b//' $TARGET
fi

exit $EXIT_SUCCESS
