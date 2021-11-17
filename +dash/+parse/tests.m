function[] = tests
%% dash.parse.tests  Unit tests for the dash.parse package
% ----------
%   dash.parse.tests
%   Runs the tests. If successful, exits silently. If failed, throws error
%   at first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.parse.tests')">Documentation Page</a>

vararginFlags;
inputOrCell;
nameValue;

end

function[] = vararginFlags

tests  = {
    % description, input, spacing, nPrevious, should pass, output
    'all flags', {'option1', 'name2', 'dim3'}, [], [], true, ["option1";"name2";"dim3"];
    'mixed string and char flags', {'option1',"name2",'dim3'}, [], [], true, ["option1";"name2";"dim3"];
    'spaced flags', {'option',5,'flag',3}, 2, [], true, ["option";"flag"];
    'not flags', {5,6,7}, [], [], false, [];
    'custom error', {5}, [], 4, false, [];
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,5};
    if shouldFail
        try
        	dash.parse.vararginFlags(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        
    else
        flags = dash.parse.vararginFlags(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        assert(isequal(flags, tests{t,6}), tests{t,1});
    end
end

end
function[] = inputOrCell

tests = {
    % description, input, nEls, input name, should succeed, match output, match wasCell
    'single array directly', 5, 1, [], true, {5}, false;
    'single array in cell', {5}, 1, [], true, {5}, true;
    'multiple arrays', {1,2,3}, 3, [], true, {1,2,3}, true;
    'not a cell vector', 5, 3, [], false, [], [];
    'incorrect number of arrays', {1 2 3}, 4, [], false, [], [];
    'custom error', {1 2 3}, 4, 'test', false, [], [];
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,5};
    if shouldFail
        try
            dash.parse.inputOrCell(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        catch ME
        end
        assert(contains(ME.identifier, testHeader));
        
    else
        [input, wasCell] = dash.parse.inputOrCell(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        assert(isequal(input, tests{t,6}) && wasCell==tests{t,7}, tests{t,1});
    end
end

end
function[] = nameValue

flags = ["flag1","flag2","flag3"];
defaults = {1,2,3};

tests = {
    % description, inputs, input name, should succeed, match output
    'no inputs', {}, [], true, {1,2,3};
    'some flags', {'flag2', 5}, [], true, {1,5,3};
    'all flags, unordered', {'flag2', 5, 'flag3', 6, 'flag1', 4}, [], true, {4,5,6};
    'repeated flags', {'flag2', 5, 'flag2', 5}, [], false, [];
    'not Name,Value pairs', {1,2,3}, [], false, [];
    'custom error', {1,2,3}, 5, false, [];
    };
testHeader = 'test:header';

for t = 1:size(tests, 1)
    shouldFail = ~tests{t,4};
    if shouldFail
        try
            dash.parse.nameValue(tests{t,2}, flags, defaults, tests{t,3}, testHeader);
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        
    else
        output = cell(1,3);
        [output{:}] = dash.parse.nameValue(tests{t,2}, flags, defaults, tests{t,3}, testHeader);
        assert(isequal(output, tests{t,5}), tests{t,1});
    end
end

end   