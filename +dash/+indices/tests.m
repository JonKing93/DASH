function[] = tests
%% dash.indices.tests  Unit tests for the dash.indices subpackage
% ----------
%   dash.indices.tests
%   Runs the units tests. If the tests pass, exits silently.
%   If the tests fail, prints the first failed test to the console.
% ----------
%
% <a href="matlab:dash.doc('dash.indices.tests')">Documentation Page</a>

strided;
keep;
limits;
fromLimits;
subscript;

end

function[] = strided

tests = {...
    % input, output, description
    5, 5, 'single index';...
    3:8, 3:8, 'already strided';...
    8:-1:3, 3:8, 'reverse strided';...
    [7 8 2 3 9 15 8 6], 2:15, 'mixed';...
    [20 2 4 8], 2:2:20, 'stride not equal to 1';...
    [4:4:12, 16:8:40], 4:4:40, 'mixed strides';...
    };

for t = 1:size(tests,1)
    assert( isequal(dash.indices.strided(tests{t,1}), tests{t,2}), 'strided: %s', tests{t,3});
end

end
function[] = keep

tests = {...
    % requested, loaded, match output, description
    [1 3 4 6], 1:6, [1 3 4 6], 'standard case';...
    [7 8 1 3], 1:8, [7 8 1 3], 'mixed direction';...
    [16 8 12], 8:4:16, [3 1 2], 'strided';...
    };

for t = 1:size(tests,1)
    keep = dash.indices.keep( tests{t,1}, tests{t,2} );
    assert(isequal(keep, tests{t,3}), tests{t,4});
end

end
function[] = limits

tests = {
    '1', [1;2;3;4], [1 1;2 3;4 6;7 10]
    '2', [3;3;5], [1 3;4 6;7 11]
    };

try
    for t = 1:size(tests,1)
        lim = dash.indices.limits(tests{t,2});
        assert(isequal(lim, tests{t,3}), tests{t,1});
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = fromLimits

limits = [1 5;1 9;4 18];
output = dash.indices.fromLimits(limits);
indices = {(1:5)', (1:9)', (4:18)'};
assert(isequal(output, indices), 'output');

end