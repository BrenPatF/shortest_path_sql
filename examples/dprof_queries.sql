DEFINE RUN_ID=&1
/***************************************************************************************************
Name: dprof_queries.sql                 Author: Brendan Furey                      Date: 21-Jun-2020

Query script component in the PL/SQL Profiling module.

The module demonstrates the use of Oracle's two profiling utilities, DBMS_Profiler (its original 
flat profiler) and DBMS_HProf (the later hierarchical profiler), and also profiling by custom code
timing instrumentation (Timer_Set). 

    GitHub: https://github.com/BrenPatF/plsql_profiling
    Blog:   'PL/SQL Profiling Notes, 1: Overview', http://aprogrammerwrites.eu/?p=703

There are driver SQL scripts for two examples to demonstrate profiling via DBMS_Profiler: One is a 
general example and the other involves calls to a system sleep procedure. Each of the three methods
of profiling demonstrated has a similar pair of driver scripts.

DRIVER SCRIPTS
====================================================================================================
|  SQL Script          |  Calls                          |  Notes                                  |
|===================================================================================================
|  dp_example_general  |  DBMS_Profiler.Start_Profiling  |  Start profiling with DBMS_Profiler     |
|                      |  Prof_Test.A_Calls_B            |  Entry point for mutually recursive     |
|                      |                                 |  calls                                  |
|                      |  Prof_Test.DBFunc               |  Database function called by query      |
|                      |  Table_Count_Type               |  Object type used to demonstrate PL/SQL |
|                      |                                 |  profiling                              |
|                      |  Prof_Test.R_Calls_R            |  Entry point for recursive calls        |
|                      |  DBMS_Profiler.Stop_Profiling   |  Stop profiling                         |
|                      |  dprof_queries.sql              |  Query script to show results           |
----------------------------------------------------------------------------------------------------
|  dp_example_sleep    |  DBMS_Profiler.Start_Profiling  |  Start profiling with DBMS_Profiler     |
|                      |  DBMS_Lock.Sleep                |  Sleep for a number of seconds          |
|                      |  DBMS_Profiler.Stop_Profiling   |  Stop profiling                         |
|                      |  dprof_queries.sql              |  Query script to show results           |
----------------------------------------------------------------------------------------------------
| *dprof_queries*      |  SQL script                     |  Query script to show results           |
====================================================================================================
This file has the results query script called by both example scripts used to demonstrate profiling
via DBMS_Profiler.

***************************************************************************************************/
SET VERIFY OFF

COLUMN runid FORMAT 999990 HEADING "Run Id"
COLUMN run_date FORMAT A8 HEADING "Time"
COLUMN run_comment FORMAT A60 HEADING  "Comment"
COLUMN unit_name FORMAT A25 HEADING "Unit"
COLUMN unit_number FORMAT 999990 HEADING "Unit#"
COLUMN unit_type FORMAT A15 HEADING "Type"
COLUMN line# FORMAT 999990 HEADING "Line#"
COLUMN text FORMAT A110 HEADING "Line Text"
COLUMN calls FORMAT 9999990 HEADING "Calls"
COLUMN seconds FORMAT 999990.000 HEADING "Seconds"
COLUMN min_secs FORMAT 999990.000 HEADING "Min S"
COLUMN max_secs FORMAT 999990.000 HEADING  "Max S"
COLUMN micro_s FORMAT 99999999990 HEADING "Microsecs"
PROMPT Run header (PLSQL_PROFILER_RUNS)
SELECT runid,
       To_Char(run_date, 'hh24:mi:ss') run_date,
       Round(run_total_time/1000000000, 3) seconds,
       Round(run_total_time/1000, 0)  micro_s
  FROM plsql_profiler_runs
 WHERE runid = &RUN_ID
/
PROMPT Profiler data overall summary (PLSQL_PROFILER_DATA)
SELECT Round(Sum(dat.total_time/1000000000), 3) seconds,
       Round(Sum(dat.total_time/1000), 0)  micro_s,
       Sum(dat.total_occur) calls
  FROM plsql_profiler_data dat
 WHERE dat.runid = &RUN_ID
/
PROMPT Profiler data summary by unit (PLSQL_PROFILER_DATA, PLSQL_PROFILER_UNITS)
SELECT unt.unit_name,
       dat.unit_number,
       Round(Sum(dat.total_time/1000000000), 3) seconds,
       Round(Sum(dat.total_time/1000), 0)  micro_s,
       Sum(dat.total_occur) calls
  FROM plsql_profiler_data dat
  JOIN plsql_profiler_units unt
    ON unt.runid = dat.runid
   AND unt.unit_number = dat.unit_number
 WHERE dat.runid = &RUN_ID
 GROUP BY unt.unit_name,
          dat.unit_number
 ORDER BY 1, 2, 3
/
PROMPT Profiler data by unit and line (PLSQL_PROFILER_DATA, PLSQL_PROFILER_UNITS, ALL_SOURCE)
SELECT Round(dat.total_time/1000000000, 3) seconds,
       Round(dat.total_time/1000, 0)  micro_s,
       Round(dat.min_time/1000000000, 3) min_secs,
       Round(dat.max_time/1000000000, 3) max_secs,
       dat.total_occur calls,
       unt.unit_name,
       dat.unit_number,
       unt.unit_type,
       dat.line#,
       Trim(src.text) text
  FROM plsql_profiler_data dat
  JOIN plsql_profiler_units unt
    ON unt.runid            = dat.runid
   AND unt.unit_number      = dat.unit_number
  LEFT JOIN all_source      src
    ON src.type             != 'ANONYMOUS BLOCK'
   AND src.name             = unt.unit_name
   AND src.line             = dat.line#
   AND src.owner            = unt.unit_owner
   AND src.type             = unt.unit_type
 WHERE dat.runid            = &RUN_ID
 ORDER BY unt.unit_name, unt.unit_number, dat.line#
/
PROMPT Profiler data by time (PLSQL_PROFILER_DATA, PLSQL_PROFILER_UNITS, ALL_SOURCE)
SELECT Round(dat.total_time/1000000000, 3) seconds,
       Round(dat.total_time/1000, 0)  micro_s,
       Round(dat.min_time/1000000000, 3) min_secs,
       Round(dat.max_time/1000000000, 3) max_secs,
       dat.total_occur calls,
       unt.unit_name,
       dat.unit_number,
       unt.unit_type,
       dat.line#,
       Trim(src.text) text
  FROM plsql_profiler_data dat
  JOIN plsql_profiler_units unt
    ON unt.runid            = dat.runid
   AND unt.unit_number      = dat.unit_number
  LEFT JOIN all_source      src
    ON src.type             IN ('PACKAGE BODY','FUNCTION','PROCEDURE','TRIGGER','TYPE BODY')
   AND src.name             = unt.unit_name 
   AND src.line             = dat.line# 
   AND src.owner            = unt.unit_owner 
   AND src.type             = unt.unit_type
 WHERE dat.runid            = &RUN_ID
 ORDER BY dat.total_time DESC, dat.total_occur, unt.unit_name, dat.line#
/