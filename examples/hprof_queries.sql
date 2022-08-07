DEFINE RUN_ID=&1
/***************************************************************************************************
Name: hprof_queries.sql                 Author: Brendan Furey                      Date: 21-Jun-2020

Query script component in the PL/SQL Profiling module.

The module demonstrates the use of Oracle's two profiling utilities, DBMS_Profiler (its original 
flat profiler) and DBMS_HProf (the later hierarchical profiler), and also profiling by custom code
timing instrumentation (Timer_Set). 

    GitHub: https://github.com/BrenPatF/plsql_profiling
    Blog:   'PL/SQL Profiling Notes, 1: Overview', http://aprogrammerwrites.eu/?p=703

There are driver SQL scripts for two examples to demonstrate profiling via DBMS_HProf: One is a 
general example and the other involves calls to a system sleep procedure. Each of the three methods
of profiling demonstrated has a similar pair of driver scripts.

DRIVER SCRIPTS
====================================================================================================
|  SQL Script          |  Calls                        |  Notes                                    |
|===================================================================================================
|  hp_example_general  |  HProf_Utils.Start_Profiling  |  Start profiling with DBMS_HProf          |
|                      |  Prof_Test.A_Calls_B          |  Entry point for mutually recursive calls |
|                      |  Prof_Test.DBFunc             |  Database function called by query        |
|                      |  Table_Count_Type             |  Object type used to demonstrate PL/SQL   |
|                      |                               |  profiling                                |
|                      |  Prof_Test.R_Calls_R          |  Entry point for recursive calls          |
|                      |  HProf_Utils.Stop_Profiling   |  Stop profiling and analyse two ways      |
|                      |  hprof_queries.sql            |  Query script to show results             |
----------------------------------------------------------------------------------------------------
|  hp_example_sleep    |  HProf_Utils.Start_Profiling  |  Start profiling with DBMS_HProf          |
|                      |  DBMS_Lock.Sleep              |  Sleep for a number of seconds            |
|                      |  HProf_Utils.Stop_Profiling   |  Stop profiling and analyse two ways      |
|                      |  hprof_queries.sql            |  Query script to show results             |
----------------------------------------------------------------------------------------------------
| *hprof_queries*      |  SQL script                   |  Query script to show results             |
====================================================================================================
This file has the results query script called by both example scripts used to demonstrate profiling
via DBMS_HProf.

***************************************************************************************************/
SET VERIFY OFF
COLUMN runid FORMAT 999990 HEADING "Run Id"
COLUMN run_timestamp FORMAT A28 HEADING  "Run Time"
COLUMN run_comment FORMAT A60 HEADING  "Comment"
COLUMN seconds FORMAT 9990.000 HEADING "Seconds"
COLUMN micro_s FORMAT 9999999999990 HEADING "Microsecs"

PROMPT Run header (DBMSHP_RUNS)
SELECT runid,
	   run_timestamp,
	   total_elapsed_time micro_s,
       Round (total_elapsed_time/1000000, 2) seconds,
       run_comment
  FROM dbmshp_runs
 WHERE runid = &RUN_ID
/
COLUMN owner FORMAT A18 HEADING "Owner"
COLUMN module FORMAT A25 HEADING "Module"
COLUMN function FORMAT A35 HEADING "Function"
COLUMN line# FORMAT 9990 HEADING "Line#"
COLUMN sy FORMAT 90 HEADING "Sy"
COLUMN sub_t FORMAT 9999999999990 HEADING "Subtree MicroS"
COLUMN fun_t FORMAT 99999999999990 HEADING "Function MicroS"
COLUMN calls FORMAT 999990 HEADING "Calls"
PROMPT Functions called (DBMSHP_FUNCTION_INFO)
SELECT owner,
	     module,
       symbolid sy, 
       function,
       line#,
       subtree_elapsed_time sub_t,
       function_elapsed_time fun_t,
       calls
  FROM dbmshp_function_info
 WHERE runid = &RUN_ID
 ORDER BY 1, 2, 3
