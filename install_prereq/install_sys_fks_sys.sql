@initspool install_sys_fks_sys
SET TIMING ON
PROMPT Foreign key table setup...
CREATE TABLE shortest_path_sql.fk_links(
                constraint_name,
                table_fr,
                table_to
) AS
SELECT Lower(con_f.constraint_name || '|' || con_f.owner),
       con_f.table_name || '|' || con_f.owner,
       con_t.table_name || '|' || con_t.owner
  FROM all_constraints                  con_f
  JOIN all_constraints                  con_t
    ON con_t.constraint_name            = con_f.r_constraint_name
   AND con_t.owner                      = con_f.r_owner
 WHERE con_f.constraint_type            = 'R'
   AND con_t.constraint_type            = 'P'
   AND con_f.table_name NOT LIKE '%|%'
   AND con_t.table_name NOT LIKE '%|%'
/
SELECT COUNT(*)
  FROM shortest_path_sql.fk_links
/
SET TIMING OFF
@endspool