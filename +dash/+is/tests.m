function[] = tests
%% dash.is.tests  Implement unit tests for the dash.is subpackage
% ----------
%   dash.is.tests
%   Runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
% ----------
%   
% <a href="matlab:dash.doc('dash.is.tests')">Documentation Page</a>

charrow;
str;
string;
strflag;
strlist;

integers;
positiveIntegers;

url;
uniqueSet;

end

function[] = charrow
tests = {
    'char row', 'test', true
    'string scalar', "test", false
    'non-text', 6, false
    };

try
    for t = 1:size(tests,1)
       out = dash.is.charrow(tests{t,2});
       assert(out==tests{t,3}, 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end
end
function[] = str
tests = {
    'string',strings(5,4), true
    'cellstring', {'a','b';'c','d'}, true
    'char', 'test', false
    'non-text', 5, false
    };
try
    for t = 1:size(tests,1)
       out = dash.is.str(tests{t,2});
       assert(out==tests{t,3}, 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end
end
function[] = string

tests = {
    'char row', 'test', true
    'string array', strings(3,3,3), true
    'cellstring array', {'a','b';'c','d'}, true
    'non-text', 5, false
    };
try
    for t = 1:size(tests,1)
       out = dash.is.string(tests{t,2});
       assert(out==tests{t,3}, 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end
end
function[] = strflag

% Build test values
strScalar = "test";
charRow = 'test';

tests = {...
    % input, should pass, description
    "test", true, "string scalar";...
    'test', true, 'character row vector';...
    [strScalar, strScalar], false, "string vector";...
    charRow', false, "char column";...
    [charRow;charRow], false, "char matrix";...
    [], false, "empty";...
    5, false, "numeric";...
    true, false, "logical true";...
    false, false, "logical false"
    };

% Test each value
nTests = size(tests, 1);
for t = 1:nTests
    assert( dash.is.strflag(tests{t,1}) == tests{t,2}, "strflag: %s", tests{t,3} );
end

end
function[] = strlist

charRow = 'a character row vector';
strRow = ["test1", "test2"];
cellstrRow = {'test1','test2'};

tests = {...
    % input, should pass, description
    strRow, true, "string row vector";...
    strRow', true, "string column vector";...
    charRow, true, "character row vector";...
    cellstrRow(1), true, 'cellstr scalar';...
    cellstrRow, true, 'cellstr row';...
    cellstrRow', true, 'cellstr column';...
    ...
    [strRow;strRow], false, "string matrix";...
    [cellstrRow;cellstrRow], false, "cellstr matrix";...
    charRow', false, "character column vector";...
    [charRow;charRow], false, "character matrix";...
    cat(3, charRow, charRow), false, 'char array';...
    ...
    [], false, 'empty';...
    5, false, 'numeric';...
    true, false, 'logical true';...
    false, false, 'logical false';
    };

for t = 1:size(tests,1)
    assert( dash.is.strlist(tests{t,1}) == tests{t,2}, "strlist: %s", tests{t,3} );
end

end

function[] = integers
tests = {
    'all ints', -4:4, true, []
    'not all ints', [1 2 3.3 4 5.5], false, 3
    };

try
    for t = 1:size(tests,1)
       [tf, loc] = dash.is.integers(tests{t,2});
       assert(tf==tests{t,3}, 'tf');
       assert(isequal(loc, tests{t,4}), 'loc');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end
end
function[] = positiveIntegers

tests = {
    'pass', 1:4, true, []
    'non-positive', 0:4, false, 1
    'non-integer', [1 2 3.3 4 5.5], false, 3
    };

try
    for t = 1:size(tests,1)
       [tf, loc] = dash.is.positiveIntegers(tests{t,2});
       assert(tf==tests{t,3}, 'tf');
       assert(isequal(loc, tests{t,4}), 'loc');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end
end

function[] = url

tests = {
    % description, string, result
    'starts with http://', 'http://my/url.html', true;
    'starts with https://', 'https://my/url.html', true;
    'does not start with http*', 'a/file/path', false;
    'contains http:// but not at start', 'test_http://_test', false;
    'contains https:// but not at start', 'test_https://_test', false;
    };

for t = 1:size(tests,1)
    result = dash.is.url(tests{t,2});
    assert(result == tests{t,3}, tests{t,1});
end

end
function[] = uniqueSet

tests = {
    % description, input, rows, tf, check repeats, repeat
    'vector with unique elements', 1:5, false, true, [];
    'vector with repeat elements', [1 2 3 2], false, false, [2;4];
    'matrix with unique rows', [1 2;2 3;3 4], true, true, [];
    'matrix with repeat rows', [1 2;2 3;1 2], true, false, [1;3];
    'matrix with unique rows, shuffled elements', [1 2; 2 1], true, true, [];
    };

for t = 1:size(tests,1)
    [tf, repeat] = dash.is.uniqueSet(tests{t,2}, tests{t,3});
    assert(tf==tests{t,4} && isequal(repeat, tests{t,5}), tests{t,1});
end

end