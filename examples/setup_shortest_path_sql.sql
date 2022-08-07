PROMPT Insert nodes
INSERT INTO nodes (node_name)
SELECT node_name
  FROM nodes_load_v
/
PROMPT Insert links
INSERT INTO links (node_id_fr, node_id_to)
SELECT DISTINCT nod_fr.id, nod_to.id
  FROM links_load_v llv
  JOIN nodes nod_fr ON nod_fr.node_name = llv.node_name_fr
  JOIN nodes nod_to ON nod_to.node_name = llv.node_name_to
 WHERE nod_fr.id != nod_to.id
/
PROMPT Count nodes
SELECT COUNT(*)
  FROM nodes
/
PROMPT Count links
SELECT COUNT(*)
  FROM links
/
PROMPT Non-unique index links (node_id_fr)
CREATE INDEX links_fr_n1 ON links(node_id_fr)
/
PROMPT Non-unique index on links(node_id_to)
CREATE INDEX links_to_n1 ON links(node_id_to)
/
PROMPT Foreign keys on links: node_id_fr and node_id_to
ALTER TABLE links ADD (CONSTRAINT links_nodes_fr FOREIGN KEY (node_id_fr) REFERENCES nodes(id))
/
ALTER TABLE links ADD (CONSTRAINT links_nodes_to FOREIGN KEY (node_id_to) REFERENCES nodes(id))
/
PROMPT Gather schema stats
EXECUTE DBMS_Stats.Gather_Schema_Stats(ownname => 'SHORTEST_PATH_SQL');
