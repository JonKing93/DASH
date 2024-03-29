function[] = tests
%% dash.assert.tests  Implement unit testing for the dash.assert subpackage
% ----------
%   dash.assert.tests
%   Runs the units tests. If the tests pass, exits silently. If the tests
%   fail, prints the first failed test to the console.
% ----------
%   
% <a href="matlab:dash.doc('dash.assert.tests')">Documentation Page</a>

% Locate test data
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-3);
testpath = fullfile(dash{:}, 'testdata','dash','assert');

% Run tests
string_;
strflag;
strlist;
strsInList;

type;
scalarType;
vectorTypeN;
matrixTypeSize;
blockTypeSize;

scalarObj;
sameSize;

integers;
positiveIntegers;
defined;

symmetricMatrices;
positiveDiagonals;
covariances;

indices;
indexCollection;
additiveIndices;
additiveIndexCollection;

fileExists(testpath);
nameValue;
uniqueSet;

end


function[] = strflag

charRow = 'test';
strRow = ["test","test"];

tests = {
    % input, description, should pass, input name
    strRow(1), 'string scalar', true, []
    charRow, 'char row vector', true, []
    strRow, 'string row vector', false, []
    strRow', 'string column vector', false, []
    charRow', 'char column', false, []
    {'test'}, 'cellstr scalar', true, []
    [], 'empty', false, []
    5, 'numeric', false, []
    true, 'logical', false, []
    false, 'custom error', false, "name"
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,3};
    if shouldFail
        try
            dash.assert.strflag(tests{t,1}, tests{t,4}, testHeader);
            error(tests{t,2});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,2});
        if ~isempty(tests{t,4})
            assert(contains(ME.message, tests{t,4}), tests{t,2});
        end
        
    else
        output = dash.assert.strflag(tests{t,1});
        assert(isequal(output, string(tests{t,1})), tests{t,2});
    end
end

end
function[] = strlist

charRow = 'test';
strRow = ["test","test"];
cellRow = {'test','test','test'};

tests = {
    strRow(1), 'string scalar', true, []
    strRow, 'string row vector', true, []
    strRow', 'string column vector', true, []
    cellRow, 'cellstr row vector', true, []
    cellRow', 'cellstr column vector', true, []
    charRow, 'char row vector', true, []
    [strRow;strRow], 'string matrix', false, []
    charRow', 'char column', false, []
    [charRow;charRow], 'char matrix', false, []
    [cellRow;cellRow], 'cellstr matrix', false, []
    [], 'empty', false, []
    5, 'numeric', false, []
    true, 'logical', false, []
    true, 'custom error', false, 'my variable'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,3};
    if shouldFail
        try
            dash.assert.strlist(tests{t,1}, tests{t,4}, testHeader);
            error(tests{t,2});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,2});
        if ~isempty(tests{t,4})
            assert(contains(ME.message, tests{t,4}), tests{t,2});
        end
        
    else
        output = dash.assert.strlist(tests{t,1});
        assert(isequal(output, string(tests{t,1})), tests{t,2});
    end
end

end
function[] = strsInList

allowed = ["a1", "a2", "a3"];
tests = {
    "a3", 'element in list', true, []
    ["a3", "a1"], 'unsorted elements from list', true, []
    ["a1","a1","a2"], 'repeated elements from list', true, []
    "B", 'element not from list', false, []
    ["a2","b"], 'some elements not from list', false, []
    "fail", 'custom error', false, 'my variable'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,3};
    if shouldFail
        try
            dash.assert.strsInList(tests{t,1}, allowed, tests{t,4}, [], testHeader);
            error(tests{t,2});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,2});
        if ~isempty(tests{t,4})
            assert(contains(ME.message, tests{t,4}), tests{t,2});
        end
        
    else
        output = dash.assert.strsInList(tests{t,1}, allowed);
        [~, loc] = ismember(tests{t,1}, allowed);
        assert(isequal(output, loc), tests{t,2});
    end
end

end

function[] = type

