DEFINE LIB=&1
/***************************************************************************************************
Name: c_hprof_syns .sql                 Author: Brendan Furey                      Date: 21-Jun-2020

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
| *c_hprof_syns.sql*           |  Synonyms script for the hierarchical profiler                    |
|--------------------------------------------------------------------------------------------------|
|  c_dprof_syns.sql            |  Synonyms script for the flat profiler                            |
====================================================================================================

Creates synonyms for hierarchical profiler components in app schema to lib schema.

Synonyms created:

    Synonym                   Object Type
    ========================  ============================================================================
    dbmshp_runs               Table
    dbmshp_function_info      Table
    dbmshp_parent_child_info  Table
    dbmshp_trace_data         Table
    dbmshp_runnumber          Table
    dbmshp_tracenumber        Sequence

***************************************************************************************************/
PROMPT Creating synonyms for &LIB Utils components...
CREATE OR REPLACE SYNONYM dbmshp_runs FOR &LIB..dbmshp_runs
/
CREATE OR REPLACE SYNONYM dbmshp_function_info FOR &LIB..dbmshp_function_info
/
CREATE OR REPLACE SYNONYM dbmshp_parent_child_info FOR &LIB..dbmshp_parent_child_info
/
CREATE OR REPLACE SYNONYM dbmshp_trace_data FOR &LIB..dbmshp_trace_data
/
CREATE OR REPLACE SYNONYM dbmshp_runnumber FOR &LIB..dbmshp_runnumber
/
CREATE OR REPLACE SYNONYM dbmshp_tracenumber FOR &LIB..dbmshp_tracenumber
/
CREATE OR REPLACE SYNONYM HProf_Utils FOR &LIB..HProf_Utils
/