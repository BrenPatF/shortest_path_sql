DEFINE SUB=&1
@..\..\initspool ins_node_roots_base_&SUB
COMPUTE SUM OF n_nodes ON REPORT
EXEC Shortest_Path_SQL_Base.Ins_Node_Roots;

COLUMN node         FORMAT A30
COLUMN lev          FORMAT 990
COLUMN path         FORMAT A100
COLUMN node         FORMAT A100
COLUMN node_name    FORMAT A50

BREAK ON n_nodes ON REPORT
SET TIMING ON
PROMPT Node count by root node
SELECT nod.root_node_id, nod_r.node_name, COUNT(*) n_nodes, MAX(nod.lev) maxlev
  FROM node_roots nod
  JOIN nodes nod_r
    ON nod_r.id = nod.root_node_id
 GROUP BY nod.root_node_id, nod_r.node_name
 ORDER BY 3
/
PROMPT Subnet count by number of nodes
WITH count_by_root AS (
    SELECT nod.root_node_id, COUNT(*) n_nodes
      FROM node_roots nod
     GROUP BY nod.root_node_id
)
SELECT n_nodes, COUNT(*) n_subnets
  FROM count_by_root
 GROUP BY n_nodes
 ORDER BY 1
/
PROMPT Subnet count by maximum level
WITH count_by_root AS (
    SELECT nod.root_node_id, MAX(nod.lev) maxlev
      FROM node_roots nod
     GROUP BY nod.root_node_id
)
SELECT maxlev, COUNT(*) n_subnets
  FROM count_by_root
 GROUP BY maxlev
 ORDER BY 1
/
SET TIMING OFF
@..\..\endspool
