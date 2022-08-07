DEFINE SUB=&1
@..\..\initspool ins_node_roots_hprof_&SUB
SET TIMING ON

VAR RUN_ID NUMBER
BEGIN

  HProf_Utils.Start_Profiling;
  Shortest_Path_SQL_Base.Ins_Node_Roots;

  :RUN_ID := HProf_Utils.Stop_Profiling(
    p_run_comment => 'Profile for Ins_Node_Roots',
    p_filename    => 'hp_ins_node_roots_&SUB..html');
END;
/
@..\..\hprof_queries :RUN_ID
SET TIMING OFF
@..\..\endspool
