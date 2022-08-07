PROMPT links_v based on links
INSERT INTO links_v (
  link_id,
  node_id_fr,
  node_id_to
)
SELECT To_Char(node_id_fr) || '-' || To_Char(node_id_to),
       To_Char(node_id_fr),
       To_Char(node_id_to)
  FROM links
/
PROMPT Non-unique index ON links_v (node_id_fr)
CREATE INDEX links_v_n1 ON links_v(node_id_fr)
/
PROMPT Non-unique index ON links_v (node_id_to)
CREATE INDEX links_v_n2 ON links_v(node_id_to)
/
EXECUTE DBMS_Stats.Gather_Schema_Stats(ownname => 'SHORTEST_PATH_SQL');
