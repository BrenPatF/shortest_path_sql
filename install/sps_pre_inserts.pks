CREATE OR REPLACE PACKAGE SPS_Pre_Inserts AS
/***************************************************************************************************
Name: sps_pre_inserts.pks              Author: Brendan Furey                       Date: 07-Aug-2022

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

This file has the SPS_Pre_Inserts package spec

***************************************************************************************************/

FUNCTION Ins_Isolated_Nodes_Links(
            p_node_vsn                   PLS_INTEGER := 1,
            p_link_vsn                   PLS_INTEGER := 1,
            p_ts_id                      PLS_INTEGER := NULL) RETURN PLS_INTEGER;

END SPS_Pre_Inserts;
/
SHO ERR
