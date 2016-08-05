#!/bin/bash
# Init script for dbTools

pwd=`pwd`
paramsfile="params_local.sh"
mydir=`dirname $0`
templatepath=$mydir/params_local_template.sh
echo ""
echo "Initializing dbTools in $pwd"

# Create params_local.sh

echo ""
echo "- Creating $paramsfile"

if [ -e "$paramsfile" ] ; then
    echo "  $paramsfile exists, skipping"
    echo "  Please remove the file $params_local so this script can create the template"
    echo "  or make sure $paramsfile defines your source databases like in the template file  "
    echo "  located under $templatepath"
else
    cp $templatepath params_local.sh 
    echo "  Done"
fi

for file in base_tables.txt basedata_tables.txt data_tables.txt; do
echo ""
echo "- Creating table list $file"
if [ -e "$file" ] ; then
    echo "  File $file exists, skipping"
else
    echo "  Creating empty table list $file"
    touch $file
fi
done

echo "Done"
