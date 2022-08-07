CREATE OR REPLACE PACKAGE BODY Shortest_Path_SQL_Base_TS AS
/***************************************************************************************************
Name: shortest_path_sql_base_ts.pkb    Author: Brendan Furey                       Date: 07-Aug-2022

Package body component in the shortest_path_sql module. Base Shortest Path package without tuning
but with code timing.

    GitHub: https://github.com/BrenPatF/shortest_path_sql
    Blog:   https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html

PACKAGES
====================================================================================================
|  Package                    | Notes                                                              |
|==================================================================================================|
|  SPS_Pre_Inserts            | Insertion of isolated nodes and links, with various tuning options |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL          | Main Shortest Path package with code timing and tuning options via |
|                             | parameters                                                         |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL_Base     | Base Shortest Path package without tuning or code timing           |
|--------------------------------------------------------------------------------------------------|
| *Shortest_Path_SQL_Base_TS* | Base Shortest Path package without tuning but with code timing     |
|--------------------------------------------------------------------------------------------------|
|  TT_Shortest_Path_SQL       | Unit testing the Shortest_Path_SQL package                         | 
====================================================================================================

This file has the Shortest_Path_SQL_Base_TS package body

***************************************************************************************************/

/***************************************************************************************************

Ins_Min_Tree_Links: Implements Min Pathfinder algorithm to populate min_tree_links table. This
                    version includes code timing

***************************************************************************************************/
FUNCTION Ins_Min_Tree_Links(
            p_root_node_id                 PLS_INTEGER)   -- root node id
            RETURN                         PLS_INTEGER IS -- #nodes inserted

  l_lev         PLS_INTEGER := 0;
  l_ins         PLS_INTEGER;
  l_ins_tot     PLS_INTEGER := 0;
  l_ts_id       PLS_INTEGER := Timer_Set.Construct('Ins_Min_Tree_Links: ' || p_root_node_id);
BEGIN
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
    Timer_Set.Increment_Time(l_ts_id, 'Level: ' || l_lev || ', nodes: ' || l_ins);
    EXIT WHEN l_ins = 0;
    l_lev := l_lev + 1;

  END LOOP;
  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_MTL'));
  Utils.W(Timer_Set.Format_Results(l_ts_id));
  RETURN l_ins_tot;

END Ins_Min_Tree_Links;

/***************************************************************************************************

Ins_Min_Tree_Links: Implements Min Pathfinder algorithm to populate min_tree_links table. This
                    version excludes code timing

***************************************************************************************************/
FUNCTION Ins_Min_Tree_Links_No_TS(
            p_root_node_id                 PLS_INTEGER)   -- root node id
            RETURN                         PLS_INTEGER IS -- #nodes inserted

  l_lev         PLS_INTEGER := 0;
  l_ins         PLS_INTEGER;
  l_ins_tot     PLS_INTEGER := 0;
BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE min_tree_links';
  INSERT INTO min_tree_links VALUES (p_root_node_id, '', 0);
  LOOP

    INSERT INTO min_tree_links
    SELECT CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to 
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
    EXIT WHEN l_ins = 0;
    l_lev := l_lev + 1;

  END LOOP;
  RETURN l_ins_tot;

END Ins_Min_Tree_Links_No_TS;

/***************************************************************************************************

Ins_Min_Tree_Links: Implements Min Pathfinder algorithm to populate min_tree_links table. This
                    version gets all shortest paths, and includes code timing

***************************************************************************************************/
PROCEDURE Ins_All_Min_Path_Links(
            p_root_node_id                 PLS_INTEGER) IS -- root node id

  l_lev         PLS_INTEGER := 0;
  l_ins         PLS_INTEGER;
  l_ins_tot     PLS_INTEGER := 0;
BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE min_tree_links';
  INSERT INTO min_tree_links VALUES (p_root_node_id, '', 0);
  LOOP

    INSERT INTO min_tree_links
    SELECT CASE WHEN lnk.node_id_fr = mlp_cur.node_id THEN lnk.node_id_to ELSE lnk.node_id_fr END,
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
    EXIT WHEN l_ins = 0;
    l_lev := l_lev + 1;

  END LOOP;

END Ins_All_Min_Path_Links;

/***************************************************************************************************

Ins_Node_Roots: Implements Subnetwork Grouper algorithm to populate node_roots table. This
                    version includes code timing

***************************************************************************************************/
PROCEDURE Ins_Node_Roots IS
  l_root_id           PLS_INTEGER;
  l_ins_tot           PLS_INTEGER;
  l_ts_id             PLS_INTEGER := Timer_Set.Construct('Ins_Node_Roots');
  l_suffix            VARCHAR2(60);

BEGIN

  EXECUTE IMMEDIATE 'TRUNCATE TABLE node_roots';
  LOOP

    BEGIN
      SELECT id INTO l_root_id FROM nodes WHERE id NOT IN (SELECT node_id FROM node_roots) AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN 
        l_root_id := NULL;
    END;

    Timer_Set.Increment_Time(l_ts_id, 'SELECT id INTO l_root_id');
    EXIT WHEN l_root_id IS NULL;
    l_ins_tot := Ins_Min_Tree_Links_No_TS(l_root_id);

    l_suffix := CASE WHEN l_ins_tot = 0  THEN '(1 node)'
                     WHEN l_ins_tot = 1  THEN '(2 nodes)'
                     WHEN l_ins_tot = 2  THEN '(3 nodes)'
                     WHEN l_ins_tot < 40 THEN '(4-39 nodes)'
                     ELSE                     '(root node ' || l_root_id || ', size: ' || (l_ins_tot + 1) || ')'
                END;
    Timer_Set.Increment_Time(l_ts_id, 'Insert min_tree_links ' || l_suffix);

    INSERT INTO node_roots tgt
    SELECT node_id, l_root_id, lev FROM min_tree_links;
    Timer_Set.Increment_Time(l_ts_id, 'Insert node_roots ' || l_suffix);

  END LOOP;
  Utils.W(Timer_Set.Format_Results(l_ts_id));

END Ins_Node_Roots;

END Shortest_Path_SQL_Base_TS;
/
SHO ERR
