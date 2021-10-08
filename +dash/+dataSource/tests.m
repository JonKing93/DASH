function[] = tests
%% Implement unit tests for classes in the dash.dataSource subpackage
%
%   dash.dataSource.tests()  runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.


%% Add the test data to the path
currentPath = mfilename('fullpath');
testPath = split(currentPath, filesep);
testPath = [testPath(1:end-3); 'testdata'; 'dash.dataSource'];
testPath = strjoin(testPath, filesep);
addpath(testPath);
clean = onCleanup( @()rmpath(genpath(testPath)) );

file1 = "test-matfile-notv73.mat";
file2 = "test-matfile-v73.mat";


%% mat
header = "dash.dataSource.mat";

try
    dash.dataSource.mat('this-is-not-a-real-file', "var");
    error('%s: missing file', header);
catch
end
try
    dash.dataSource.mat('test.txt', "var");
    error('%s: not a mat file', header);
catch
end
try
    dash.datasource.mat('file2', "fakevar");
    error('%s: missing variable', header);
catch
end
try
    A = dash.dataSource.mat(file2, "A");
catch
    error('%s: normal build', header);
end
assert( isequal(A.size, [3 5 2]), '%s: wrong size');
assert( isequal(A.dataType, 'double'), '%s: wrong datatype');

tests = {...
    {1,1,1}, 1, 'basic load';...
    {1:3, (1:4)', 2}, [101:104;111:114;121:124], 'multiple elements';...
    {1, [1 3 4], 1}, [1 3 4], 'unstrided';...
    {1, [3 4 1 2], 1}, [3 4 1 2], 'mixed order';...
    };
for t = 1:size(tests,1)
    X = A.load(tests{t,1});
    assert(isequal(X, tests{t,2}), '%s:%s', header, tests{t,3});
end

warning('testing warnings');
dash.dataSource.mat(file2, "A");
assert(strcmp(lastwarn, 'testing warnings'), '%s: no warning', header);
dash.dataSource.mat(file1, "A");
[~, lastID] = lastwarn;
assert(strcmp(lastID, "DASH:dataSource:mat:matfileNotV73"), "%s: cause warning", header);




