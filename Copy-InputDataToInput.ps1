# Script to expand the input zip files and copy to $dbDir
#
# The files were taken from tow external sites, and converted from Unix to Windows format (line endings)
#
# imdb.*: https://www.cs.oberlin.edu/~rhoyle/16f-cs151/lab10/index.html
#
# brightkite_edges.csv: https://snap.stanford.edu/data/loc-brightkite.html
#
# Two files exceeded 100MB in size when zipped and could not be saved to GitHub
# full and post1950 can be obtained from the link above, and converted asnecessary
#
#$srcDir = 'C:\Users\Brend\OneDrive\Documents\GitHub\shortest_path_sql\examples\input\'
$srcDir = '.\examples\input\'
$dbDir = 'C:\input'
$inputFiles = @(
		'brightkite_edges.csv',
#		'imdb.full.txt', too big for GitHub
		'imdb.no_tv_v.txt',
		'imdb.only_tv_v.txt',
#		'imdb.post1950.txt', too big for GitHub
		'imdb.pre1950.txt',
		'imdb.small.txt',
		'imdb.top250.txt')

Foreach($f in $inputFiles) {
	Expand-Archive -Path ($srcDir + $f + '.zip') -DestinationPath $dbDir
}