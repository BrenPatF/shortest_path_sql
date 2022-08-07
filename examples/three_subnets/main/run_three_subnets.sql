@setup_three_subnets
@..\..\ins_all_min_path_links three_subnets S1-N0-1
@..\..\ins_min_tree_links three_subnets S1-N0-1

@..\..\ins_node_roots_base_ts three_subnets

@..\..\ins_node_roots three_subnets 0 0 0
@..\..\ins_node_roots three_subnets 3 5 3
@..\..\ins_node_roots_xplans three_subnets

@..\..\ins_node_roots_hprof three_subnets
@..\..\ins_node_roots_dprof three_subnets
@..\..\ins_min_tree_links_hprof three_subnets S1-N0-1
@..\..\ins_min_tree_links_dprof three_subnets S1-N0-1

@..\..\query_all_paths three_subnets S1-N0-1 3
@..\..\query_min_paths_1 three_subnets S1-N0-1
@..\..\query_min_paths_2 three_subnets S1-N0-1 3

@..\..\run_net_pipe_t three_subnets
@..\..\run_net_pipe_sum three_subnets
exit