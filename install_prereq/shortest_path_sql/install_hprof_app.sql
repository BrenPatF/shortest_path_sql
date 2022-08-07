@..\install_prereq\initspool install_hprof_app
/***************************************************************************************************
Name: install_profiler_app.sql          Author: Brendan Furey                      Date: 21-Jun-2020

Installation script for DBMS_HProf demo components in the PL/SQL Profiling module.  

The module demonstrates the use of Oracle's two profiling utilities, DBMS_Profiler (its original 
flat profiler) and DBMS_HProf (the later hierarchical profiler), and also profiling by custom code
timing instrumentation (Timer_Set). 

    GitHub: https://github.com/BrenPatF/plsql_profiling
    Blog:   'PL/SQL Profiling Notes, 1: Overview', http://aprogrammerwrites.eu/?p=703

There are install scripts for the app schema for each of the three profiling methods. Note that
installation of this module is dependent on prerequisite installs of other modules as described in
the README.

INSTALL SCRIPTS
====================================================================================================
|  Script                     |  Notes                                                             |
|===================================================================================================
|  APP SCHEMA                                                                                      |
----------------------------------------------------------------------------------------------------
| *install_hprof_app.sql*     |  Installs DBMS_HProf demo components in app schema                 |
----------------------------------------------------------------------------------------------------
|  install_profiler_app.sql   |  Installs DBMS_Profiler demo components in app schema              |
----------------------------------------------------------------------------------------------------
|  install_timer_set_app.sql  |  Installs Timer_Set demo components in app schema                  |
====================================================================================================
This file has the install script for the DBMS_HProf demo components in app schema.

Components created in app schema:

    Types               Description
    ================    ============================================================================
    Table_Count_Type    Object type used to demonstrate PL/SQL profiling with three methods

    Packages            Description
    ==================  ============================================================================
    HProf_Utils         Utility procedures and functions for use with PL/SQL profiling by DBMS_HProf
    Prof_Test           Procedures and functions to demonstrate PL/SQL profiling with DBMS_Profiler
                        and DBMS_HProf

***************************************************************************************************/

PROMPT Create package HProf_Utils
@hprof_utils.pks
@hprof_utils.pkb

@..\install_prereq\endspool