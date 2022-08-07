CREATE OR REPLACE PACKAGE BODY HProf_Utils IS
/***************************************************************************************************
Name: hprof_utils.pkb                      Author: Brendan Furey                   Date: 21-Jun-2020

Package body component in the PL/SQL Profiling module. 

The module demonstrates the use of Oracle's two profiling utilities, DBMS_Profiler (its original 
flat profiler) and DBMS_HProf (the later hierarchical profiler), and also profiling by custom code
timing instrumentation (Timer_Set). 

    GitHub: https://github.com/BrenPatF/plsql_profiling
    Blog:   'PL/SQL Profiling Notes, 1: Overview', http://aprogrammerwrites.eu/?p=703

There are several packages used to demonstrate the three profiling methods, some shared and some 
specific to one or two of the methods. Note that installation of this module is dependent on 
prerequisite installs of other modules as described in the README.

PACKAGES AND TYPES
====================================================================================================
|  Package/Object    |  Type     |  Notes                                                          |
|==================================================================================================|
|  COMMON APP COMPONENTS                                                                           |
|--------------------------------------------------------------------------------------------------|
|  Prof_Test         |  Package  |  Procedures and functions to test PL/SQL profiling              |
|--------------------------------------------------------------------------------------------------|
|  Table_Count_Type  |  Object   |  Object type to test PL/SQL profiling                           |
|--------------------------------------------------------------------------------------------------|
|  DBMS_HPROF COMPONENTS                                                                           |
|--------------------------------------------------------------------------------------------------|
| *HProf_Utils*      |  Package  |  Utility procedures and functions for use with PL/SQL profiling |
|                    |           |  by DBMS_HProf                                                  |
|--------------------------------------------------------------------------------------------------|
|  TIMER_SET COMPONENTS                                                                            |
|--------------------------------------------------------------------------------------------------|
|  Timer_Set_Test    |  Package  |  Procedures and functions to test PL/SQL profiling by custom    |
|                    |           |  code timing via the Timer_set module                           |
====================================================================================================
This file has the HProf_Utils package body.

***************************************************************************************************/

g_trace_id  NUMBER;
/***************************************************************************************************

Start_Profiling: Call DBMS_HProf.Start_Profiling and save the returned trace id in package global

***************************************************************************************************/
PROCEDURE Start_Profiling IS
BEGIN

  g_trace_id := DBMS_HProf.Start_Profiling;

END Start_Profiling;

/***************************************************************************************************

Stop_Profiling: Call DBMS_HProf.Stop_Profiling, then analyse in two ways: first, writing html
                report; second, writing to the DBMS_HProf tables for querying

***************************************************************************************************/
FUNCTION Stop_Profiling(
            p_run_comment                  VARCHAR2,                       -- run comment
            p_filename                     VARCHAR2) RETURN PLS_INTEGER IS -- file name for html report
  l_report_clob		CLOB;
BEGIN

  DBMS_HProf.Stop_Profiling;
  DBMS_HProf.Analyze(trace_id => g_trace_id, report_clob => l_report_clob);
  DBMS_XSLProcessor.CLOB2File(cl => l_report_clob, flocation => 'INPUT_DIR', fname => p_filename);
  RETURN DBMS_HProf.Analyze(trace_id => g_trace_id, run_comment => p_run_comment);

END Stop_Profiling;

END HProf_Utils;
/
SHO ERR