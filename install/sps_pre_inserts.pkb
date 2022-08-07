CREATE OR REPLACE PACKAGE BODY SPS_Pre_Inserts AS
/***************************************************************************************************
Name: sps_pre_inserts.pkb              Author: Brendan Furey                       Date: 07-Aug-2022

Package body component in the shortest_path_sql module. Insertion of isolated nodes and links, with
various tuning options.

    GitHub: https://github.com/BrenPatF/shortest_path_sql
    Blog:   https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html

PACKAGES
====================================================================================================
|  Package                    | Notes                                                              |
|==================================================================================================|
| *SPS_Pre_Inserts*           | Insertion of isolated nodes and links, with various tuning options |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL          | Main Shortest Path package with code timing and tuning options via |
|                             | parameters                                                         |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL_Base     | Base Shortest Path package without tuning or code timing           |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL_Base_TS  | Base Shortest Path package without tuning but with code timing     |
|--------------------------------------------------------------------------------------------------|
|  TT_Shortest_Path_SQL       | Unit testing the Shortest_Path_SQL package                         | 
====================================================================================================

This file has the SPS_Pre_Inserts package body

***************************************************************************************************/

PROCEDURE Ins_Isolated_Nodes_1 IS
BEGIN

  INSERT INTO node_roots
  SELECT /*+  gather_plan_statistics XPLAN_ISO_N */
         nod.id, nod.id, 0
    FROM nodes nod
   WHERE NOT EXISTS (SELECT 1
                       FROM links lnk
                      WHERE lnk.node_id_fr = nod.id OR lnk.node_id_to = nod.id);

END Ins_Isolated_Nodes_1;

PROCEDURE Ins_Isolated_Nodes_2 IS
BEGIN

  INSERT INTO node_roots
  SELECT /*+  gather_plan_statistics XPLAN_ISO_N */
         nod.id, nod.id, 0
    FROM nodes nod
    LEFT JOIN links lnk_f
      ON lnk_f.node_id_fr = nod.id
    LEFT JOIN links lnk_t
      ON lnk_t.node_id_to = nod.id
   WHERE lnk_f.node_id_fr IS NULL
     AND lnk_t.node_id_to IS NULL;

END Ins_Isolated_Nodes_2;

PROCEDURE Ins_Isolated_Nodes_3 IS
BEGIN

  INSERT INTO node_roots
  SELECT /*+  gather_plan_statistics XPLAN_ISO_N USE_NL (lnk_f) USE_NL (lnk_t) */
         nod.id, nod.id, 0
    FROM nodes nod
    LEFT JOIN links lnk_f
      ON lnk_f.node_id_fr = nod.id
    LEFT JOIN links lnk_t
      ON lnk_t.node_id_to = nod.id
   WHERE lnk_f.node_id_fr IS NULL
     AND lnk_t.node_id_to IS NULL;

END Ins_Isolated_Nodes_3;

PROCEDURE Ins_Isolated_Nodes_4 IS
BEGIN

  INSERT INTO node_roots
  SELECT /*+  gather_plan_statistics XPLAN_ISO_N USE_NL (lnk_t) */
         nod.id, nod.id, 0
    FROM nodes nod
    LEFT JOIN links lnk_f
      ON lnk_f.node_id_fr = nod.id
    LEFT JOIN links lnk_t
      ON lnk_t.node_id_to = nod.id
   WHERE lnk_f.node_id_fr IS NULL
     AND lnk_t.node_id_to IS NULL;

END Ins_Isolated_Nodes_4;

PROCEDURE Ins_Isolated_Links_1 IS
BEGIN

  INSERT INTO node_roots
    WITH isolated_links AS (
      SELECT lnk.node_id_fr, lnk.node_id_to
        FROM links lnk
      WHERE NOT EXISTS (
                  SELECT 1
                    FROM links lnk_1
                   WHERE (lnk_1.node_id_fr = lnk.node_id_to OR 
                          lnk_1.node_id_to = lnk.node_id_fr OR 
                          lnk_1.node_id_fr = lnk.node_id_fr OR 
                          lnk_1.node_id_to = lnk.node_id_to)
                     AND lnk_1.ROWID != lnk.ROWID
            )
    )
    SELECT /*+ gather_plan_statistics XPLAN_ISO_L */ 
           node_id_fr, node_id_fr, 0
      FROM isolated_links
    UNION
    SELECT node_id_to, node_id_fr, 1
      FROM isolated_links;

END Ins_Isolated_Links_1;

