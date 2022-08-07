DEFINE SUB=&1
DEFINE ROOT_NAME='&2'

SET TIMING ON
@..\..\get_root_vars

@..\..\initspool ins_tree_links_dprof_&SUB._&root_file_var

VAR n_roots NUMBER
VAR RUN_ID NUMBER
DECLARE
  l_result           PLS_INTEGER;
BEGIN

  l_result := DBMS_Profiler.Start_Profiler(
          run_comment => 'Profile for Ins_Tree_links',
          run_number  => :RUN_ID);
  :n_roots := Shortest_Path_SQL_Base.Ins_Min_Tree_Links(&root_id_var);

  l_result := DBMS_Profiler.Stop_Profiler;
END;
/
@..\..\dprof_queries :RUN_ID

COLUMN node       FORMAT A35
COLUMN node_name  FORMAT A35
COLUMN lev        FORMAT 990
PROMPT Minimum Path Tree
WITH paths (node_id, lev) AS (
    SELECT &root_id_var, 0
      FROM DUAL
     UNION ALL
    SELECT mtl.node_id, 
           pth.lev + 1
      FROM paths pth
      JOIN min_tree_links mtl
        ON mtl.node_id_prior = pth.node_id
)  SEARCH DEPTH FIRST BY node_id SET line_no
SELECT n.node_name, Substr(LPad ('.', 1 + 2 * p.lev, '.') || p.node_id, 2) node, p.lev lev
  FROM paths p
  JOIN nodes n
    ON n.id = p.node_id
  ORDER BY p.line_no
/
SET TIMING OFF
@..\..\endspool