@..\..\initspool setup_three_subnets

SET TIMING ON
@..\..\..\install\install_shortest_path_sql
PROMPT VIEW links_load_v
CREATE OR REPLACE VIEW links_load_v(node_name_fr, node_name_to) AS
WITH nodes_fr AS (
    SELECT COLUMN_VALUE node_name_fr, ROWNUM rn
      FROM L1_chr_arr(
              'S1-N0-1',
              'S1-N0-1',
              'S1-N0-1',
              'S1-N0-1',
              'S1-N0-1',
              'S1-N1-5',
              'S1-N1-1',
              'S1-N2-1',
              'S1-N1-2',
              'S1-N1-2',
              'S1-N1-4',
              'S1-N2-3',
              'S2-N0-1'
    )
), nodes_to AS (
    SELECT COLUMN_VALUE node_name_to, ROWNUM rn
      FROM L1_chr_arr(
              'S1-N1-1',
              'S1-N1-2',
              'S1-N1-3',
              'S1-N1-4',
              'S1-N1-5',
              'S1-N2-3',
              'S1-N2-1',
              'S1-N3-1',
              'S1-N1-3',
              'S1-N2-2',
              'S1-N2-3',
              'S1-N3-2',
              'S2-N1-1'
    )
)
SELECT nfr.node_name_fr, nto.node_name_to 
  FROM nodes_fr nfr
  JOIN nodes_to nto
    ON nto.rn = nfr.rn
/
PROMPT VIEW nodes_load_v
CREATE OR REPLACE VIEW nodes_load_v(node_name) AS
SELECT node_name_fr
  FROM links_load_v
 UNION
SELECT node_name_to
  FROM links_load_v
 UNION
SELECT 'S3-N0-1' FROM DUAL
ORDER BY 1
/
@..\..\setup_shortest_path_sql
@..\..\setup_shortest_path_sql_links_v
SET TIMING OFF
@..\..\endspool