PROCEDURE Ins_Isolated_Links_2 IS
BEGIN

  INSERT INTO node_roots
  WITH isolated_links AS (
    SELECT lnk.node_id_fr, lnk.node_id_to
      FROM links lnk
    WHERE NOT EXISTS (
                SELECT 1
                  FROM links lnk_1
                 WHERE lnk_1.node_id_fr = lnk.node_id_fr
                   AND lnk_1.ROWID != lnk.ROWID
          )
      AND NOT EXISTS (
                SELECT 1
                  FROM links lnk_2
                 WHERE lnk_2.node_id_to = lnk.node_id_to
                   AND lnk_2.ROWID != lnk.ROWID
          )
      AND NOT EXISTS (
                SELECT 1
                  FROM links lnk_3
                 WHERE (lnk_3.node_id_fr = lnk.node_id_to)
                   AND lnk_3.ROWID != lnk.ROWID
          )
      AND NOT EXISTS (
                SELECT 1
                  FROM links lnk_4
                 WHERE (lnk_4.node_id_to = lnk.node_id_fr)
                   AND lnk_4.ROWID != lnk.ROWID
          )
  )
  SELECT /*+ gather_plan_statistics XPLAN_ISO_L */ 
         node_id_fr, node_id_fr, 0
    FROM isolated_links
   UNION
  SELECT node_id_to, node_id_fr, 1
    FROM isolated_links;

END Ins_Isolated_Links_2;

PROCEDURE Ins_Isolated_Links_3 IS
BEGIN

  INSERT INTO node_roots
  WITH isolated_links AS (
    SELECT lnk.node_id_fr, lnk.node_id_to
      FROM links lnk
      LEFT JOIN links lnk_1
          ON (lnk_1.node_id_fr = lnk.node_id_fr AND lnk_1.ROWID != lnk.ROWID)
      LEFT JOIN links lnk_2
          ON (lnk_2.node_id_fr = lnk.node_id_to AND lnk_2.ROWID != lnk.ROWID)
      LEFT JOIN links lnk_3
          ON (lnk_3.node_id_to = lnk.node_id_fr AND lnk_3.ROWID != lnk.ROWID)
      LEFT JOIN links lnk_4
          ON (lnk_4.node_id_to = lnk.node_id_to AND lnk_4.ROWID != lnk.ROWID)
    WHERE lnk_1.node_id_fr IS NULL
      AND lnk_2.node_id_fr IS NULL
      AND lnk_3.node_id_to IS NULL
      AND lnk_4.node_id_to IS NULL
  )
  SELECT /*+ gather_plan_statistics XPLAN_ISO_L */ 
         node_id_fr, node_id_fr, 0
    FROM isolated_links
   UNION
  SELECT node_id_to, node_id_fr, 1
    FROM isolated_links;

END Ins_Isolated_Links_3;

PROCEDURE Ins_Isolated_Links_4 IS
BEGIN

  INSERT INTO node_roots
  WITH isolated_links AS (
    SELECT /*+ USE_NL (lnk_2) USE_NL (lnk_3) USE_NL (lnk_4) */
           lnk.node_id_fr, lnk.node_id_to
      FROM links lnk
      LEFT JOIN links lnk_1
          ON (lnk_1.node_id_fr = lnk.node_id_fr AND lnk_1.ROWID != lnk.ROWID)
      LEFT JOIN links lnk_2
          ON (lnk_2.node_id_fr = lnk.node_id_to AND lnk_2.ROWID != lnk.ROWID)
      LEFT JOIN links lnk_3
          ON (lnk_3.node_id_to = lnk.node_id_fr AND lnk_3.ROWID != lnk.ROWID)
      LEFT JOIN links lnk_4
          ON (lnk_4.node_id_to = lnk.node_id_to AND lnk_4.ROWID != lnk.ROWID)
    WHERE lnk_1.node_id_fr IS NULL
      AND lnk_2.node_id_fr IS NULL
      AND lnk_3.node_id_to IS NULL
      AND lnk_4.node_id_to IS NULL
  )
  SELECT /*+ gather_plan_statistics XPLAN_ISO_L */ 
         node_id_fr, node_id_fr, 0
    FROM isolated_links
   UNION
  SELECT node_id_to, node_id_fr, 1
    FROM isolated_links;

END Ins_Isolated_Links_4;

