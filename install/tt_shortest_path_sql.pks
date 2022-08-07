CREATE OR REPLACE PACKAGE TT_Shortest_Path_SQL AS
/***************************************************************************************************
Name: tt_shortest_path_sql.pks         Author: Brendan Furey                       Date: 07-Aug-2022

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

This file has the TT_Shortest_Path_SQL package spec

***************************************************************************************************/
FUNCTION Purely_Wrap_Ins_Min_Tree_Links(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;

FUNCTION Purely_Wrap_Ins_Node_Roots(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;

END TT_Shortest_Path_SQL;
/
