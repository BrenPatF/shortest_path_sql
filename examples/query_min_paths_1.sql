DEFINE SUB=&1
DEFINE ROOT_NAME='&2'

SET TIMING ON
@..\..\get_root_vars

@..\..\initspool query_min_paths_1_&SUB._&root_file_var

PROMPT Root name: &ROOT_NAME, Root id: &root_id_var

COLUMN path         FORMAT A25
COLUMN node         FORMAT A30
COLUMN node_name    FORMAT A35
COLUMN lp           FORMAT A2
COLUMN lev          FORMAT 990
COLUMN maxlev       FORMAT 999990
COLUMN intnod       FORMAT 999990
COLUMN intmax       FORMAT 999990
PROMPT One recursive subqueries - XPLAN_RSF_1
WITH paths (node_id, rnk, lev) AS (
    SELECT &root_id_var, 1, 0
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to ELSE l.node_id_fr END,
            Rank () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                                          ELSE l.node_id_fr END
                          ORDER BY p.node_id),
            p.lev + 1
      FROM paths p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
     WHERE p.rnk = 1
)  SEARCH DEPTH FIRST BY node_id SET line_no
CYCLE node_id SET lp TO '*' DEFAULT ' '
, node_min_levs AS (
    SELECT node_id,
           Min (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev,
           Min (line_no) KEEP (DENSE_RANK FIRST ORDER BY lev) line_no
      FROM paths
     GROUP BY node_id
)
SELECT /*+ gather_plan_statistics XPLAN_RSF_1 */ 
       n.node_name, 
       Substr(LPad ('.', 1 + 2 * m.lev, '.') || m.node_id, 2) node, 
       m.lev lev
  FROM node_min_levs m
  JOIN nodes n
    ON n.id = m.node_id
 ORDER BY m.line_no
/
EXEC Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_RSF_1'));

SET TIMING OFF
@..\..\endspool