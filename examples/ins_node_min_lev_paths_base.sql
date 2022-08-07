DEFINE SUB=&1
DEFINE ROOT=&2
SET TIMING ON
VAR n_roots number
@..\..\initspool ins_node_min_lev_paths_base_&SUB._&ROOT
EXEC :n_roots := Shortest_Path_SQL_Base.Pop_Node_Min_Lev_Paths(&ROOT);
COLUMN path FORMAT A85
COLUMN node_name FORMAT A35
BREAK ON lev
SELECT mlp.lev, nod.node_name, mlp.path
  FROM node_min_lev_paths mlp
  JOIN nodes nod ON nod.id = mlp.node_id
 ORDER BY 1, 3
/
SET TIMING OFF
@..\..\endspool
