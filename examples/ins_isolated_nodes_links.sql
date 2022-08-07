DEFINE SUB=&1
DEFINE P1=&2
DEFINE P2=&3
@..\..\initspool ins_isolated_nodes_links_&SUB._&P1&P2
SET TIMING ON
DECLARE
  l_n_nodes PLS_INTEGER;
BEGIN
  l_n_nodes := SPS_Pre_Inserts.Ins_Isolated_Nodes_Links(p_node_vsn => &P1, p_link_vsn => &P2);
  Utils.W('Processed: ' || l_n_nodes);
END;
/
SET TIMING OFF
@..\..\endspool
