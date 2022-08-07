Date -format "dd-MMM-yy HH:mm:ss"
$userRoot='C:\Users\Brend\OneDrive\Documents\'
$sqlDir = $userRoot + 'GitHub\shortest_path_sql\unit_test\'
$npmDir = $userRoot + 'demo\npm\node_modules\trapit\'
$inputDir = 'C:\input\'
$utOutFiles = @('tt_shortest_path_sql.purely_wrap_ins_node_roots_out.json', 'tt_shortest_path_sql.purely_wrap_ins_min_tree_links_out.json')

sl $sqlDir
$script = '@./r_tests'
'Executing: ' + $script + ' at ' + (Date -format "dd-MMM-yy HH:mm:ss")
& sqlplus 'shortest_path_sql/shortest_path_sql@orclpdb' $script

sl $npmDir
Foreach($f in $utOutFiles) {
    $jsonFile = ($inputDir + $f)
    ('Copying ' + $jsonFile + ' to .\externals\shortest_path_sql')
    cp $jsonFile .\externals\shortest_path_sql
}
node externals\format-externals shortest_path_sql > shortest_path_sql.log
cat .\shortest_path_sql.log

sl $sqlDir
