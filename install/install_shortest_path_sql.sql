/***************************************************************************************************
Name: install_shortest_path_sql.sql    Author: Brendan Furey                       Date: 07-Aug-2022

Installation script for base components in the shortest_path_sql module. 

    GitHub: https://github.com/BrenPatF/shortest_path_sql
    Blog:   https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html

Note that installation of this module is dependent on pre-requisite installs of other modules as
described in the README.

INSTALL SCRIPTS
====================================================================================================
|  Script                            |  Notes                                                      |
|===================================================================================================
| *install_shortest_path_sql.sql*    |  Creates base components in shortest_path_sql schema        |
----------------------------------------------------------------------------------------------------
|  install_shortest_path_sql_tt.sql  |  Creates unit test components in shortest_path_sql schema   |
====================================================================================================
This file has the install script for the base components in shortest_path_sql schema.

Components created in shortest_path_sql schema:

    Table               Description
    ==================  ============================================================================
    nodes               Nodes
    node_roots          Node roots
    links               Links
    min_tree_links      Minimum tree links
    log_lines           Log lines logging table
    links_v             Links table used by Net_Pipe package

    Packages                   Description
    =========================  =====================================================================
    SPS_Pre_Inserts            Insertion of isolated nodes and links, with various tuning options
    Shortest_Path_SQL          Main Shortest Path package with code timing and tuning options via parameters
    Shortest_Path_SQL_Base     Base Shortest Path package without tuning or code timing
    Shortest_Path_SQL_Base_TS  Base Shortest Path package without tuning but with code timing

***************************************************************************************************/
PROMPT Drop links table
DROP TABLE links
/
PROMPT Create nodes table
DROP TABLE nodes
/
CREATE TABLE nodes(
  id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  node_name       VARCHAR2(300) NOT NULL
)
/
PROMPT Create node_roots table
DROP TABLE node_roots
/
CREATE TABLE node_roots(
  node_id         NUMBER,
  root_node_id    NUMBER,
  lev             NUMBER
)
/
PROMPT Create index node_roots_n1
CREATE UNIQUE INDEX node_roots_n1 ON node_roots(node_id)
/
PROMPT Create links table
CREATE TABLE links(
  node_id_fr      NUMBER NOT NULL,
  node_id_to      NUMBER NOT NULL
)
/
PROMPT Create GTT min_tree_links
DROP TABLE min_tree_links
/
CREATE GLOBAL TEMPORARY TABLE min_tree_links (
    node_id           NUMBER NOT NULL,
    node_id_prior     NUMBER,
    lev               NUMBER NOT NULL
) ON COMMIT PRESERVE ROWS
/
PROMPT DO NOT Create index min_tree_links_u1
rem CREATE UNIQUE INDEX min_tree_links_u1 ON min_tree_links(node_id)
rem /
PROMPT Create table log_lines
DROP TABLE log_lines
/
CREATE TABLE log_lines (
        id                      NUMBER GENERATED ALWAYS AS IDENTITY,
        text                    VARCHAR2(4000),
        creation_date           TIMESTAMP
)
/
PROMPT Create links_v table
DROP TABLE links_v
/
CREATE TABLE links_v(
  link_id         VARCHAR2(15),
  node_id_fr      VARCHAR2(15) NOT NULL,
  node_id_to      VARCHAR2(15) NOT NULL
)
/
@..\..\..\install\sps_pre_inserts.pks
@..\..\..\install\sps_pre_inserts.pkb
@..\..\..\install\shortest_path_sql.pks
@..\..\..\install\shortest_path_sql.pkb
@..\..\..\install\shortest_path_sql_base.pks
@..\..\..\install\shortest_path_sql_base.pkb
@..\..\..\install\shortest_path_sql_base_ts.pks
@..\..\..\install\shortest_path_sql_base_ts.pkb
@..\..\..\install\net_pipe.pks
@..\..\..\install\net_pipe.pkb