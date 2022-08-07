CREATE OR REPLACE PACKAGE BODY Net_Pipe AS
/***************************************************************************************************
Name: net_pipe.pkb                      Author: Brendan Furey                      Date: 10-May-2015

Package body component in the plsql_network module. 

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

PACKAGES
====================================================================================================
|  Package      |  Notes                                                                           |
|==================================================================================================|
| *Net_Pipe*    |  Package with pipelined function for network analysis                            |
|---------------|----------------------------------------------------------------------------------|
|  TT_Net_Pipe  |  Unit testing the Net_Pipe package. Depends on the module trapit_oracle_tester   |
====================================================================================================

This file has the Net_Pipe package body. See README for API specification and examples of use.

***************************************************************************************************/
ROOT_LINK_ID          CONSTANT VARCHAR2(100) := 'ROOT';
LOOP_FLAG             CONSTANT VARCHAR2(1) := '*';
DIRN_FR               CONSTANT VARCHAR2(1) := '<';
DIRN_TO               CONSTANT VARCHAR2(1) := '>';
DIRN_SJ               CONSTANT VARCHAR2(1) := '=';

CURSOR next_nodes_csr(p_node_id                      VARCHAR2,
                      p_link_id_prior                VARCHAR2) IS
    WITH uni_3way AS (
  SELECT link_id, node_id_fr node_id, DIRN_FR dirn
    FROM links_v
   WHERE node_id_to   = p_node_id
     AND node_id_to  != node_id_fr
     AND link_id     != p_link_id_prior
   UNION
  SELECT link_id, node_id_to, DIRN_TO
    FROM links_v
   WHERE node_id_fr   = p_node_id
     AND node_id_to  != node_id_fr
     AND link_id     != p_link_id_prior
   UNION
  SELECT link_id, node_id_to, DIRN_SJ
    FROM links_v
   WHERE node_id_fr   = p_node_id
     AND node_id_to   = node_id_fr
     AND link_id     != p_link_id_prior
  )
  SELECT Trim(link_id) link_id, Trim(node_id) node_id, dirn -- Trims necessary in Version 18.3.0.0.0
    FROM uni_3way
   ORDER BY 2, 1;
TYPE next_nodes_arr IS TABLE OF next_nodes_csr%ROWTYPE;

/*************************************************************************************************

next_Nodes: Gets the list of node neighbours using package cursor

*************************************************************************************************/
FUNCTION next_Nodes(
            p_node_id                      VARCHAR2,         -- node id
            p_link_id_prior                VARCHAR2)         -- prior link id
            RETURN                         next_nodes_arr IS -- array of next node records

  l_next_nodes_lis               next_nodes_arr;
BEGIN

  OPEN next_nodes_csr(p_node_id, p_link_id_prior);
  FETCH next_nodes_csr BULK COLLECT
   INTO l_next_nodes_lis;
  CLOSE next_nodes_csr;

  RETURN l_next_nodes_lis;

END next_Nodes;
/***************************************************************************************************

All_Nets: Entry point function that returns the network structure records based on the view links_v

***************************************************************************************************/
FUNCTION All_Nets 
            RETURN net_arr PIPELINED IS -- network structure records

  TYPE id_hash_type IS TABLE OF  PLS_INTEGER INDEX BY VARCHAR2(100);
  g_net_tab                      net_arr;
  g_node_hash                    id_hash_type;
  g_link_hash                    id_hash_type;
  g_line_no                      PLS_INTEGER;

  /*************************************************************************************************

  init_Net: Initialises global variables

  *************************************************************************************************/
  PROCEDURE init_Net IS
  BEGIN

    g_net_tab := net_arr();
    g_link_hash.DELETE;

  END init_Net;

  /*************************************************************************************************

  add_Net_Rec: Adds network record to global array and sets other global variables

  *************************************************************************************************/
  PROCEDURE add_Net_Rec(
              p_root_node_id                 VARCHAR2,    -- root node id
              p_dirn                         VARCHAR2,    -- direction
              p_node_id                      VARCHAR2,    -- node id
              p_link_id                      VARCHAR2,    -- link id
              p_node_level                   PLS_INTEGER, -- node level
              p_is_loop                      BOOLEAN) IS  -- does node form a loop?

    l_net_rec                       net_rec;
  BEGIN

      g_link_hash(p_link_id) := 1;
      g_line_no := g_line_no + 1;

      l_net_rec.line_no      := g_line_no;
      l_net_rec.root_node_id := p_root_node_id;
      l_net_rec.dirn         := p_dirn;
      l_net_rec.node_id      := p_node_id;
      l_net_rec.link_id      := p_link_id;
      l_net_rec.node_level   := p_node_level;

      IF p_is_loop THEN

        l_net_rec.loop_flag := LOOP_FLAG;

      ELSE

        g_node_hash(p_node_id) := 1;

      END IF;

      g_net_tab.EXTEND;
      g_net_tab(g_net_tab.COUNT)  := l_net_rec;

  END add_Net_Rec;
      
  /*************************************************************************************************

  expand_Node: Recursive procedure to expand the network from a given node

  *************************************************************************************************/
  PROCEDURE expand_Node(
              p_root_node_id                 VARCHAR2,    -- root node id
              p_dirn                         VARCHAR2,    -- direction
              p_node_id                      VARCHAR2,    -- node id
              p_link_id                      VARCHAR2,    -- link id
              p_node_level                   PLS_INTEGER, -- node level
              p_is_loop                      BOOLEAN) IS  -- does node form a loop?

    l_next_nodes_lis                next_nodes_arr;
  BEGIN

    add_Net_Rec(p_root_node_id => p_root_node_id,
                p_dirn         => p_dirn,
                p_node_id      => p_node_id,
                p_link_id      => p_link_id,
                p_node_level   => p_node_level,
                p_is_loop      => p_is_loop);

    IF p_is_loop THEN RETURN; END IF; -- if the node formed a loop, needed to add link but not expand

    l_next_nodes_lis := next_Nodes(p_node_id       => p_node_id,
                                   p_link_id_prior => p_link_id);

    FOR i IN 1..l_next_nodes_lis.COUNT LOOP

      IF NOT g_link_hash.EXISTS(l_next_nodes_lis(i).link_id) THEN -- if link not done then...

        expand_Node(p_root_node_id  => p_root_node_id,
                    p_dirn          => l_next_nodes_lis(i).dirn,
                    p_node_id       => l_next_nodes_lis(i).node_id,
                    p_link_id       => l_next_nodes_lis(i).link_id,
                    p_node_level    => p_node_level + 1,
                    p_is_loop       => g_node_hash.EXISTS(l_next_nodes_lis(i).node_id));
      END IF;

    END LOOP;

  END expand_Node;

BEGIN

  g_line_no := 0;
  FOR r_nod IN (SELECT Trim(node_id_fr) root_node_id FROM links_v
                 UNION
                SELECT Trim(node_id_to) FROM links_v) LOOP

    IF g_node_hash.EXISTS(r_nod.root_node_id) THEN CONTINUE; END IF; -- skip if in prior subnetwork

    init_Net;
    expand_Node(p_root_node_id  => r_nod.root_node_id,
                p_dirn          => ' ',
                p_node_id       => r_nod.root_node_id,
                p_link_id       => ROOT_LINK_ID,
                p_node_level    => 0,
                p_is_loop       => FALSE);

    FOR i IN 1..g_net_tab.COUNT LOOP

      PIPE ROW (g_net_tab(i));

    END LOOP;

  END LOOP;

END All_Nets;

END Net_Pipe;
/
SHO ERR