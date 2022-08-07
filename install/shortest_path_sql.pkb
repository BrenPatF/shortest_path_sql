CREATE OR REPLACE PACKAGE BODY Shortest_Path_SQL AS
/***************************************************************************************************
Name: shortest_path_sql.pkb            Author: Brendan Furey                       Date: 07-Aug-2022

Package body component in the shortest_path_sql module. Main Shortest Path package with code timing
and tuning options via parameters.

    GitHub: https://github.com/BrenPatF/shortest_path_sql
    Blog:   https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html

PACKAGES
====================================================================================================
|  Package                    | Notes                                                              |
|==================================================================================================|
|  SPS_Pre_Inserts            | Insertion of isolated nodes and links, with various tuning options |
|--------------------------------------------------------------------------------------------------|
| *Shortest_Path_SQL*         | Main Shortest Path package with code timing and tuning options via |
|                             | parameters                                                         |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL_Base     | Base Shortest Path package without tuning or code timing           |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL_Base_TS  | Base Shortest Path package without tuning but with code timing     |
|--------------------------------------------------------------------------------------------------|
|  TT_Shortest_Path_SQL       | Unit testing the Shortest_Path_SQL package                         | 
====================================================================================================

This file has the Shortest_Path_SQL package body

***************************************************************************************************/

/***************************************************************************************************

Clear_Log, Write_Log: Local logging procedures, not used currently, but may help debugging

***************************************************************************************************/
PROCEDURE Clear_Log IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  DELETE log_lines;
  COMMIT;

END Clear_Log;

