# DbTools

This repository contains two main scripts:
- dump.sh: A wrapper bash script for mysqldump that makes dumping data from your dev,testing,production,... systems a little easier
- make_fixtures.sh: A script that re-generates fixtures if your database structure changed.

 
## Setup

- Clone this repository into some directory, for example /home/user/myproject/dbtools/
- cd into the directory where you keep your dumps
- run `/home/user/myproject/dbtools/init.sh`
- Edit the newly created file params_local.sh with the details for your dev, testing and any other environments
- Edit the newly created files base\_tables.txt, basedata\_tables.txt and data\_tables.txt and write down the names of your 
  tables that fall into this category. Write one table per line. See [Fixtures](#fixtures) for more information.

## Dumping data with dump.sh
````
/home/user/myproject/dbtools/dump.sh -h
````
````
Exactly three arguments required.
Usage: dump.sh [options] sourcedb base|basedata|data|all [target.sql]
Dumps different kinds of data from the sourcedb
Source databases need to be defined in params_local
Removes auto increment if not told to keep them

Options: 
 -h        show this help
 -v        verbose mode
 -s        dump only structure 
 -d        dump only data 
 -p        make pretty data dumps 
 -a        keep auto increment 
 -w pw     use pw as password for mysql connection
````

## Fixtures
````
/home/user/myproject/dbtools/make_fixtures.sh -h
````
````
Usage: make_fixtures.sh [options] [file] ...
Creates fixtures for tests by combining base data with data for test
If no file is given, runs for testdata_*
Files are expected to have a name like testdata_X_name.sql
Runs in two steps:
1) Creates dumps structure.sql and base.sql from
main database
2) For each file testdata_X_name.sql loads a clean database with
 - structure.sql
 - base.sql
 - basedata_X.sql
 - testdata_X_name.sql
and saves result in fixture_name.sql

Options: 
 -h        show this help
 -v        verbose mode
 -b        only get structure.sql and base.sql from main
````

### Intended Workflow 

While migrations are great for development and production environments, it is not clear how migrate the 100 sql dumps that contain
the fixtures for your tests. I am handling this by divided the tables in the database into three categories:
- Base: Tables that contain data, that is the same for all tests. A good example are the tables containg the rules for your Role Based Access Control.
- Basedata: Tables that contain data that is the same for many tests. Let's say you have created a couple of testing users that you use for a test suite that needs 10 fixtures. Then the user table would need to be listed in basedata.txt. 
- Data: Tables that contain the actual data for the test. 

After dividing your tables into these three categories and listing the tablenames in the files base\_tables.txt, basedata\_tables.txt and data\_tables.txt, the workflow is as follows.

- Prepare your testing db so that it contains your fixture data.
- If it doesn't exist yet, create your basedata for the set of tests "A":
````
/home/user/myproject/dbtools/dump.sh -p testing basedata basedata_A.sql
````
- Create your test data
````
/home/user/myproject/dbtools/dump.sh -p testing data testdata_A_testname.sql
````
- Now create the fixture
````
/home/user/myproject/dbtools/make_fixtures.sh testdata_A_testname.sql
````
The result should look like this
````
Updating structure from dev
dump.sh: Dumping  structure from all tables in dev database (euf2030 on root@localhost) to structure.sql

Updating base from dev
dump.sh: Dumping pretty data from base tables in dev database (euf2030 on root@localhost) to base.sql
dump.sh: Warning: No tables in selection base, creating empty dump file


Building fixture for test testname
Cleaning db
Loading:
 - structure
 - base
 - basedata from basedata_A.sql
 - testdata from testdata_A_testname.sql
Dumping into fixture_testname.sql
````
Your complete data is now dumped in fixture_testname.sql.
If you work on your app and update your table structure or update one of the base tables, you only need to run 
````
/home/user/myproject/dbtools/make_fixtures.sh 
````
This will refresh the structure and base dumps from your development database and rebuild the fixtures. It will do this for all files named testdata_X_name.sql in your data directory.






