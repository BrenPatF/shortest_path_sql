DEFINE SUB=&1
@..\..\initspool ins_node_roots_dprof_&SUB
SET TIMING ON

VAR RUN_ID NUMBER
DECLARE
  l_result           PLS_INTEGER;
BEGIN

  l_result := DBMS_Profiler.Start_Profiler(
          run_comment => 'Profile for Ins_Node_Roots',
          run_number  => :RUN_ID);

  Shortest_Path_SQL_Base.Ins_Node_Roots;

  l_result := DBMS_Profiler.Stop_Profiler;
END;
/
@..\..\dprof_queries :RUN_ID
SET TIMING OFF
@..\..\endspool
