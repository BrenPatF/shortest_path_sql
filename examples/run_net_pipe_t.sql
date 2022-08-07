DEFINE SUB=&1
@..\..\initspool run_net_pipe_t_&SUB
SET LINES 500
SET PAGES 50000
COLUMN "Network"        FORMAT A10
COLUMN "Lev"            FORMAT 99990
COLUMN "Link"           FORMAT A10
COLUMN "#Links"         FORMAT 999990
COLUMN "#Nodes"         FORMAT 999990
COLUMN "Node Name"      FORMAT A35
COLUMN "Node"           FORMAT A70

SET TIMING ON

PROMPT Network detail (tree)
SELECT root_node_id "Network",
       n.node_name "Node Name", 
       Substr(LPad ('.', 1 + Least(2 * (t.node_level), 60), '.') || t.node_id, 2) "Node", 
       t.node_level lev
  FROM TABLE(Net_Pipe.All_Nets) t
  JOIN nodes n
    ON n.id = t.node_id
 WHERE t.loop_flag IS NULL
 ORDER BY line_no
/
SET TIMING OFF
@..\..\endspool