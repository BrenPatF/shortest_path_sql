@..\..\initspool setup_brightkite
@..\..\..\install\install_shortest_path_sql
SET TIMING ON
DROP TABLE links_brightkite_ext
/
CREATE TABLE links_brightkite_ext (
        src              NUMBER,
        dst              NUMBER
)
ORGANIZATION EXTERNAL (
  TYPE          oracle_loader
  DEFAULT DIRECTORY input_dir
  ACCESS PARAMETERS
  (
    FIELDS TERMINATED BY ','
    MISSING FIELD VALUES ARE NULL
  )
  LOCATION ('Brightkite_edges.csv')
)
/
PROMPT Count links on file
SELECT COUNT(*)
 FROM links_brightkite_ext
/
PROMPT VIEW links_load_v with from node < to node to avoid inclusion of reverse links
CREATE OR REPLACE VIEW links_load_v(node_name_fr, node_name_to) AS
SELECT src,
       dst
  FROM links_brightkite_ext
 WHERE src < dst
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
@..\..\endspool