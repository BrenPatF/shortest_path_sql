DEFINE SUB=&1
@..\..\initspool run_net_pipe_&SUB
SET LINES 500
SET PAGES 50000
COLUMN "Network"        FORMAT A10
COLUMN "Lev"            FORMAT 99990
COLUMN "Link"           FORMAT A10
COLUMN "#Links"         FORMAT 999990
COLUMN "#Nodes"         FORMAT 999990
COLUMN "Node Name"      FORMAT A30
COLUMN "Node"           FORMAT A70

SET TIMING ON
PROMPT Network detail (all links)
SELECT root_node_id "Network",
       n.node_name "Node Name", 
       Substr(LPad ('.', 1 + Least(2 * (t.node_level), 60), '.') || t.node_id, 2)  || t.loop_flag "Node", 
       t.node_level
  FROM TABLE(Net_Pipe.All_Nets) t
  JOIN nodes n
    ON n.id = t.node_id
 ORDER BY line_no
/

PROMPT Network detail (tree)
SELECT root_node_id                                                            "Network",
       n.node_name "Node Name", 
       Substr(LPad ('.', 1 + Least(2 * (t.node_level), 60), '.') || t.node_id, 2) "Node", 
       t.node_level
  FROM TABLE(Net_Pipe.All_Nets) t
  JOIN nodes n
    ON n.id = t.node_id
 WHERE t.loop_flag IS NULL
 ORDER BY line_no
/

BREAK ON "Network" ON "#Links" ON "#Nodes"
PROMPT Network summary 1 - by subnetwork
SELECT root_node_id            "Network",
       Count(DISTINCT link_id) "#Links",
       Count(DISTINCT node_id) "#Nodes",
       Max(node_level)         "Max Lev"
  FROM TABLE(Net_Pipe.All_Nets)
 GROUP BY root_node_id
 ORDER BY 2
/
PROMPT Network summary 2 - grouped by numbers of nodes
WITH network_counts AS (
SELECT root_node_id,
       Count(DISTINCT node_id) n_nodes
  FROM TABLE(Net_Pipe.All_Nets)
 GROUP BY root_node_id
)
SELECT n_nodes "#Nodes",
       COUNT(*) "#Networks"
  FROM network_counts
 GROUP BY n_nodes
 ORDER BY 1
/
SET TIMING OFF
@..\..\endspool