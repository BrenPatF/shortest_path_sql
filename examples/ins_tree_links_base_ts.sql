DEFINE SUB=&1
DEFINE ROOT=&2
@..\..\initspool ins_tree_links_base_ts_&SUB._&ROOT
SET TIMING ON
COLUMN node       FORMAT A35
COLUMN node_name  FORMAT A35
COLUMN lev        FORMAT 990
EXEC Shortest_Path_SQL_Base_TS.Ins_Tree_links(p_root_node_id => &ROOT);

WITH paths (node_id, lev) AS (
SELECT a.node_id_to, 0
  FROM tree_links a
WHERE a.node_id_fr = 0
 UNION ALL
SELECT a.node_id_to, 
        p.lev + 1
  FROM paths p
  JOIN tree_links a
    ON a.node_id_fr = p.node_id
)  SEARCH DEPTH FIRST BY node_id SET line_no
SELECT n.node_name, Substr(LPad ('.', 1 + 2 * p.lev, '.') || p.node_id, 2) node, p.lev lev
  FROM paths p
  JOIN nodes n
    ON n.id = p.node_id
  ORDER BY p.line_no
/
SET TIMING OFF
@..\..\endspool