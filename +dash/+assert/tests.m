function[] = tests
%% Implements unit testing for the functions in dash.assert
%
% dash.assert.tests
% Runs the tests. If successful, exits silently. If failed, prints the
% first failed test to console.
%
% Tests the following functions:
% fileExists, strflag, strlist

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
assert(strcmp(ME.identifier, "header:nameNotStrflag"), 'strflag: ID');
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
assert(strcmp(ME.identifier, "header:nameNotStrlist"), 'strlist: ID');
assert(strcmp(ME.message, 'name must be a string vector, cellstring vector, or character row vector'), 'strlist: message');



end