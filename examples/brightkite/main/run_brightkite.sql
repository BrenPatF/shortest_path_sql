@setup_brightkite

@..\..\ins_min_tree_links brightkite 6

@..\..\ins_node_roots_base_ts brightkite

@..\..\ins_node_roots brightkite 0 0 0
@..\..\ins_node_roots brightkite 3 5 3
@..\..\ins_node_roots_xplans brightkite

@..\..\ins_node_roots_hprof brightkite
@..\..\ins_node_roots_dprof brightkite

rem @..\..\query_min_paths_1 brightkite 6 5 -- does not terminate
@..\..\query_min_paths_2 brightkite 6 5

@..\..\run_net_pipe_t brightkite
@..\..\run_net_pipe_sum brightkite
exit