function[] = tests
%% dash.metadata.tests  Unit-tests for dash.metadata subpackage
% ----------
%   dash.metadata.tests  
%   Runs the tests. If successful, exits silently. Otherwise, throws an
%   error at the first failed test
%
%   Tests the following functions:
%   assert, assertField, bothNaN, define, hasDuplicateRows
% ----------

%% bothNaN

tests = {...
    NaN, 5, false, 'first NaN';
    5, NaN, false, 'second NaN';
    NaN, NaN, true, 'both NaN';
    NaN(5,1), NaN(5,1), false, 'both NaN vectors';
    false, "test", false, 'non-numeric inputs';
    };

for t = 1:size(tests,1)
    result = dash.metadata.bothNaN(tests{t,1}, tests{t,2});
    assert(result==tests{t,3}, 'bothNaN: %s', tests{t,4});
end
    

%% hasDuplicateRows

tests = {...
    (1:5)', false, 'unique numeric rows';...
    ["a";"b";"c"], false, 'unique string rows';...
    ones(5,1), true, 'repeated numeric';...
    ["A","B";"A","C"], false, 'repeated elements but unique rows';...
    };

for t = 1:size(tests,1)
    result = dash.metadata.hasDuplicateRows(tests{t,1});
    assert(result == tests{t,2}, 'hasDuplicateRows:%s', tests{t,3});
end

%% assertField







end