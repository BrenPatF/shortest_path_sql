# Shortest Path Analysis of Large Networks by SQL and PL/SQL
<img src="mountains.png"><br />

This project is on the use of SQL and PL/SQL to solve shortest path problems on large networks on an Oracle database. It provides solutions in pure SQL (based on previous articles by the author), and solutions in PL/SQL with embedded SQL that scale better for larger problems.

It applies the solutions to a range of problems, upto a size of 2,800,309 nodes and 109,262,592 links.

Standard and custom methods for execution time profiling of the code are included, and one of the algorithms implemented in PL/SQL is tuned based on the profiling.

The two PL/SQL entry points have automated unit tests using the Math Function Unit Testing design pattern, [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester).

<img src="kevin-bacon.png"><br />
[Movie Morsel: Six Degrees of Kevin Bacon](http://www.markrobinsonwrites.com/the-music-that-makes-me-dance/2018/3/11/movie-morsel-six-degrees-of-kevin-bacon)

There *will be* some short recordings on the project (around 2m each), which can also be viewed via a Twitter thread:

| Recording                     | Tweet                                                                                   |
|:------------------------------|:----------------------------------------------------------------------------------------|
| shortest_path_sql.mp4         | [1: shortest_path_sql](https://twitter.com/BrenPatF/status/) |

There is also a blog post:

- [Blog: Shortest Path Analysis of Large Networks by SQL and PL/SQL](https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html)

## In this README...
[&darr; Background](#background)<br />
[&darr; Installation](#installation)<br />
[&darr; Running the examples](#running-the-examples)<br />
[&darr; Running the unit tests](#running-the-unit-tests)<br />
[&darr; See Also](#see-also)

## Background
[&uarr; In this README...](#in-this-readme)

In 2015 I posted a number of articles on network analysis via SQL and array-based PL/SQL, including [SQL for Shortest Path Problems 2: A Branch and Bound Approach](http://aprogrammerwrites.eu/?p=1415) and [PL/SQL Pipelined Function for Network Analysis](http://aprogrammerwrites.eu/?p=1426). These were tested on networks up to a size of 
58,228 nodes and 214,078 links, but were not intended for really large networks.

Recently, I came across (by way of an article on using PostgreSQL for network analysis, [Using the PostgreSQL Recursive CTE - Part Two, Bryn Llewellyn, March 2021](https://blog.yugabyte.com/using-postgresql-recursive-cte-part-2-bacon-numbers/)) a set of network datasets published by an American college, [Bacon Numbers Datasets from Oberlin College, December 2016](https://www.cs.oberlin.edu/~rhoyle/16f-cs151/lab10/index.html). These range in size up to 2,800,309 nodes and 109,262,592 links, and I wondered if I could develop my ideas further to enable solution in Oracle SQL and PL/SQL of the larger networks.

## Installation
[&uarr; In this README...](#in-this-readme)<br />
[&darr; Install 1: Install prerequisite tools (if necessary)](#install-1-install-prerequisite-tools-if-necessary)<br />
[&darr; Install 2: Clone git repository](#install-2-clone-git-repository)<br />
[&darr; Install 3: Install prerequisite modules](#install-3-install-prerequisite-modules)<br />
[&darr; Install 4: Copy the unit test input JSON files to the database server](#install-4-copy-the-unit-test-input-json-files-to-the-database-server-optional---for-unit-testing)<br />
[&darr; Install 5: Copy the input data files to the database server](#install-5-copy-the-input-data-files-to-the-database-server)<br />

### Install 1: Install prerequisite tools (if necessary)
- [&uarr; Installation](#installation)

#### Oracle database
The database installation requires a minimum Oracle version of 12.2 [Oracle Database Software Downloads](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html).

#### Github Desktop
In order to clone the code as a git repository you need to have the git application installed. I recommend [Github Desktop](https://desktop.github.com/) UI for managing repositories on windows. This depends on the git application, available here: [git downloads](https://git-scm.com/downloads), but can also be installed from within Github Desktop, according to these instructions: 
[How to install GitHub Desktop](https://www.techrepublic.com/article/how-to-install-github-desktop/).

#### nodejs (Javascript backend) [Optional]
nodejs is needed to run a program that turns the unit test output files into formatted HTML pages. It requires no JavaScript knowledge to run the program, and nodejs can be installed [here](https://nodejs.org/en/download/).

### Install 2: Clone git repository
[&uarr; Installation](#installation)

The following steps will download the repository into a folder, shortest_path_sql, within your GitHub root folder:
- Open Github desktop and click [File/Clone repository...]
- Paste into the url field on the URL tab: https://github.com/BrenPatF/shortest_path_sql.git
- Choose local path as folder where you want your GitHub root to be
- Click [Clone]

### Install 3: Install prerequisite modules
[&uarr; Installation](#installation)

The install depends on the prerequisite modules Utils, Trapit, Timer_Set and Oracle's profilers, all installed in `lib` schemas. The sys install creates the lib schema for the pre-reqquisites and shortest_path_sql for the network code and tables.

The prerequisite modules can be installed by following the instructions for each module at the module root pages listed in the `See Also` section below. This allows inclusion of the examples and unit tests for those modules. Alternatively, the next section shows how to install these modules directly without their examples or unit tests.

#### [Schema: sys; Folder: install_prereq] Create lib and app schemas and Oracle directory
install_sys.sql creates an Oracle directory, `input_dir`, pointing to 'c:\input'. Update this if necessary to a folder on the database server with read/write access for the Oracle OS user
- Run script from slqplus:

```sql
SQL> @install_sys_all
```

#### [Schema: lib; Folder: install_prereq\lib] Create lib components
- Run script from slqplus:

```sql
SQL> @install_lib_all
```

#### [Schema: shortest_path_sql; Folder: install_prereq\shortest_path_sql] Create shortest_path_sql synonyms
- Run script from slqplus:

```sql
SQL> @c_syns_all
```
#### [Folder: (npm root)] Install npm trapit package [Optional - for unit testing]
The npm trapit package is a nodejs package used to format unit test results in text and HTML format. 

Open a DOS or Powershell window in the folder where you want to install npm packages, and, with [nodejs](https://nodejs.org/en/download/) installed, run
```
$ npm install trapit
```
This should install the trapit nodejs package in a subfolder .\node_modules\trapit

### Install 4: Copy the unit test input JSON files to the database server [Optional - for unit testing]
[&uarr; Installation](#installation)

- Copy the following files from the unit_test\input folders to the server folder pointed to by the Oracle directory INPUT_DIR:
    - tt_shortest_path_sql.purely_wrap_ins_min_tree_links_inp.json
    - tt_shortest_path_sql.purely_wrap_ins_node_roots_inp.json

- There is also a powershell script to do this, assuming C:\input as INPUT_DIR. From a powershell window in the root folder:
```powershell
$ ./Copy-JSONToInput.ps1
```

### Install 5: Copy the input data files to the database server
[&uarr; Installation](#installation)

- Unzip the following files from the examples\input folders to the server folder pointed to by the Oracle directory INPUT_DIR:

    - brightkite_edges.csv.zip
    - imdb.no_tv_v.txt.zip
    - imdb.only_tv_v.txt.zip
    - imdb.pre1950.txt.zip
    - imdb.small.txt.zip
    - imdb.top250.txt.zip

The files are in Windows format, so conversion may be needed if not using Windows.

- There is also a powershell script to do this, assuming C:\input as INPUT_DIR. From a powershell window in the root folder:
```powershell
$ ./Copy-InputDataToInput.ps1
```
The following files are too big, even zipped to save to GitHub, so these have to be obtained from the original source site (and converted to Windows format, if necessary): 

https://www.cs.oberlin.edu/~rhoyle/16f-cs151/lab10/index.html

    - imdb.full.txt
    - imdb.post1950.txt


## Running the examples
[&uarr; In this README...](#in-this-readme)<br />

Each example has a driver sqlplus script, run\*.sql, in its own subfolder:

```
examples
    bacon
        full
        no_tv_v
        only_tv_v
        post1950
        pre1950
        small
        top250
    brightkite
        main
    foreign_keys
        sys_fks
    three_subnets
        main
```
The driver script calls a setup script that
- re-installs the base database components
- loads the example data to the nodes and links tables

The driver script then calls multiple scripts from the examples folder to execute the PL/SQL programs, with various parameter combinations, spoolng to individual files.

For example, the call to the driver for bacon/full is, from its subfolder:
```
SQL> @run_bacon_full
```
There is also a powershell script Run-All.ps1 that navigates to each subfolder, logs on and runs the driver script. This takes a long time to run!

## Running the unit tests
[&uarr; In this README...](#in-this-readme)<br />

The unit test programs may be run from the unit_test folder (which calls the unit test install script at the start):

```sql
SQL> @r_tests
```

The output results files are processed by a JavaScript program that has to be installed separately, as described above [Install npm trapit package](#folder-npm-root-install-npm-trapit-package-optional---for-unit-testing). The JavaScript program produces listings of the results in HTML and/or text format in a subfolder named from the unit test title, and the subfolders are included in the folder `unit_test\output`. 

To run the processor, open a powershell window in the npm trapit package folder after placing the output JSON files, tt_shortest_path_sql.purely_wrap_ins_min_tree_links_out.json, tt_shortest_path_sql.purely_wrap_ins_node_roots_out.json in a new (or existing) folder, shortest_path_sql, within the subfolder externals and run:

```
$ node externals\format-externals shortest_path_sql
```
This outputs to screen the following summary level report, as well as writing the formatted results files to the subfolders indicated:
```
Unit Test Results Summary for Folder ./externals/shortest_path_sql
==================================================================
 File                                                          Title                                  Inp Groups  Out Groups  Tests  Fails  Folder                               
-------------------------------------------------------------  -------------------------------------  ----------  ----------  -----  -----  -------------------------------------
 tt_shortest_path_sql.purely_wrap_ins_min_tree_links_out.json  Oracle SQL Shortest Paths: Node Tree            3           2      7      0  oracle-sql-shortest-paths_-node-tree 
 tt_shortest_path_sql.purely_wrap_ins_node_roots_out.json      Oracle SQL Shortest Paths: Node Roots           2           2      3      0  oracle-sql-shortest-paths_-node-roots

0 externals failed, see ./externals/shortest_path_sql for scenario listings
```
The process has also been automated in a powershell script, Run_Ut.ps1, in folder unit_test, which has the following hard-coded folders:
```
$userRoot='C:\Users\Brend\OneDrive\Documents\'
$sqlDir = $userRoot + 'GitHub\shortest_path_sql\unit_test\'
$npmDir = $userRoot + 'demo\npm\node_modules\trapit\'
$inputDir = 'C:\input\'
```

## Operating System/Oracle Versions
### Windows
Windows 11
### Oracle
Oracle Database Version 21.3.0.0.0

## See Also
[&uarr; In this README...](#in-this-readme)<br />
- [Blog: Shortest Path Analysis of Large Networks by SQL and PL/SQL](https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html)
- [The Math Function Unit Testing design pattern, implemented in nodejs](https://github.com/BrenPatF/trapit_nodejs_tester)
- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)
- [Utils - Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils)
- [Timer_Set - Oracle PL/SQL code timing module](https://github.com/BrenPatF/timer_set_oracle)
- [Powershell utilities module](https://github.com/BrenPatF/powershell_utils)

## License
MIT
