function[] = tests
%% dash.string.tests  Unit tests for the dash.string package
% ----------
%   dash.string.tests
%   Runs the tests. If successful, exits silently. If failed, throws error
%   at first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.string.tests')">Documentation Page</a>

list;
elementName;

size_;
nonscalarObj;

indexedDimension;

end

function[] = list

tests = {
    % description, input, match output
    'one element', {"a"}, '"a"';
    'two elements', {["a","b"]}, '"a" and "b"'
    'three elements', {["a","b","c"]}, '"a", "b", and "c"'
    '>3 elements', {["a","b","c","d"]}, '"a", "b", "c", and "d"'
    'integers', {[1 2 3 4]}, '1, 2, 3, and 4'
    'string conjunction', {["a","b"], 'or'}, '"a" or "b"'
    'integer conjunction', {[1 2 3 4],'or'}, '1, 2, 3, or 4'
};

for t = 1:size(tests,1)
    output = dash.string.list(tests{t,2}{:});
    assert(isequal(output, tests{t,3}), tests{t,1});
end

end
function[] = elementName

tests = {
    'single element', 1, "item", 1, "item"
    'multiple elements', 3, "item", 5, "item 3"
    'first element', 1, "item", 5, "item 1"
    };

try
    for t = 1:size(tests,1)
        name = dash.string.elementName(tests{t,2:4});
        assert(strcmp(name, tests{t,5}), tests{t,1});
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = size_

tests = {
    'two', [2 1], '2x1'
    'five', [2 0 3 1 6], '2x0x3x1x6'
    };
try
    for t = 1:size(tests,1)
        siz = dash.string.size(tests{t,2});
        assert(strcmp(siz, tests{t,3}), tests{t,1});
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = nonscalarObj

tests = {
    'print size', NaN(2,3,3), 'test', sprintf('  2x3x3 test array\n\n')
    'print N', NaN(3,3,3,3,3), 'test', sprintf('  5-D test array\n\n')
    'empty size', NaN(2,3,0,4), 'test', sprintf('  2x3x0x4 empty test array\n\n')
    'empty N', NaN(2,0,2,2,2,2), 'test', sprintf('  6-D empty test array\n\n')
    };

try
    for t = 1:size(tests,1)
        info = dash.string.nonscalarObj(tests{t,2:3});
        assert(strcmp(info, tests{t,4}), tests{t,1});
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = indexedDimension

tests = {
    'named single dimension', 'lat', 1, false, 'the "lat" dimension'
    'named multiple dimension', 'lat', 3, true, 'the "lat" dimension'
    'unnamed single dimension', "", 1, false, 'the dimension'
    'unnamed multiple dimension', "", 3, true, 'indexed dimension 3'
    };

try
    for t = 1:size(tests,1)
        [indexName, dimName] = dash.string.indexedDimension(tests{t,2:4});

        assert(strcmp(dimName, tests{t,5}), [tests{t,1}, ' dimension']);
        t6 = ['the indices for ', tests{t,5}];
        assert(strcmp(indexName, t6), [tests{t,1}, ' indices']);
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end