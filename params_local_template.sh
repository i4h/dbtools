# Parameters to be sourced by the shell scripts in this folder 
# Rename to params_local

declare -A HOSTS
declare -A DBS
declare -A USERNAMES
declare -A PASSWORDS

# Connection parameters for source databases

## Source database dev
HOSTS["dev"]="localhost"
DBS["dev"]="myproject"
USERNAMES["dev"]="root"
PASSWORDS["dev"]=""

## Source database testing
HOSTS["testing"]="localhost"
DBS["testing"]="myproject_testing"
USERNAMES["testing"]="root"
PASSWORDS["testing"]=""

## Source database production
HOSTS["production"]="localhost"
DBS["production"]="myproject_production"
USERNAMES["production"]="root"
PASSWORDS["production"]=""

## More source databases...