PROCEDURE Write_Log (p_text VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  INSERT INTO log_lines (
        text,
        creation_date
  ) VALUES (
        p_text,
        SYSTIMESTAMP);
  COMMIT;

END Write_Log;

/***************************************************************************************************

Ins_Min_Tree_Links: Implements Min Pathfinder algorithm to populate min_tree_links table. This
                    version includes code timing

***************************************************************************************************/
FUNCTION Ins_Min_Tree_Links(
            p_root_node_id                 PLS_INTEGER,      -- root node id
            p_time_levs                    BOOLEAN := FALSE) -- if TRUE do code timing
            RETURN                         PLS_INTEGER IS    -- #nodes inserted

  l_lev         PLS_INTEGER := 0;
  l_ins         PLS_INTEGER;
  l_ins_tot     PLS_INTEGER := 0;
  l_ts_id       PLS_INTEGER;
BEGIN
  IF p_time_levs THEN
    l_ts_id := Timer_Set.Construct('Ins_Min_Tree_Links: ' || p_root_node_id);
  END IF;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE min_tree_links';
  INSERT INTO min_tree_links VALUES (p_root_node_id, '', 0);
  LOOP

    INSERT INTO min_tree_links
    SELECT /*+ gather_plan_statistics XPLAN_MTL */ 
           CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to 
                                                      ELSE lnk.node_id_fr END,
           Min (mlp_cur.node_id),
           l_lev + 1
      FROM min_tree_links mlp_cur
      JOIN links lnk
        ON (lnk.node_id_fr = mlp_cur.node_id OR lnk.node_id_to = mlp_cur.node_id)
      LEFT JOIN min_tree_links mlp_pri
        ON mlp_pri.node_id = CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to 
                                                                        ELSE lnk.node_id_fr END
     WHERE mlp_pri.node_id IS NULL
       AND mlp_cur.lev = l_lev
     GROUP BY CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to 
                                                         ELSE lnk.node_id_fr END;
    l_ins := SQL%ROWCOUNT;
    COMMIT;
    l_ins_tot := l_ins_tot + l_ins;
    IF p_time_levs THEN
      Timer_Set.Increment_Time(l_ts_id, 'Level: ' || l_lev || ', nodes: ' || l_ins);
    END IF;
    EXIT WHEN l_ins = 0;
    l_lev := l_lev + 1;

  END LOOP;
  IF p_time_levs THEN
    Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_MTL'));
    Utils.W(Timer_Set.Format_Results(l_ts_id));
  END IF;
  RETURN l_ins_tot;

END Ins_Min_Tree_Links;

/***************************************************************************************************

Ins_Min_Tree_Links: Implements Min Pathfinder algorithm to populate min_tree_links table. This
                    version gets all shortest paths, and includes code timing

***************************************************************************************************/
PROCEDURE Ins_All_Min_Path_Links(
            p_root_node_id                 PLS_INTEGER) IS -- root node id

  l_lev         PLS_INTEGER := 0;
  l_ins         PLS_INTEGER;
  l_ins_tot     PLS_INTEGER := 0;
  l_ts_id       PLS_INTEGER;
BEGIN
  l_ts_id := Timer_Set.Construct('Ins_Min_Tree_Links: ' || p_root_node_id);
  EXECUTE IMMEDIATE 'TRUNCATE TABLE min_tree_links';
  INSERT INTO min_tree_links VALUES (p_root_node_id, '', 0);
  LOOP

    INSERT INTO min_tree_links
    SELECT /*+ gather_plan_statistics XPLAN_AMPL */ 
           CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to ELSE lnk.node_id_fr END,
           mlp_cur.node_id,
           l_lev + 1
      FROM min_tree_links mlp_cur
      JOIN links lnk
        ON (lnk.node_id_fr = mlp_cur.node_id OR lnk.node_id_to = mlp_cur.node_id)
      LEFT JOIN min_tree_links mlp_pri
        ON mlp_pri.node_id = CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to ELSE lnk.node_id_fr END
     WHERE mlp_pri.node_id IS NULL
       AND mlp_cur.lev = l_lev
     GROUP BY CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to ELSE lnk.node_id_fr END,
              mlp_cur.node_id;
    l_ins := SQL%ROWCOUNT;
    COMMIT;
    l_ins_tot := l_ins_tot + l_ins;
    Timer_Set.Increment_Time(l_ts_id, 'Level: ' || l_lev || ', nodes: ' || l_ins);
    EXIT WHEN l_ins = 0;
    l_lev := l_lev + 1;

  END LOOP;
  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_AMPL'));
  Utils.W(Timer_Set.Format_Results(l_ts_id));

END Ins_All_Min_Path_Links;

/***************************************************************************************************

Ins_Node_Roots: Implements Subnetwork Grouper algorithm to populate node_roots table. This
                    version has 3 parameters to test tuning options, and includes code timing

***************************************************************************************************/
PROCEDURE Ins_Node_Roots(
            p_node_vsn                     PLS_INTEGER := 1,    -- version to call for nodes
            p_link_vsn                     PLS_INTEGER := 1,    -- version to call for links
            p_order_type                   PLS_INTEGER := 1) IS -- type of root ordering
--
-- p_node_vsn:   0   - No pre-insert
--               1   - Pre-insert isolated nodes, unhinted
--               2-4 - Pre-insert isolated nodes, hinted
--
-- p_link_vsn:   0 - No pre-insert
--               1 - Pre-insert isolated links, Not Exists / Or
--               2 - Pre-insert isolated links, Four Not Exists Subqueries
--               3 - Pre-insert isolated links, Four Outer Joins
--               4 - Pre-insert isolated links, Four Outer Joins with 3 Nested Loop Hints
--               5 - Pre-insert isolated links, Group Counting
--
-- p_order_type: 0 - No root ordering
--               1 - Select minimum node from unused nodes each iteration
--               2 - Select first ranked node from subquery ordering unused nodes
--               3 - Outer cursor ordering all nodes, check unused each iteration
--
  l_root_id           PLS_INTEGER;
  l_ts_id             PLS_INTEGER := Timer_Set.Construct('Ins_Node_Roots');
  l_ins_tot           PLS_INTEGER;
  l_ins_tot_sum       PLS_INTEGER;
  l_n_nodes           PLS_INTEGER;
  l_timer_name_1      VARCHAR2(100);
  l_timer_name_2      VARCHAR2(100);
  l_suffix            VARCHAR2(60);
  l_fetch_suffix      VARCHAR2(30) := ' (first)';
  l_dummy             PLS_INTEGER;
  CURSOR c_roots IS
  SELECT id FROM nodes ORDER BY 1;

BEGIN
  Utils.W('Ins_Node_Roots: p_node_vsn = ' || p_node_vsn || 'p_link_vsn = ' || p_link_vsn || ', p_order_type = ' || p_order_type);
  Clear_Log;
  l_ins_tot_sum := SPS_Pre_Inserts.Ins_Isolated_Nodes_Links(p_node_vsn => p_node_vsn, 
                                                            p_link_vsn => p_link_vsn, 
                                                            p_ts_id    => l_ts_id);

  IF p_order_type = 3 THEN
    OPEN c_roots;
    Timer_Set.Increment_Time(l_ts_id, 'OPEN c_roots');
    SELECT COUNT(*) INTO l_n_nodes FROM nodes;
    Timer_Set.Increment_Time(l_ts_id, 'Count nodes');
  END IF;

  LOOP

    IF p_order_type = 0 THEN
      BEGIN
        SELECT id INTO l_root_id FROM nodes WHERE id NOT IN (SELECT node_id FROM node_roots) AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN 
          l_root_id := NULL;
      END;
    ELSIF p_order_type = 1 THEN
      SELECT Min(id) INTO l_root_id FROM nodes WHERE id NOT IN (SELECT node_id FROM node_roots);
    ELSIF p_order_type = 2 THEN
      BEGIN
        SELECT id INTO l_root_id FROM (SELECT id FROM nodes WHERE id NOT IN (SELECT node_id FROM node_roots) ORDER BY 1) WHERE ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN 
          l_root_id := NULL;
      END;
    ELSIF p_order_type = 3 THEN
      FETCH c_roots INTO l_root_id;
      Timer_Set.Increment_Time(l_ts_id, 'FETCH c_roots ' || l_fetch_suffix);
      l_fetch_suffix := ' (remaining)';
      IF c_roots%NOTFOUND THEN
        l_root_id := NULL;
        Utils.W('No more root nodes to fetch, processed: ' || l_ins_tot_sum || '/' || l_n_nodes);
      ELSE
        BEGIN
          SELECT 1 INTO l_dummy 
            FROM node_roots 
           WHERE node_id = l_root_id;
          Timer_Set.Increment_Time(l_ts_id, 'SELECT 1 INTO l_dummy: Found');
          CONTINUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            Timer_Set.Increment_Time(l_ts_id, 'SELECT 1 INTO l_dummy: Not found');
        END;
      END IF;
    END IF;
    IF p_order_type != 3 THEN
      Timer_Set.Increment_Time(l_ts_id, 'SELECT id INTO l_root_id');
    END IF;
    EXIT WHEN l_root_id IS NULL;
    l_ins_tot := Ins_Min_Tree_Links(l_root_id);
    l_ins_tot_sum := l_ins_tot_sum + l_ins_tot + 1;

    l_suffix := CASE WHEN l_ins_tot = 0  THEN '(1 node)'
                     WHEN l_ins_tot = 1  THEN '(2 nodes)'
                     WHEN l_ins_tot = 2  THEN '(3 nodes)'
                     WHEN l_ins_tot < 40 THEN '(4-39 nodes)'
                     ELSE                     '(root node ' || l_root_id || ', size: ' || (l_ins_tot + 1) || ')'
                END;
    l_timer_name_1 := 'Insert min_tree_links ' || l_suffix;
    l_timer_name_2 := 'Insert node_roots ' || l_suffix;
    Timer_Set.Increment_Time(l_ts_id, l_timer_name_1);
    INSERT INTO node_roots tgt
    SELECT node_id, l_root_id, lev FROM min_tree_links;
    Timer_Set.Increment_Time(l_ts_id, l_timer_name_2);

    IF l_n_nodes = l_ins_tot_sum THEN
      Utils.W('Terminating loop with all nodes processed: ' || l_n_nodes);
      EXIT;
    END IF;

  END LOOP;
  IF p_order_type = 3 THEN
    CLOSE c_roots;
  END IF;

  Utils.W(Timer_Set.Format_Results(l_ts_id));

END Ins_Node_Roots;

END Shortest_Path_SQL;
/
SHO ERR
