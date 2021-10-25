function[] = tests
%% dash.assert.tests  Implement unit testing for the dash.assert subpackage
% ----------
%   dash.assert.tests()
%   Runs the units tests. If the tests pass, exits silently. If the tests
%   fail, prints the first failed test to the console.
%
%   Tests the following functions: 
%   fileExists, scalarType, strflag, strlist, strsInList, vectorTypeN
% ----------

%% fileExists

% Add the test file to the path
currentPath = mfilename('fullpath');
testPath = split(currentPath, filesep);
testPath = [testPath(1:end-3); 'testdata'; 'dash.assert.fileExists'];
testPath = strjoin(testPath, filesep);
addpath(testPath);

try
    file = strjoin({'testdata', 'dash.assert.fileExists','not-a-file'}, filesep);
    dash.assert.fileExists(file, "");
    rmpath(testPath);
    error('fileExists: missing file');
catch
end

try
    file = strjoin({'testdata','dash.assert.fileExists','testfile.txt'}, filesep);
    dash.assert.fileExists(file, "");
catch
    rmpath(testPath);
    error('fileExists: existing char file');
end

try
    dash.assert.fileExists(string(file), "");
catch
    rmpath(testPath);
    error('fileExists: existing string file');
end

try
    file = strjoin({'testdata','dash.assert.fileExists','testfile'}, filesep);
    dash.assert.fileExists(file, "", ".txt");
catch
    rmpath(testPath);
    error('fileExists: append string extension');
end

try
    file = strjoin({'testdata','dash.assert.fileExists','testfile'}, filesep);
    dash.assert.fileExists(file, "", '.txt');
catch
    rmpath(testPath);
    error('fileExists: append char extension');
end
        
rmpath(testPath);

file = strjoin({testPath, 'testfile.txt'}, filesep);
try
    dash.assert.fileExists(file, "");
catch
    error('fileExists: Absolute path off active path');
end

file = strjoin({testPath, 'testfile.txt'}, filesep);
try
    dash.assert.fileExists(file, "");
catch
    error('fileExists: Absolute path off active path');
end

file = strjoin({testPath, 'not-a-file.txt'}, filesep);
try
    dash.assert.fileExists(file, "myHeader");
    error('fileExists: File that does not exist');
catch ME
end

if ~strcmp(ME.identifier, sprintf('myHeader:fileNotFound'))
    error('fileExists: ID');
elseif ~strcmp(ME.message, sprintf('File "%s" could not be found. It may be misspelled or not on the active path', file))
    error('fileExists: message');
end


%% scalarType

passTests = {...
    struct('test',1), 'struct', 'scalar struct';...
    5, 'double', 'scaalr double';...
    5, 'numeric', 'scalar numeric';...
    true, 'logical', 'scalar logical';...
    5, [], 'scalar no type';...
    };
failTests = {...
    ones(4,1), 'numeric', 'not scalar right type';...
    1, 'logical', 'scalar wrong type';...
    ones(4,1), [], 'not scalar no type';...
    };

errorTests = {...
    'not scalar', [], [], 'my variable is not scalar', 'myHeader:inputNotScalar', 'not scalar';...
    "wrong type", 'numeric', [], 'my variable must be a numeric scalar, but it is a string scalar instead', 'myHeader:inputWrongType', 'wrong type';...
    "type name", 'numeric', 'custom type name', 'my variable must be a custom type name scalar, but it is a string scalar instead', 'myHeader:inputWrongType', 'custom type name';...
    };

for t = 1:size(passTests,1)
    try
        dash.assert.scalarType(passTests{t,1}, passTests{t,2}, "", "");
    catch
        error('scalarType:%s', passTests{t,3});
    end
end

for t = 1:size(failTests,1)
    try
        dash.assert.scalarType(passTests{t,1}, passTests{t,2}, "", "");
        error('scalarType:%s', failTests{t,3});
    catch
    end
end

tests = errorTests;
for t = 1:size(tests, 1)
    try
        dash.assert.scalarType(tests{t,1}, tests{t,2}, 'my variable', 'myHeader', tests{t,3});
    catch ME
    end
    assert(strcmp(ME.message, tests{t,4}), 'scalarType: %s message', tests{t,6});
    assert(strcmp(ME.identifier, tests{t,5}), 'scalarType: %s ID', tests{t,6});
end


%% strflag

charRow = 'test';
strRow = ["test","test"];

passTests = {...
    strRow(1), 'string scalar';...
    charRow, 'char row vector';...
    };

for t = 1:size(passTests,1)
    try
        dash.assert.strflag( passTests{t,1}, "", "");
    catch ME
        error('strflag: %s', passTests{t,2});
    end
end

failTests = {...
    strRow, 'string row vector';...
    strRow', 'string column vector';...
    charRow', 'char column';...
    {'test'}, 'cellstr scalar';...
    [], 'empty';...
    5, 'numeric';...
    true, 'logical';...
    };

