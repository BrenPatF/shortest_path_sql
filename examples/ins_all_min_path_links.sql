DEFINE SUB=&1
DEFINE ROOT_NAME='&2'

SET TIMING ON
@..\..\get_root_vars

@..\..\initspool ins_all_min_path_links_&SUB._&root_file_var

PROMPT Root name: &ROOT_NAME, Root id: &root_id_var

EXEC Shortest_Path_SQL.Ins_All_Min_Path_Links(&root_id_var);

COLUMN node_name FORMAT A35
COLUMN node_name_prior FORMAT A35
SET LINES 180
SELECT mlp.lev, nod.node_name, nod_p.node_name node_name_prior
  FROM min_tree_links mlp
  JOIN nodes nod ON nod.id = mlp.node_id
  LEFT JOIN nodes nod_p ON nod_p.id = mlp.node_id_prior
 ORDER BY 1, 3, 2
/
COLUMN node       FORMAT A35
COLUMN node_name  FORMAT A35
COLUMN lev        FORMAT 990
PROMPT Minimum Path Tree
WITH paths (node_id, lev) AS (
    SELECT &root_id_var, 1
      FROM DUAL
     UNION ALL
    SELECT mtl.node_id, 
           pth.lev + 1
      FROM paths pth
      JOIN min_tree_links mtl
        ON mtl.node_id_prior = pth.node_id
)  SEARCH DEPTH FIRST BY node_id SET line_no
SELECT n.node_name, Substr(LPad ('.', 1 + 2 * (p.lev - 1), '.') || p.node_id, 2) node, p.lev - 1 lev
  FROM paths p
  JOIN nodes n
    ON n.id = p.node_id
  ORDER BY p.line_no
/
SET TIMING OFF
@..\..\endspool
