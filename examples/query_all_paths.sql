DEFINE SUB=&1
DEFINE ROOT_NAME='&2'

SET TIMING ON
@..\..\get_root_vars

@..\..\initspool query_all_paths_&SUB._&root_file_var

PROMPT Root name: &ROOT_NAME, Root id: &root_id_var

COLUMN node_name FORMAT A35
COLUMN node FORMAT A35
COLUMN lev FORMAT 990
SET LINES 180
PROMPT All paths
WITH paths (node_id, lev) AS (
    SELECT &root_id_var, 0
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN lnk.node_id_fr = pth.node_id THEN lnk.node_id_to 
                                                  ELSE lnk.node_id_fr END,
           pth.lev + 1
      FROM paths pth
      JOIN links lnk
        ON pth.node_id IN (lnk.node_id_fr, lnk.node_id_to)
)  SEARCH DEPTH FIRST BY node_id SET line_no
CYCLE node_id SET cycle TO '*' DEFAULT ' '
SELECT /*+ gather_plan_statistics XPLAN_ALL_PATHS */ 
       n.node_name, 
       Substr(LPad ('.', 1 + 2 * p.lev, '.') || p.node_id, 2) node,
       p.lev
  FROM paths p
  JOIN nodes n
    ON n.id = p.node_id
 WHERE cycle = ' '
  ORDER BY p.line_no
/
EXEC Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_ALL_PATHS'));
SET TIMING OFF
@..\..\endspool
