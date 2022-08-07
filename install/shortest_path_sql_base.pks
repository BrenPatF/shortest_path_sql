CREATE OR REPLACE PACKAGE Shortest_Path_SQL_Base AS
/***************************************************************************************************
Name: shortest_path_sql_base.pks       Author: Brendan Furey                       Date: 07-Aug-2022

Package body component in the shortest_path_sql module. Base Shortest Path package without tuning or
code timing.

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
| *Shortest_Path_SQL_Base*    | Base Shortest Path package without tuning or code timing           |
|--------------------------------------------------------------------------------------------------|
|  Shortest_Path_SQL_Base_TS  | Base Shortest Path package without tuning but with code timing     |
|--------------------------------------------------------------------------------------------------|
|  TT_Shortest_Path_SQL       | Unit testing the Shortest_Path_SQL package                         | 
====================================================================================================

This file has the Shortest_Path_SQL_Base package spec

***************************************************************************************************/
FUNCTION Ins_Min_Tree_Links(
	        p_root_node_id                 PLS_INTEGER)
	        RETURN                         PLS_INTEGER;
PROCEDURE Ins_Node_Roots;
PROCEDURE Ins_All_Min_Path_Links(
            p_root_node_id                 PLS_INTEGER);

END Shortest_Path_SQL_Base;
/
SHO ERR
