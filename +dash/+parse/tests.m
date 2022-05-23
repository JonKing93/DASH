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
nameValue;
nameValueOrCollection;

inputOrCell;
stringsOrIndices;
switches;

constructorInputs;

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
function[] = nameValueOrCollection

tests = {
    % description, should succeed, inputs, outputs
    'name value pairs', true, {'string','hello','number',5.5,'option',NaN(4,4)}, ["string";"number";"option"], {'hello';5.5;NaN(4,4)}
    'collection', true, {["string","number","option"], {'hello',5.5,NaN(4,4)}}, ["string";"number";"option"], {'hello';5.5;NaN(4,4)}
    'single input', false, {'flag'}, [], []
    'non vector names', false, {["a","B";"c","D"], {1,2;3,4}}, [], []
    'invalid names', false, {5, 5}, [], []
    'single value array', true, {'flag', 5}, "flag", {5}
    'single value cell', true, {'flag', {5}}, "flag", {5}
    'invalid pairs', false, {'a',1,'b'}, [], []
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.parse.nameValueOrCollection(tests{t,3},[],[],[],header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            [names, values] = dash.parse.nameValueOrCollection(tests{t,3});
            assert(isequal(names, tests{t,4}), 'names');
            assert(isequaln(values, tests{t,5}), 'values');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
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
function[] = stringsOrIndices

strs = ["a","b","c","d"];
tests = {
    'strings', true, ["d","b"], [4 2]
    'string array', false, ["a""b";"c""d"], []
    'strings not in list', false, "bad", []
    'indices',true, [4 2 2], [4 2 2]
    'invalid indices',false, [1 2.2], []
    'invalid type', false, datetime(1,1,1), []
    };
header = 'test:header';

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.parse.stringsOrIndices(tests{t,3}, strs, [],[],[],[], header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            indices = dash.parse.stringsOrIndices(tests{t,3}, strs);
            assert(isequal(indices, tests{t,4}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = switches

strs = {["a","all"],["e","error"],["o","overwrite"]};
tests = {
    'string logical', true, ["a","error","e","all"], strs(1:2), 4, [false true true false]'
    'string numeric', true, ["a","overwrite","o","error"], strs, 4, [0 2 2 1]'
    'logical', true, [false true true false], strs(1:2), 4, [false true true false]'
    'numeric', true, [0 2 2 1], strs, 4, [0 2 2 1]'
    'scalar state', true, 2, strs, 4, 2
    'incorrect number of switches', false, [1 2], strs, 4, []
    'numeric for logical', false, 1, strs(1:2), 1, []
    'logical for numeric', false, true, strs, 1, []
    'invalid numeric', false, 7, strs, 1, []
    'invalid string', false, "b", strs, 1, []
    'invalid input', false, datetime(1,1,1), strs, 1, []
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                dash.parse.switches(tests{t,3:5},[],[],header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            state = dash.parse.switches(tests{t,3:5});
            assert(isequal(state, tests{t,6}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

