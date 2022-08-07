DEFINE TP='&1'
@..\..\..\install\install_shortest_path_sql
SET TIMING ON
PROMPT Create bacon_&TP. tables...
DROP TABLE bacon_&TP._ext
/
CREATE TABLE bacon_&TP._ext (
        actor       VARCHAR2(300),
        film        VARCHAR2(300)
)
ORGANIZATION EXTERNAL (
  TYPE          oracle_loader
  DEFAULT       DIRECTORY input_dir
  ACCESS PARAMETERS
  (
    RECORDS DELIMITED BY NEWLINE
    READSIZE 120000000
    FIELDS TERMINATED BY '|'
    MISSING FIELD VALUES ARE NULL
  )
  LOCATION ('imdb.&TP..txt')
)
/
PROMPT VIEW links_load_v
CREATE OR REPLACE VIEW links_load_v(node_name_fr, node_name_to) AS
SELECT src.actor, 
       dst.actor
FROM bacon_&TP._ext src
JOIN bacon_&TP._ext dst
  ON dst.film = src.film AND dst.actor > src.actor
/
PROMPT VIEW nodes_load_v
CREATE OR REPLACE VIEW nodes_load_v(node_name) AS
SELECT DISTINCT actor
FROM bacon_&TP._ext 
/
@..\..\setup_shortest_path_sql
SET TIMING OFF
