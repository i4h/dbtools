#!/bin/bash

# Loads the given dump into the testing database

set -o nounset
set -o errexit

# Thanks to doubleDown on http://stackoverflow.com/questions/13219634/easiest-way-to-check-for-an-index-or-a-key-in-an-array
function exists(){
  if [ "$2" != in ]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi   
  eval '[ ${'$3'[$1]+muahaha} ]'  
}



source params_local.sh

DB=""
HOST=""
USER=""
PASSWORD=""
SOURCE="testing"



if exists $SOURCE in  PASSWORDS  ; then
    PASSWORD=${PASSWORDS[$SOURCE]}
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

if [ "$USER" == "" ] || [ "$PASSWORD" == "" ] || [ "$HOST" == "" ] || [ "$DB" == "" ] ; then
    echo "For this to work, all parameters for source databse testing need to be defined in  params_local"
    exit
fi;


echo "Running mysql -h $HOST -u $USER -p$PASSWORD $DB < $1"
mysql -h $HOST -u $USER -p$PASSWORD $DB < $1