for t = 1:size(failTests,1)
    try
        dash.assert.strflag(failTests{t,1}, "", "");
        error('strflag: %s', failTests{t,2});
    catch
    end
end

% ID and message test
try
    dash.assert.strflag(false, "name", "header");
catch ME
end
assert(strcmp(ME.identifier, "header:inputNotStrflag"), 'strflag: ID');
assert(strcmp(ME.message, 'name must be a string scalar or character row vector'), 'strflag: message');


%% strlist

cellRow = {'test','test','test'};

passTests = {...
    strRow(1), 'string scalar';...
    strRow, 'string row vector';...
    strRow', 'string column vector';...
    cellRow, 'cellstr row vector';...
    cellRow', 'cellstr column vector';...
    charRow, 'char row vector';...
    };

for t = 1:size(passTests,1)
    try
        dash.assert.strlist( passTests{t,1}, "", "");
    catch ME
        error('strlist: %s', passTests{t,2});
    end
end

failTests = {...
    [strRow;strRow], 'string matrix';...
    charRow', 'char column';...
    [charRow;charRow], 'char matrix';...
    [cellRow;cellRow], 'cellstr matrix';...
    [], 'empty';...
    5, 'numeric';...
    true, 'logical';...
    };

for t = 1:size(failTests,1)
    try
        dash.assert.strlist(failTests{t,1}, "", "");
        error('strlist: %s', failTests{t,2});
    catch
    end
end

% ID and message test
try
    dash.assert.strlist(false, "name", "header");
catch ME
end
assert(strcmp(ME.identifier, "header:inputNotStrlist"), 'strlist: ID');
assert(strcmp(ME.message, 'name must be a string vector, cellstring vector, or character row vector'), 'strlist: message');


%% strsInList

allowed = ["a1", "a2", "a3"];
passTests = {...
    "a3", 'element in list';...
    ["a3", "a1"], 'unsorted elements from list';...
    ["a1","a1","a2"], 'repeated elements from list';...
    };
failTests = {...
    "B", 'element not from list';...
    ["a2","b"], 'some elements not from list';...
    };

for t = 1:size(passTests,1)
    try
        dash.assert.strsInList(passTests{t,1}, allowed, "", "", "");
    catch
        error('strsInList:%s', passTests{t,2});
    end
end

for t = 1:size(failTests,1)
    try
        dash.assert.strsInList(failTests{t,1}, allowed, "", "", "");
        error('strsInList:%s', passTests{t,2});
    catch
    end
end

try
    dash.assert.strsInList("fail", "test", "my variable", "element in list", "myHeader");
catch ME
end
message = "my variable (fail) is not a(n) element in list. Allowed values are ""test"".";
id = "myHeader:stringNotInList";
assert(strcmp(ME.message, message), 'strsInList: error message');
assert(strcmp(ME.identifier, id), 'strsInList: error ID');


%% vectorTypeN

passTests = {...
    ones(5,1), 'numeric', 5, 'numeric column length';...
    ones(1,5), 'numeric', 5, 'numeric row length';...
    ["a","b","c"], 'string', 3, 'string row length';...
    ones(5,1), [], 5, 'numeric length, no type';...
    ones(5,1), 'double', [], 'double length, no type';...
    ones(5,1), [], [], 'numeric, no length, no type';...
    };
failTests = {...
    ones(4,4), [], [], 'matrix';...
    ones(5,1), 'string', [], 'wrong type';...
    ones(5,1), 'numeric', 7, 'wrong length';...
    };
errorTests = {...
    ones(4,4), [], [], 'my variable is not a vector', 'myHeader:inputNotVector', 'not vector error';...
    ones(5,1), 'string', [], 'my variable must be a string vector, but it is a double vector instead', 'myHeader:inputWrongType', 'wrong type error';...
    ones(5,1), 'numeric', 7, 'my variable must have 7 elements, but has 5 elements instead', 'myHeader:inputWrongLength', 'wrong length error';...
    };

test = passTests;
for t = 1:size(test,1)
    try
        dash.assert.vectorTypeN(test{t,1}, test{t,2}, test{t,3}, "", "");
    catch ME
        error('vectorTypeN: %s', test{t,4});
    end
end

test = failTests;
for t = 1:size(test,1)
    try
        dash.assert.vectorTypeN(test{t,1}, test{t,2}, test{t,3}, "", "");
        error('vectorTypeN: %s', test{t,4});
    catch
    end
end

test = errorTests;
for t = 1:size(test, 1)
    try
        dash.assert.vectorTypeN(test{t,1}, test{t,2}, test{t,3}, 'my variable', 'myHeader');
    catch ME
    end
    assert(strcmp(ME.message, test{t,4}), 'vectorTypeN: %s', test{t,6});
    assert(strcmp(ME.identifier, test{t,5}), 'vectorTypeN: %s', test{t,6});
end


end