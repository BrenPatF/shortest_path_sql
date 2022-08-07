@..\install\install_shortest_path_sql_tt
@..\initspool r_tests
BEGIN

  Trapit_Run.Run_Tests(p_group_nm => 'SHORTEST_PATH_SQL');

END;
/
@..\endspool
exit