DEFINE LIB=&1
/***************************************************************************************************
Name: c_dprof_syns .sql                 Author: Brendan Furey                      Date: 21-Jun-2020

Prerequisite synonyms script in the PL/SQL Profiling module for the app schema.

The module demonstrates the use of Oracle's two profiling utilities, DBMS_Profiler (its original 
flat profiler) and DBMS_HProf (the later hierarchical profiler), and also profiling by custom code
timing instrumentation (Timer_Set). 

    GitHub: https://github.com/BrenPatF/plsql_profiling
    Blog:   'PL/SQL Profiling Notes, 1: Overview', http://aprogrammerwrites.eu/?p=703

There are prerequisitea installation scripts for sys, lib and app schemas:

	install_sys_all.sql  -   Overall install prerequisites script for the sys schema
    install_lib_all.sql  -   Overall driver install prerequisites script for the lib schema
    c_syns_all.sql       -   Overall synonyms script for the app schema

INSTALL SCRIPTS - prerequisite synonyms for the app schema
====================================================================================================
|  Script                      |  Notes                                                            |
|==================================================================================================|
|  c_utils_syns.sql            |  Synonyms script for the Utils module (copied from there)         |
|--------------------------------------------------------------------------------------------------|
|  c_timer_set_syns.sql        |  Synonyms script for the Timer_Set module (copied from there)     |
|--------------------------------------------------------------------------------------------------|
|  c_hprof_syns.sql            |  Synonyms script for the hierarchical profiler                    |
|--------------------------------------------------------------------------------------------------|
| *c_dprof_syns.sql*           |  Synonyms script for the flat profiler                            |
====================================================================================================

Creates synonyms for flat profiler components in app schema to lib schema.

Synonyms created:

    Synonym                   Object Type
    ========================  ============================================================================
    plsql_profiler_runs       Table
    plsql_profiler_units      Table
    plsql_profiler_data       Table
    plsql_profiler_runnumber  Sequence

***************************************************************************************************/
PROMPT Creating synonyms for &LIB Utils components...
CREATE OR REPLACE SYNONYM plsql_profiler_runs FOR &LIB..plsql_profiler_runs
/
CREATE OR REPLACE SYNONYM plsql_profiler_units FOR &LIB..plsql_profiler_units
/
CREATE OR REPLACE SYNONYM plsql_profiler_data FOR &LIB..plsql_profiler_data
/
CREATE OR REPLACE SYNONYM plsql_profiler_runnumber FOR &LIB..plsql_profiler_runnumber
/
