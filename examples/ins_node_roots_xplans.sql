DEFINE SUB=&1
@..\..\initspool ins_node_roots_xplans_&SUB
SET TIMING ON
DECLARE
  l_root_id           PLS_INTEGER;
BEGIN
  SELECT /*+ gather_plan_statistics XPLAN_TYPE_0 */
        id INTO l_root_id 
    FROM nodes 
   WHERE id NOT IN (SELECT node_id FROM node_roots) 
     AND ROWNUM = 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_TYPE_0'));
END;
/
DECLARE
  l_root_id           PLS_INTEGER;
BEGIN
  SELECT /*+ gather_plan_statistics XPLAN_TYPE_1 */
         Min(id) INTO l_root_id 
    FROM nodes WHERE id NOT IN (SELECT node_id FROM node_roots);
  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_TYPE_1'));
END;
/
DECLARE
  l_root_id           PLS_INTEGER;
BEGIN
  SELECT /*+ gather_plan_statistics XPLAN_TYPE_2 */
         id INTO l_root_id 
    FROM (SELECT id FROM nodes WHERE id NOT IN (
              SELECT node_id FROM node_roots) ORDER BY 1
         ) 
   WHERE ROWNUM = 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_TYPE_2'));
END;
/
DECLARE
  l_root_id           PLS_INTEGER;
  l_dummy             PLS_INTEGER;
  CURSOR c_roots IS
  SELECT /*+ gather_plan_statistics XPLAN_TYPE_3_1 */
        id 
    FROM nodes 
   ORDER BY 1;
BEGIN

  OPEN c_roots;
  FETCH c_roots INTO l_root_id;

  SELECT /*+ gather_plan_statistics XPLAN_TYPE_3_2 */
       1 INTO l_dummy 
    FROM node_roots 
   WHERE node_id = l_root_id;

  CLOSE c_roots;

  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_TYPE_3_1'));
  Utils.W(Utils.Get_XPlan(p_sql_marker => 'XPLAN_TYPE_3_2'));
END;
/
SET TIMING OFF
@..\..\endspool
