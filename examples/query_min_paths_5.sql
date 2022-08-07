DEFINE SUB=&1
DEFINE ROOT_NAME='&2'

SET TIMING ON
@..\..\get_root_vars

@..\..\initspool query_min_paths_5_&SUB._&root_file_var

PROMPT Root name: &ROOT_NAME, Root id: &root_id_var

COLUMN path         FORMAT A25
COLUMN node         FORMAT A30
COLUMN node_name    FORMAT A35
COLUMN lp           FORMAT A2
COLUMN lev          FORMAT 990
COLUMN maxlev       FORMAT 999990
COLUMN intnod       FORMAT 999990
COLUMN intmax       FORMAT 999990
PROMPT Two recursive subqueries - XPLAN_RSF_2
WITH paths_1 (node_id, lev, rn) AS (
    SELECT &root_id_var, 0, 1
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to ELSE l.node_id_fr END,
           p.lev + 1,
           Row_Number () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                                               ELSE l.node_id_fr END
                               ORDER BY p.node_id)
      FROM paths_1 p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
     WHERE p.rn = 1
       AND p.lev < 1
) CYCLE node_id SET lp TO '*' DEFAULT ' '
, paths_2 (node_id, lev, rn) AS (
    SELECT &root_id_var, 0, 1
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to ELSE l.node_id_fr END,
           p.lev + 1,
           Row_Number () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                                               ELSE l.node_id_fr END
                               ORDER BY p.node_id)
      FROM paths_2 p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
      LEFT JOIN (SELECT node_id, Max (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev FROM paths_1 GROUP BY node_id) b
        ON b.node_id = CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                          ELSE l.node_id_fr END
     WHERE p.rn = 1
       AND p.lev < 2
       AND p.lev < Nvl (b.lev, 1000000)
) CYCLE node_id SET lp TO '*' DEFAULT ' '
, paths_3 (node_id, lev, rn) AS (
    SELECT &root_id_var, 0, 1
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to ELSE l.node_id_fr END,
           p.lev + 1,
           Row_Number () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                                               ELSE l.node_id_fr END
                               ORDER BY p.node_id)
      FROM paths_3 p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
      LEFT JOIN (SELECT node_id, Max (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev FROM paths_2 GROUP BY node_id) b
        ON b.node_id = CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                          ELSE l.node_id_fr END
     WHERE p.rn = 1
       AND p.lev < 3
       AND p.lev < Nvl (b.lev, 1000000)
) CYCLE node_id SET lp TO '*' DEFAULT ' '
, paths_4 (node_id, lev, rn) AS (
    SELECT &root_id_var, 0, 1
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to ELSE l.node_id_fr END,
           p.lev + 1,
           Row_Number () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                                               ELSE l.node_id_fr END
                               ORDER BY p.node_id)
      FROM paths_4 p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
      LEFT JOIN (SELECT node_id, Max (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev FROM paths_3 GROUP BY node_id) b
        ON b.node_id = CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                          ELSE l.node_id_fr END
     WHERE p.rn = 1
       AND p.lev < 4
       AND p.lev < Nvl (b.lev, 1000000)
) CYCLE node_id SET lp TO '*' DEFAULT ' '
, paths_5 (node_id, lev, rn) AS (
    SELECT &root_id_var, 0, 1
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to ELSE l.node_id_fr END,
           p.lev + 1,
           Row_Number () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                                               ELSE l.node_id_fr END
                               ORDER BY p.node_id)
      FROM paths_5 p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
      LEFT JOIN (SELECT node_id, Max (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev FROM paths_4 GROUP BY node_id) b
        ON b.node_id = CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                          ELSE l.node_id_fr END
     WHERE p.rn = 1
       AND p.lev < 5
       AND p.lev < Nvl (b.lev, 1000000)
) CYCLE node_id SET lp TO '*' DEFAULT ' '
, 
approx_best_paths AS (
    SELECT node_id,
           Max (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev
      FROM paths_5
     GROUP BY node_id
), paths (node_id, lev, rn) AS (
    SELECT &root_id_var, 0, 1
      FROM DUAL
     UNION ALL
    SELECT CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                              ELSE l.node_id_fr END,
           p.lev + 1,
           Row_Number () OVER (PARTITION BY CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to
                                                                               ELSE l.node_id_fr END
                               ORDER BY p.node_id)
      FROM paths p
      JOIN links l
        ON p.node_id IN (l.node_id_fr, l.node_id_to)
      LEFT JOIN approx_best_paths b
        ON b.node_id = CASE WHEN l.node_id_fr = p.node_id THEN l.node_id_to 
                                                          ELSE l.node_id_fr END
     WHERE p.rn = 1
       AND p.lev < Nvl (b.lev, 1000000)
)  SEARCH DEPTH FIRST BY node_id SET line_no CYCLE node_id SET lp TO '*' DEFAULT ' '
, node_min_levs AS (
    SELECT node_id,
           Min (lev) KEEP (DENSE_RANK FIRST ORDER BY lev) lev,
           Min (line_no) KEEP (DENSE_RANK FIRST ORDER BY lev) line_no
      FROM paths
     GROUP BY node_id
)
SELECT n.node_name, 
       Substr(LPad ('.', 1 + 2 * m.lev, '.') || m.node_id, 2) node, 
       m.lev lev
  FROM node_min_levs m
  JOIN nodes n
    ON n.id = m.node_id
 ORDER BY m.line_no
/

SET TIMING OFF
@..\..\endspool