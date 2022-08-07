@setup_sys_fks.sql

@..\..\ins_min_tree_links sys_fks JOB_HISTORY|HR
@..\..\ins_min_tree_links sys_fks ORDDCM_STORED_TAGS_WRK|ORDDATA
@..\..\ins_min_tree_links sys_fks ORDDCM_CT_ACTION|ORDDATA

@..\..\ins_node_roots_base_ts sys_fks

@..\..\ins_node_roots sys_fks 0 0 0
@..\..\ins_node_roots sys_fks 3 5 3
@..\..\ins_node_roots_xplans sys_fks

@..\..\ins_node_roots_hprof sys_fks
@..\..\ins_node_roots_dprof sys_fks

@..\..\query_min_paths_1 sys_fks ORDDCM_STORED_TAGS_WRK|ORDDATA
@..\..\query_min_paths_2 sys_fks ORDDCM_STORED_TAGS_WRK|ORDDATA 5
@..\..\query_min_paths_2 sys_fks JOB_HISTORY|HR 5

@..\..\run_net_pipe_t sys_fks
@..\..\run_net_pipe_sum sys_fks
exit