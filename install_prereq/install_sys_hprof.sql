@..\initspool install_sys_hprof
DEFINE APP=shortest_path_sql
DEFINE LIB=lib
/***************************************************************************************************
Name: install_sys_hprof .sql            Author: Brendan Furey                      Date: 21-Jun-2020

Install sys script for the hierarchical profiler in the PL/SQL Profiling module.

The module demonstrates the use of Oracle's two profiling utilities, DBMS_Profiler (its original 
flat profiler) and DBMS_HProf (the later hierarchical profiler), and also profiling by custom code
timing instrumentation (Timer_Set). 

    GitHub: https://github.com/BrenPatF/plsql_profiling
    Blog:   'PL/SQL Profiling Notes, 1: Overview', http://aprogrammerwrites.eu/?p=703

There are prerequisitea installation scripts for sys, lib and app schemas:

    install_sys_all.sql  -   Overall install prerequisites script for the sys schema
    install_lib_all.sql  -   Overall driver install prerequisites script for the lib schema
    c_syns_all.sql       -   Overall synonyms script for the app schema

INSTALL SCRIPTS - prerequisites for the sys schema
====================================================================================================
|  Script                      |  Notes                                                            |
|==================================================================================================|
|  install_sys.sql             |  Install sys script for the Utils module (copied from there)      |
|--------------------------------------------------------------------------------------------------|
| *install_sys_hprof.sql*      |  Install sys script for the hierarchical profiler                 |
====================================================================================================
This script grants execute privilegre on DBMS_Hprof to app and lib schemas.

***************************************************************************************************/

GRANT EXECUTE ON DBMS_Hprof TO &APP, &LIB
/
@..\endspool
