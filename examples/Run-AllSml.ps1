Date -format "dd-MMM-yy HH:mm:ss"
$rootDir = 'C:\Users\Brend\OneDrive\Documents\GitHub\shortest_path_sql\examples\'
$examples = @(@{folder = 'three_subnets\main'; script = 'run_three_subnets'},
              @{folder = 'foreign_keys\sys_fks'; script = 'run_sys_fks'},
              @{folder = 'brightkite\main'; script = 'run_brightkite'},
              @{folder = 'bacon\small'; script = 'run_bacon_small'},
              @{folder = 'bacon\top250'; script = 'run_bacon_top250'})
$examples

Foreach($e in $examples){
    sl ($rootDir + $e.folder)
    $script = '@./' + $e.script
    'Executing: ' + $script + ' at ' + (Date -format "dd-MMM-yy HH:mm:ss")
    & sqlplus 'shortest_path_sql/shortest_path_sql@orclpdb' $script
}
sl $rootDir
