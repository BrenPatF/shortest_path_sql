/***************************************************************************************************
Name: install_sys_all .sql              Author: Brendan Furey                      Date: 21-Jun-2020

Prerequisites installation script in the Shortest Path Analysis of Large Networks by SQL and PL/SQL
module for the sys schema.

    GitHub: https://github.com/BrenPatF/shortest_path_sql
    Blog:   Shortest Path Analysis of Large Networks by SQL and PL/SQL
            https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html

There are prerequisitea installation scripts for sys, lib and app schemas:

   *install_sys_all.sql* -   Overall install prerequisites script for the sys schema
    install_lib_all.sql  -   Overall driver install prerequisites script for the lib schema
    c_syns_all.sql       -   Overall synonyms script for the shortest_path_sql schema

INSTALL SCRIPTS - prerequisites for the sys schema
====================================================================================================
|  Script                      |  Notes                                                            |
|==================================================================================================|
|  install_sys.sql             |  Install sys script for the Utils module (copied from there)      |
|--------------------------------------------------------------------------------------------------|
|  install_sys_hprof.sql       |  Install sys script for the hierarchical profiler                 |
|--------------------------------------------------------------------------------------------------|
|  install_sys_fks_sys.sql     |  Install sys script for the sys_fks example dataset               |
====================================================================================================
This script calls the sys install scripts.

***************************************************************************************************/
@install_sys
@install_sys_hprof
@install_sys_fks_sys
