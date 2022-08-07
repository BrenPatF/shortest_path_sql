@..\initspool install_shortest_path_sql_tt
/***************************************************************************************************
Name: install_shortest_path_sql_tt.sql Author: Brendan Furey                       Date: 07-Aug-2022

Installation script for unit test components in the shortest_path_sql module. 

    GitHub: https://github.com/BrenPatF/shortest_path_sql
    Blog:   https://brenpatf.github.io/jekyll/update/2022/08/07/shortest-path-analysis-of-large-networks-by-sql-and-plsql.html

Note that installation of this module is dependent on pre-requisite installs of other modules as
described in the README.

INSTALL SCRIPTS
====================================================================================================
|  Script                            |  Notes                                                      |
|===================================================================================================
|  install_shortest_path_sql.sql     |  Creates base components in shortest_path_sql schema        |
----------------------------------------------------------------------------------------------------
| *install_shortest_path_sql_tt.sql* |  Creates unit test components in shortest_path_sql schema   |
====================================================================================================
This file has the install script for the unit test components in shortest_path_sql schema.

Components created in shortest_path_sql schema:

    Packages                   Description
    =========================  =====================================================================
    TT_Shortest_Path_SQL       Unit testing the Shortest_Path_SQL package

    Metadata            Description
    ==================  ============================================================================
    tt_units            Record for each test packaged procedure. The input JSON files must first be
                        placed in the OS folder pointed to by INPUT_DIR directory

***************************************************************************************************/
PROMPT Create package TT_Shortest_Path_SQL
@..\install\tt_shortest_path_sql.pks
@..\install\tt_shortest_path_sql.pkb

PROMPT Add the tt_units record, reading in JSON file from INPUT_DIR
BEGIN

  Trapit.Add_Ttu(
            p_unit_test_package_nm         => 'TT_SHORTEST_PATH_SQL',
            p_purely_wrap_api_function_nm  => 'Purely_Wrap_Ins_Min_Tree_Links', 
            p_group_nm                     => 'SHORTEST_PATH_SQL',
            p_active_yn                    => 'Y', 
            p_input_file                   => 'tt_shortest_path_sql.purely_wrap_ins_min_tree_links_inp.json');

  Trapit.Add_Ttu(
            p_unit_test_package_nm         => 'TT_SHORTEST_PATH_SQL',
            p_purely_wrap_api_function_nm  => 'Purely_Wrap_Ins_Node_Roots', 
            p_group_nm                     => 'SHORTEST_PATH_SQL',
            p_active_yn                    => 'Y', 
            p_input_file                   => 'tt_shortest_path_sql.purely_wrap_ins_node_roots_inp.json');

  END;
/
@..\endspool