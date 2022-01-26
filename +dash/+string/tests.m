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
error('list conjunction');
size;
indexedDimension;

end

function[] = list

tests = {
    % description, input, match output
    'one element', "a", '"a"';
    'two elements', ["a","b"], '"a" and "b"'
    'three elements', ["a","b","c"], '"a", "b", and "c"'
    '>3 elements', ["a","b","c","d"], '"a", "b", "c", and "d"'
    'integers', [1 2 3 4], '1, 2, 3, and 4'
};

for t = 1:size(tests,1)
    output = dash.string.list(tests{t,2});
    assert(isequal(output, tests{t,3}), tests{t,1});
end

end