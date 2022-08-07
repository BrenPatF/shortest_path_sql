DEFINE SUB=&1
DEFINE ROOT_NAME='&2'
DEFINE BT=&3

SET TIMING ON
@..\..\get_root_vars

@..\..\initspool ins_tree_links_&SUB._&root_file_var._&BT

PROMPT Root name: &ROOT_NAME, Root id: &root_id_var

EXEC  Shortest_Path_SQL.Ins_Tree_links(p_root_node_id => &root_id_var, p_batch_type => &BT);

COLUMN node       FORMAT A35
COLUMN node_name  FORMAT A35
COLUMN lev        FORMAT 990

WITH paths (node_id, lev) AS (
    SELECT a.node_id_to, 1
      FROM tree_links a
    WHERE a.node_id_fr = 0
     UNION ALL
    SELECT a.node_id_to, 
            p.lev + 1
      FROM paths p
      JOIN tree_links a
        ON a.node_id_fr = p.node_id
)  SEARCH DEPTH FIRST BY node_id SET line_no
SELECT n.node_name, Substr(LPad ('.', 1 + 2 * (p.lev - 1), '.') || p.node_id, 2) node, p.lev - 1 lev
  FROM paths p
  JOIN nodes n
    ON n.id = p.node_id
  ORDER BY p.line_no
/
SET TIMING OFF
@..\..\endspool