@..\..\..\install\install_shortest_path_sql
SET TIMING ON
PROMPT VIEW links_load_v
CREATE OR REPLACE VIEW links_load_v(node_name_fr, node_name_to) AS
SELECT table_fr,
       table_to
  FROM fk_links
/
PROMPT VIEW nodes_load_v
CREATE OR REPLACE VIEW nodes_load_v(node_name) AS
SELECT node_name_fr
  FROM links_load_v
 UNION
SELECT node_name_to
  FROM links_load_v
/
@..\..\setup_shortest_path_sql
@..\..\setup_shortest_path_sql_links_v
SET TIMING OFF
