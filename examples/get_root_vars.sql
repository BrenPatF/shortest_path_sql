COLUMN root_id NEW_VALUE root_id_var;
COLUMN root_file NEW_VALUE root_file_var;

SELECT id root_id, Lower(Replace(Replace(Replace('&ROOT_NAME', ' ', '_'), '|', '-'), '"', '')) root_file
  FROM nodes 
 WHERE node_name = Replace('&ROOT_NAME', '"', '''');
