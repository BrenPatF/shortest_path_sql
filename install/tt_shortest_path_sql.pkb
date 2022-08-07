CREATE OR REPLACE PACKAGE BODY TT_Shortest_Path_SQL AS
/***************************************************************************************************
Name: tt_shortest_path_sql.pkb         Author: Brendan Furey                       Date: 07-Aug-2022

Package body component in the shortest_path_sql module. Unit testing the Shortest_Path_SQL package.

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
|  Shortest_Path_SQL_Base_TS  | Base Shortest Path package without tuning but with code timing     |
|--------------------------------------------------------------------------------------------------|
| *TT_Shortest_Path_SQL*      | Unit testing the Shortest_Path_SQL package                         | 
====================================================================================================

This file has the TT_Shortest_Path_SQL package body

***************************************************************************************************/

/***************************************************************************************************

add_A_Node: Local helper function to add a node

***************************************************************************************************/
FUNCTION add_A_Node(
            p_node_name                    VARCHAR2)      -- node name
            RETURN                         PLS_INTEGER IS -- node id

  l_id        PLS_INTEGER;
BEGIN

  SELECT id 
    INTO l_id
    FROM nodes 
   WHERE node_name = p_node_name;

  RETURN l_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    INSERT INTO nodes (node_name)
    VALUES (p_node_name)
    RETURNING id INTO l_id;

    RETURN l_id;

END add_A_Node;

/***************************************************************************************************

add_Links: Local helper procedure to add nodes

***************************************************************************************************/
PROCEDURE add_Nodes(
            p_node_2lis                    L2_chr_arr) IS -- list of node names

  l_id        PLS_INTEGER;
BEGIN

  FOR i IN 1..p_node_2lis.COUNT LOOP

    l_id := add_A_Node(p_node_2lis(i)(1));

  END LOOP;

END add_Nodes;

/***************************************************************************************************

add_Links: Local helper procedure to add links, starts by truncating the network model tables

***************************************************************************************************/
PROCEDURE add_Links(
            p_link_2lis                    L2_chr_arr) IS -- list of (from node, to node) name pairs

  l_id_fr       PLS_INTEGER;
  l_id_to       PLS_INTEGER;
BEGIN

  EXECUTE IMMEDIATE 'TRUNCATE TABLE links';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE nodes';
  FOR i IN 1..p_link_2lis.COUNT LOOP

    l_id_fr := add_A_Node(p_link_2lis(i)(1));
    l_id_to := add_A_Node(p_link_2lis(i)(2));
    INSERT INTO links VALUES (l_id_fr, l_id_to);

  END LOOP;
END add_Links;

/***************************************************************************************************

cursor_To_List: Call Utils Cursor_To_List function, passing an open cursor, and delimiter, and 
                return the resulting list of delimited records

***************************************************************************************************/
FUNCTION cursor_To_List(
            p_cursor_text                  VARCHAR2)     -- cursor text
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_csr             SYS_REFCURSOR;
BEGIN

  OPEN l_csr FOR p_cursor_text;
  RETURN Utils.Cursor_To_List(x_csr    => l_csr,
                              p_delim  => '|');

END cursor_To_List;

/***************************************************************************************************

Purely_Wrap_Ins_Node_Roots: Unit test wrapper function for Shortest_Path_SQL.Ins_Min_Tree_Links

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_Ins_Min_Tree_Links(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
  l_ins_tot                      PLS_INTEGER;
  l_root_id                      PLS_INTEGER;
BEGIN

  add_Links(p_link_2lis => p_inp_3lis(1));
  add_Nodes(p_node_2lis => p_inp_3lis(2));

  SELECT id
    INTO l_root_id
    FROM nodes
   WHERE node_name = p_inp_3lis(3)(1)(1);

  l_ins_tot := Shortest_Path_SQL.Ins_Min_Tree_Links(l_root_id);
  l_act_2lis.EXTEND(2);

  l_act_2lis(1) := cursor_To_List(p_cursor_text =>
     'SELECT nod.node_name, mtl.lev, nod_p.node_name FROM min_tree_links mtl' ||
     '  JOIN nodes nod ON nod.id = mtl.node_id' ||
     '  LEFT JOIN nodes nod_p ON nod_p.id = mtl.node_id_prior ORDER BY 1');

  ROLLBACK;
  RETURN l_act_2lis;

END Purely_Wrap_Ins_Min_Tree_Links;

/***************************************************************************************************

Purely_Wrap_Ins_Node_Roots: Unit test wrapper function for Shortest_Path_SQL.Ins_Node_Roots

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_Ins_Node_Roots(
              p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
              RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();

BEGIN

  add_Links(p_link_2lis => p_inp_3lis(1));
  add_Nodes(p_node_2lis => p_inp_3lis(2));
  Shortest_Path_SQL.Ins_Node_Roots(p_node_vsn   => 3,
                                   p_link_vsn   => 5,
                                   p_order_type => 3);
  l_act_2lis.EXTEND;

  l_act_2lis(1) := cursor_To_List(p_cursor_text => 
    'SELECT nod.node_name, rtn.node_name, lev' ||
    '  FROM node_roots nrt' ||
    '  JOIN nodes nod ON nod.id = nrt.node_id' ||
    '  JOIN nodes rtn ON rtn.id = nrt.root_node_id' ||
    ' ORDER BY 2, 1');

  ROLLBACK;
  RETURN l_act_2lis;

END Purely_Wrap_Ins_Node_Roots;

END TT_Shortest_Path_SQL;
/
SHO ERR
