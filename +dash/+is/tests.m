function[] = tests
%% dash.is.tests  Implement unit tests for the dash.is subpackage
% ----------
%   dash.is.tests
%   Runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
% ----------
%   Tests the following functions: strflag, strlist

strflag;
strlist;
url;
uniqueSet;

end

function[] = strflag

% Build test values
strScalar = "test";
charRow = 'test';

tests = {...
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