PROCEDURE Ins_Isolated_Links_5 IS
BEGIN

  INSERT INTO node_roots
  WITH all_nodes AS (
    SELECT node_id_fr node_id, 'F' tp
      FROM links
   UNION ALL
    SELECT node_id_to, 'T'
      FROM links
  ), unique_nodes AS (
    SELECT node_id, Max(tp) tp
      FROM all_nodes
     GROUP BY node_id
    HAVING COUNT(*) = 1
  ), isolated_links AS (
    SELECT lnk.node_id_fr, lnk.node_id_to
      FROM links lnk
      JOIN unique_nodes frn ON frn.node_id = lnk.node_id_fr AND frn.tp = 'F'
      JOIN unique_nodes ton ON ton.node_id = lnk.node_id_to AND ton.tp = 'T'
  )
  SELECT /*+ gather_plan_statistics XPLAN_ISO_L */ 
         node_id_fr, node_id_fr, 0
    FROM isolated_links
   UNION ALL
  SELECT node_id_to, node_id_fr, 1
    FROM isolated_links;

END Ins_Isolated_Links_5;

PROCEDURE Ins_Isolated_Links_6 IS
BEGIN

  INSERT INTO node_roots
  WITH isolated_links AS (
    SELECT lnk.node_id_fr, lnk.node_id_to
      FROM links lnk
    WHERE NOT EXISTS (
                SELECT 1
                  FROM links lnk_2
                 WHERE lnk_2.node_id_fr = lnk.node_id_fr
                   AND lnk_2.ROWID != lnk.ROWID
          )
      AND NOT EXISTS (
                SELECT 1
                  FROM links lnk_2
                 WHERE lnk_2.node_id_to = lnk.node_id_to
                   AND lnk_2.ROWID != lnk.ROWID
          )
      AND NOT EXISTS (
                SELECT 1
                  FROM links lnk_2
                 WHERE (lnk_2.node_id_fr = lnk.node_id_to OR lnk_2.node_id_to = lnk.node_id_fr)
                   AND lnk_2.ROWID != lnk.ROWID
          )
  )
  SELECT /*+ gather_plan_statistics XPLAN_ISO_L */ 
         node_id_fr, node_id_fr, 0
    FROM isolated_links
   UNION
  SELECT node_id_to, node_id_fr, 1
    FROM isolated_links;

END Ins_Isolated_Links_6;

FUNCTION Ins_Isolated_Nodes_Links(
            p_node_vsn                     PLS_INTEGER := 1,    -- version to call for nodes
            p_link_vsn                     PLS_INTEGER := 1,    -- version to call for links
            p_ts_id                        PLS_INTEGER := NULL) -- timer set id
            RETURN                         PLS_INTEGER IS
  l_ts_id             PLS_INTEGER := p_ts_id;
  l_n_nodes           PLS_INTEGER := 0;
  l_n_links           PLS_INTEGER := 0;
BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE node_roots';
  IF l_ts_id IS NULL THEN
    l_ts_id := Timer_Set.Construct('Ins_Isolated_Nodes_Links');
  END IF;

  IF p_node_vsn = 1 THEN
    Ins_Isolated_Nodes_1;
  ELSIF p_node_vsn = 2 THEN
    Ins_Isolated_Nodes_2;
  ELSIF p_node_vsn = 3 THEN
    Ins_Isolated_Nodes_3;
  ELSIF p_node_vsn = 4 THEN
    Ins_Isolated_Nodes_4;
  END IF;
  IF p_node_vsn > 0 THEN
    l_n_nodes := SQL%ROWCOUNT;
    Timer_Set.Increment_Time(l_ts_id, 'Insert isolated nodes ' || p_node_vsn || ': ' || l_n_nodes);
    Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_ISO_N'));
  END IF;

  IF p_link_vsn = 1 THEN
    Ins_Isolated_Links_1;
  ELSIF p_link_vsn = 2 THEN
    Ins_Isolated_Links_2;
  ELSIF p_link_vsn = 3 THEN
    Ins_Isolated_Links_3;
  ELSIF p_link_vsn = 4 THEN
    Ins_Isolated_Links_4;
  ELSIF p_link_vsn = 5 THEN
    Ins_Isolated_Links_5;
  ELSIF p_link_vsn = 6 THEN
    Ins_Isolated_Links_6;
  END IF;
  IF p_link_vsn > 0 THEN
    l_n_links := SQL%ROWCOUNT;
    Timer_Set.Increment_Time(l_ts_id, 'Insert isolated links ' || p_link_vsn || ': ' || l_n_links);
    Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_ISO_L'));
  END IF;
  IF p_ts_id IS NULL THEN
    Utils.W(Timer_Set.Format_Results(l_ts_id));
  END IF;
  RETURN l_n_nodes + l_n_links;
END Ins_Isolated_Nodes_Links;

END SPS_Pre_Inserts;
/
SHO ERR