tests = {
    'type', true, 5, 'double', [], []
    'inherited type', true, 5, 'numeric', [], []
    'wrong type', false, 5, 'logical', [], []
    'custom error', false, 5, 'logical', 'my variable', 'my description'
    'multiple types, valid', true, 5, ["string","cell","double"], [], []
    'multiple types, invalid', false, 5, ["string","cell"], 'my variable','my description'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.assert.type(tests{t,3:6}, testHeader);
            error(tests{t,1});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        if ~isempty(tests{t,5})
            assert(contains(ME.message, tests{t,5}) && contains(ME.message, tests{t,6}), tests{t,1});
        end
        
    else
        dash.assert.type(tests{t,3}, tests{t,4});
    end
end

end
function[] = scalarType

tests = {
    'scalar struct', true, struct('test',1), 'struct', []
    'scalar double', true, 5, 'double', []
    'scalar numeric', true, 5, 'numeric', []
    'scalar logical', true, true, 'logical', []
    'scalar no type', true, 5, [], []
    'not scalar, right type', false, ones(4,1),  'numeric', []
    'scalar wrong type', false, 1, 'logical', []
    'not scalar, no type', false, ones(4,1), [], []
    'custom error, not scalar', false, ones(4,1), [], 'my type'
    'custom error, wrong type', false, 1, 'logical', 'my type'
    'multiple types, valid', true, 5, ["string","cell","double"],[]
    'multiple types, invalid', false, 5, ["string","cell"], 'my type'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.assert.scalarType(tests{t,3}, tests{t,4}, tests{t,5}, testHeader);
            error(tests{t,1});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        if ~isempty(tests{t,5})
            assert(contains(ME.message, tests{t,5}), tests{t,1});
        end
        
    else
        dash.assert.scalarType(tests{t,3:5}, testHeader);
    end
end

end
function[] = scalarObj

tests = {
    % description, should pass, calling object
    'empty', true, gridMetadata
    'scalar', true, gridMetadata('lat',1)
    'array', false, [gridMetadata('lat',1), gridMetadata('lon',2)]
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    try
        dash.assert.scalarObj(tests{t,3}, testHeader);
        assert(tests{t,2}, tests{t,1});
    catch ME
        assert(~tests{t,2} && contains(ME.identifier, testHeader), tests{t,1});
    end
end

end
function[] = vectorTypeN

tests = {
    'numeric column length', true, ones(5,1), 'numeric', 5, []
    'numeric row length', true, ones(1,5), 'numeric', 5, []
    'string row length', true, ["a","b","c"], 'string', 3, []
    'numeric length, no type', true, ones(5,1), [], 5, []
    'double length, no type', true, ones(5,1), [], 5, []
    'no length, no type', true, ones(5,1), [], [], []
    'matrix', false, ones(4,4), [], [], []
    'wrong type', false, ones(5,1), 'string', [], []
    'wrong length', false, ones(5,1), 'numeric', 7, []
    'custom error, not vector', false, ones(4,4), [], [], 'test name'
    'custom error, wrong type', false, ones(5,1), 'string', [], 'test name'
    'custom error, wrong length', false, ones(5,1), 'numeric', 7, 'test name'
    'multiple types, valid', true, ones(5,1), ["string","cell","double"],5,[]
    'multiple types, invalid', false, ones(5,1), ["string","cell"], 5, 'test name'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.assert.vectorTypeN(tests{t,3:6}, testHeader);
            error(tests{t,1});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        if ~isempty(tests{t,6})
            assert(contains(ME.message, tests{t,6}), tests{t,1});
        end
        
    else
        dash.assert.vectorTypeN(tests{t,3:6}, testHeader);
    end
end


end

function[] = integers

tests = {
    'All integers', true, 1:5
    'Not all integers', false, 1:.1:5
    'has NaN', false, [1 2 NaN 3]
    'has Inf', false, [1 2 Inf 3]
};
name = 'test name';
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.integers(tests{t,3}, name, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error header');
            assert(contains(ME.message, name), 'invalid error message');
            
        else
            dash.assert.integers(tests{t,3}, name, header);
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = positiveIntegers

tests = {
    'all positive integers', true, 1:10
    'zero', false, 0:10
    'not positive', false, -4:-2
    'not integer', false, [1 2.2 3]
    'NaN', false, [1 NaN 2]
    'Inf', false, [1 Inf 2]
    };
name = 'test name';
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.positiveIntegers(tests{t,3}, name, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error header');
            assert(contains(ME.message, name), 'invalid error message');
            
        else
            dash.assert.positiveIntegers(tests{t,3}, name, header);
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = defined

tests = {
    '1, valid', true, 1, 1:5
    '1, nan', false, 1, [1 2 NaN 3]
    '1, inf', false, 1, [1 2 Inf 3]
    '1, mixed', false, 1, [1 2 NaN Inf 3]
    '1, complex', false, 1, 2i
    '2, valid', true, 2, 1:5
    '2, nan', true, 2, [1 2 NaN 3]
    '2, inf', false, 2, [1 2 Inf 3]
    '2, mixed', false, 2, [1 2 NaN Inf 3]
    '2, complex', false, 2, 2i
    '3, valid', true, 3, 1:5
    '3, nan', false, 3, [1 2 NaN 3]
    '3, inf', true, 3, [1 2 Inf 3]
    '3, mixed', false, 3, [1 2 NaN Inf 3]
    '3, complex', false, 3, 2i
    '4, valid', true, 4, 1:5
    '4, nan', true, 4, [1 2 NaN 3]
    '4, inf', true, 4, [1 2 Inf 3]
    '4, mixed', true, 4, [1 2 NaN Inf 3]
    '4, complex', false, 4, 2i
    };
name = 'test name';
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.defined(tests{t,[4,3]}, name, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error header');
            assert(contains(ME.message, name), 'invalid error message');
            
        else
            dash.assert.defined(tests{t,[4,3]}, name, header);
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = indices

a = ones(3,3,3);
a(:,:,:) = [];

tests = {
    % test, should succeed, indices, dimension length, name, logical name,
    % linear name, output 
    'logical', true, [true;false;true;false], 4, [], [], [], [1;3]
    'linear', true, [4 7 1 1 9], 10, [], [], [], [4 7 1 1 9]
    'empty', true, [], 10, [],[],[], []
    'empty array', true, a, 10, [],[],[], []
    'not indices', false, struct('a',1), 5, [], [], [], []
    'not vector', false, [1 2;3 4], 4, [], [], [], []
    'logical wrong length', false, [true;true;false], 4, 'test1', 'test2', [], []
    'linear not positive', false, -1, 4, 'test1', [], [], []
    'linear not integer', false, 2.2, 4, 'test1', [], [], []
    'linear too large', false, 5, 4, 'test1', [], 'test2', []
    };
testHeader = 'test:header';
   
try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.indices(tests{t,3:7}, testHeader);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, testHeader), tests{t,1}, 'header');
            if ~isempty(tests{t,6})
                assert(contains(ME.message, tests{t,6}), 'message');
            end
            if ~isempty(tests{t,7})
                assert(contains(ME.message, tests{t,7}), 'message');
            end

        else
            output = dash.assert.indices(tests{t,3:7}, testHeader);
            assert(isequal(output, tests{t,8}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = indexCollection

tests = {
    'direct, logical', true, [false;false;true], 1, 3, [], {3}
    'direct, linear', true, [5 2 6 7], 1, 10, [], {[5 2 6 7]}
    'cell, mixed', true, {true(5,1), 1:6, false(18,1)}, 3, [5 7 18], [], {(1:5)', 1:6, NaN(0,1)}
    'not collection', false, struct('a',1), 5, [], [], []
    'wrong number of index vectors', false, {true(5,1), 1:3, 4:6}, 4, [], [], []
    'logical wrong length', false, {true(6,1), 1:3}, 2, [10 10], [], []
    'linear too large', false, {true(5,1), 200:300}, 2, [5 10], [], [] 
    'custom error, bad collection', false, struct('a',1), 1, 6, [], []
    'custom error, bad index', false, true(5,1), 1, 6, "test message", []
    };
testHeader = 'test:header';

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.indexCollection(tests{t,3:6}, testHeader);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, testHeader), 'header');
            if ~isempty(tests{t,6})
                assert(contains(ME.message, tests{t,6}), 'message');
            end

        else
            output = dash.assert.indexCollection(tests{t,3:6}, testHeader);
            assert(isequal(output, tests{t,7}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = additiveIndices

a = ones(3,3,3);
a(:,:,:) = [];

tests = {
    % test, should succeed, indices, name, output
    'indices', true, -2:2, [], -2:2
    'invalid indices', false, [1.1 2.2], 'test', []
    'empty', true, [], [], []
    'empty array', true, a, [], []
    'not indices', false, struct('a',1), 'test', []
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.additiveIndices(tests{t,3:4}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'header');
            assert(contains(ME.message, tests{t,4}), 'message');

        else
            output = dash.assert.additiveIndices(tests{t,3:4}, header);
            assert(isequal(output, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = additiveIndexCollection

tests = {
    'direct', true, -3:3, 1
    'cell, 1', true, {-3:3}, 1
    'cell, multiple', true, {-1:4,-3:3,5:8}, 3
    'not collection', false, struct('a',1), 1
    'wrong number of index vectors', false, {-1:4,-3:3}, 3
    'invalid indices', false, {[-1 -2 -3], [1.1 2.2]}, 2
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.additiveIndexCollection(tests{t,3:4}, 'test', header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error header');
            
        else
            dash.assert.additiveIndexCollection(tests{t,3:4}, 'test', header);
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = fileExists(testpath)

% Move to test data
home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);

% Add to path
onpath = fullfile(testpath, 'on-path');
addpath(genpath(testpath));
rmpath(genpath(testpath));
addpath(onpath);
removeTests = onCleanup( @()rmpath(onpath) );

% Get file paths
relfile = fullfile('on-path', 'test-file.txt');
abson = fullfile(testpath, 'on-path', 'test-file.txt');
absoff = fullfile(testpath, 'off-path', 'test-file.txt');
noext = fullfile(testpath, 'on-path', 'test-file');
notfile = fullfile(testpath, 'not-a-file.txt');

% Run rests
tests = {
    'existing file on path', true, relfile, [], string(abson)
    'absolute file off path', true, absoff, [], string(absoff)
    'add extension', true, noext, '.txt', string(abson)
    'missing file', false, notfile, [], []
    };
testHeader = 'test:header';

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.fileExists(tests{t,3:4}, testHeader);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, testHeader), 'header');

        else
            output = dash.assert.fileExists(tests{t,3:4}, testHeader);
            assert(isequal(output, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end    

end
function[] = nameValue

tests = {
    'name values', true, {'name1', 5, "name2", 6}, [], [], {["name1";"name2"], {5;6}}
    'odd inputs', false, {'name1', 5, 'name2'}, [], [], []
    'not name value', false, {["name1","name2"], 5, 'name3', 6}, [], [], []
    'custom error', false, 5, 3, 'extra info', []
    };
testHeader = 'test:header';

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.assert.nameValue(tests{t,3:5}, testHeader);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, testHeader), 'header');

        else
            [names, values] = dash.assert.nameValue(tests{t,3:5}, testHeader);
            assert(isequal(names, tests{t,6}{1}), 'names');
            assert(isequal(values, tests{t,6}{2}), 'values');
        end
    end
catch cause
    ME = MException('test:failed', tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end       

end
function[] = uniqueSet

tests = {
    'unique', true, [1;2;3;4;5], []
    'not unique', false, [1;2;2], []
    'custom error', false, [1;2;2], 'my variable'
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,2};
    if shouldFail
        try
            dash.assert.uniqueSet(tests{t,3}, tests{t,4}, testHeader);
            error(tests{t,1});
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        if ~isempty(tests{t,4})
            assert(contains(ME.message, tests{t,4}), tests{t,1});
        end
        
    else
        dash.assert.uniqueSet(tests{t,3});
    end
end

end