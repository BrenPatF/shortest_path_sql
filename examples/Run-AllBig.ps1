Date -format "dd-MMM-yy HH:mm:ss"
$rootDir = 'C:\Users\Brend\OneDrive\Documents\GitHub\shortest_path_sql\examples\'
$examples = @(@{folder = 'bacon\only_tv_v'; script = 'run_bacon_only_tv_v'},
              @{folder = 'bacon\no_tv_v'; script = 'run_bacon_no_tv_v'},
              @{folder = 'bacon\post1950'; script = 'run_bacon_post1950'},
              @{folder = 'bacon\full'; script = 'run_bacon_full'})
$examples

Foreach($e in $examples){
    sl ($rootDir + $e.folder)
    $script = '@./' + $e.script
    'Executing: ' + $script + ' at ' + (Date -format "dd-MMM-yy HH:mm:ss")
    & sqlplus 'shortest_path_sql/shortest_path_sql@orclpdb' $script
}
sl $rootDir