/
COLUMN owner_p FORMAT A18 HEADING "Parent:"
COLUMN module_p FORMAT A25 HEADING "Module"
COLUMN function_p FORMAT A35 HEADING "Function"
COLUMN sy_p FORMAT 90 HEADING "Sy"
COLUMN owner_c FORMAT A18 HEADING "Child:"
COLUMN module_c FORMAT A25 HEADING "Module"
COLUMN function_c FORMAT A35 HEADING "Function"
COLUMN sy_c FORMAT 90 HEADING "Sy"

PROMPT Function call parent-child links (DBMSHP_PARENT_CHILD_INFO)
SELECT fi_p.owner owner_p, fi_p.module module_p, pci.parentsymid sy_p, fi_p.function function_p,
       fi_c.owner owner_c, fi_c.module module_c, pci.childsymid sy_c, fi_c.function function_c,
       pci.subtree_elapsed_time sub_t,
       pci.function_elapsed_time fun_t,
       pci.calls
  FROM dbmshp_parent_child_info    pci
  JOIN dbmshp_function_info		   fi_p
    ON fi_p.runid                  = pci.runid	
   AND fi_p.symbolid	           = pci.parentsymid
  JOIN dbmshp_function_info		   fi_c
    ON fi_c.runid                  = pci.runid	
   AND fi_c.symbolid	           = pci.childsymid
 WHERE pci.runid = (SELECT Max(runid) FROM dbmshp_runs)
ORDER BY 1, 2
/
COLUMN ftree FORMAT A60 HEADING "Function tree" 
COLUMN "Inst." FORMAT A6
COLUMN "Row" FORMAT 90
PROMPT BPF Recursive Subquery Factor Tree Query
WITH pci_sums (childsymid, subtree_elapsed_time, function_elapsed_time, calls) AS (
    SELECT childsymid, Sum(subtree_elapsed_time), 
                       Sum(function_elapsed_time), 
                       Sum(calls)
      FROM dbmshp_parent_child_info pci
     WHERE runid = &RUN_ID
     GROUP BY childsymid
), full_tree (runid, lev, node_id, sub_t, fun_t, calls, link_id) AS (
    SELECT fni.runid, 0, fni.symbolid,
           fni.subtree_elapsed_time - Nvl(psm.subtree_elapsed_time, 0),
           fni.function_elapsed_time - Nvl(psm.function_elapsed_time, 0),
           fni.calls - Nvl(psm.calls, 0), 'root' || ROWNUM
      FROM dbmshp_function_info fni
      LEFT JOIN pci_sums psm
        ON psm.childsymid = fni.symbolid
     WHERE fni.runid = &RUN_ID
       AND fni.calls - Nvl(psm.calls, 0) > 0
     UNION ALL
    SELECT ftr.runid, 
           ftr.lev + 1, 
           pci.childsymid, 
           pci.subtree_elapsed_time, 
           pci.function_elapsed_time, 
           pci.calls,
           pci.parentsymid || '-' || pci.childsymid
      FROM full_tree ftr
      JOIN dbmshp_parent_child_info pci
        ON pci.parentsymid = ftr.node_id
       AND pci.runid = ftr.runid
) SEARCH DEPTH FIRST BY sub_t DESC, fun_t DESC, calls DESC, node_id SET rn
, tree_ranked AS (
    SELECT runid, node_id, lev, rn, 
           sub_t, fun_t, calls, 
           Row_Number () OVER (PARTITION BY node_id ORDER BY rn) node_rn,
           Count (*) OVER (PARTITION BY node_id) node_cnt,
           Row_Number () OVER (PARTITION BY link_id ORDER BY rn) link_rn
      FROM full_tree
)
SELECT RPad (' ', trr.lev*2, ' ') || fni.function ftree,
       fni.symbolid sy, fni.owner, fni.module,
       CASE WHEN trr.node_cnt > 1 THEN trr.node_rn || ' of ' || trr.node_cnt END "Inst.",
       trr.sub_t, trr.fun_t, trr.calls, 
       trr.rn "Row"
  FROM tree_ranked trr
  JOIN dbmshp_function_info fni
    ON fni.symbolid = trr.node_id
   AND fni.runid = trr.runid
 WHERE trr.link_rn = 1
 ORDER BY trr.rn
/