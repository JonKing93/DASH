function[] = tests
%% stateVector.tests  Implement unit tests for the stateVector class
% ----------
%   stateVector.tests
%   Runs the unit tests. If successful, exits silently. Otherwise, throws
%   an error at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('stateVector.tests')">Documentation Page</a>

% Move to test folder
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-2);
testpath = fullfile(dash{:}, 'testdata', 'stateVector');

home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);

%%%
variableIndices
%%%

% Run the tests
constructor;
label;
name;
assertEditable;

length_;
members;
updateLengths;

add;
remove;
extract;
append;
variableIndices;

variables;
rename;
assertValidNames;

dimensions;
dimensionIndices;

design;
sequence;
metadata;
mean_;
weightedMean;
editVariables;

overlap;

couple;
uncouple;
autocouple;
coupleDimensions;

coupledIndices;
coupledVariables;
couplingInfo;

build;
addMembers;
buildEnsemble;

assertUnserialized;
serialize;
deserialize;

info;
variable;
disp_;
dispVariables;
dispCoupled;

relocate;
validateGrids;
parseGrids;
buildGrids;

end

function[] = constructor

%% No label

sv = stateVector;
svv = dash.stateVectorVariable;
svv(1,:) = [];
assert(isequal(sv.label_, ""), 'label');
assert(isequal(sv.iseditable, true), 'editable');
assert(isequal(sv.nVariables, 0), 'nVariables');
assert(isequal(sv.variableNames, strings(0,1)), 'variable names');
assert(isequal(sv.variables_, svv), 'variables');
assert(isequal(sv.gridfiles, strings(0,1)), 'gridfiles');
assert(isequal(sv.allowOverlap, false(0,1)), 'overlap');
assert(isequal(sv.lengths, NaN(0,1)), 'lengths');
assert(isequal(sv.coupled, true(0,0)), 'coupled');
assert(isequal(sv.autocouple_, true(0,1)), 'autocouple');
assert(isequal(sv.unused, []), 'unused');
assert(isequal(sv.subMembers,[]), 'subMembers');
assert(isequal(sv.isserialized, false), 'is serialized');
assert(isequal(sv.nMembers_serialized, []), 'nMembers');
assert(isequal(sv.nUnused_serialized,[]), 'nUnused');
assert(isequal(sv.nEnsDims_serialized,[]), 'nEnsDims_serialized');

%% Label

sv = stateVector('test label');
assert(isequal(sv.label_, "test label"), 'set label');

%% Invalid label

try
    sv = stateVector(["invalid","label"]);
    error('invalid label');
catch ME
end

end
function[] = label

sv = stateVector;
sv2 = sv;
sv2.label_ = "existing";
svt = sv;
svt.label_ = "test";

tests = {
    'return empty label', true, sv, {}, ""
    'return label', true, sv2, {}, "existing"
    'set empty label', true, sv, {'test'}, svt
    'set existing label', true, sv2, {'test'}, svt
    'invalid label', false, sv, {["invalid","label"]}, []
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,3};
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.label(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, "DASH:stateVector:label"), 'invalid error');
            
        else
            out = obj.label(tests{t,4}{:});
            assert(isequaln(out, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = name

sv = stateVector;
sv2 = stateVector('test label');

tests = {
    'empty name, no caps', sv, {}, "the state vector"
    'labeled name, no caps', sv2, {}, 'state vector "test label"'
    'empty, lower', sv, {false}, "the state vector"
    'labeled, lower', sv2, {false}, 'state vector "test label"'
    'empty, caps', sv, {true}, "The state vector"
    'labeled, caps', sv2, {true}, 'State vector "test label"'
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        out = obj.name(tests{t,3}{:});
        assert(strcmp(out, tests{t,4}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = assertEditable

sv = stateVector;
sv2 = sv;
sv2.iseditable = false;

svArray1 = [sv,sv;sv sv];
svArray2 = [sv,sv2;sv sv];

tests = {
    'scalar editable', true, sv
    'scalar finalized', false, sv2
    'array all editable', true, svArray1
    'array with finalized', false, svArray2
    };
header = "test:header";


try
    for t = 1:size(tests,1)
        obj = tests{t,3};
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.assertEditable(header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            obj.assertEditable;
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = length_

sv = stateVector;
sv = sv.add(["A","B","C"], 'test-lltr');
sv.lengths = [10;500;2000];

tests = {
    'empty', {}, 2510
    '0', {0}, 2510
    '-1', {-1}, [10;500;2000]
    'indexed variables', {[3 1 1]}, [2000;10;10]
    };

try
    for t = 1:size(tests,1)
        out = sv.length(tests{t,2}{:});
        assert(isequal(out, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = members

sv = stateVector;
sv2 = sv;
sv2.subMembers = {rand(4,2), rand(4,3)};
sv2.iseditable = false;
sv3 = sv.serialize;
sv3.nMembers_serialized = 7;
sv4 = sv3;
sv4.iseditable = false;

tests = {
    'no members, unserialized', sv, 0
    'members, unserialized', sv2, 4
    'no members, serialized', sv3, 0
    'members, serialized', sv4, 7
    };

try
    for t = 1:size(tests,1)
        N = tests{t,2}.members;
        assert(isequal(N, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = updateLengths

sv = stateVector;
sv = sv.add(["A","B","C"], 'test-lltr');
sv.lengths = [1;2;3];

sv = sv.updateLengths([3 1]);
assert(isequal(sv.lengths, [6000000;2;6000000]), 'did not update');
end

function[] = add

tests = {
    'single variable'
    'multiple variables'
    'name not string'
    'invalid name'
    'repeat name in new variables'
    'repeat name with existing variables'
    'grid file path'
    'gridfile object'
    'grid filepath vector'
    'gridfile object vector'
    'invalid grid'
    'deleted grid'
    'autocouple, new'
    'autocouple, existing variables'
    'autocouple, existing variables not autocoupled'
    'no autocouple, new'
    'no autocouple, existing variables'
    'no autocouple, existing variables not autocoupled'
    'mixed autocouple'
    };

error('unfinished');

end
function[] = remove

svEmpty = stateVector;

% Indexed variables
sv = svEmpty.add(["A","B","C"], 'test-lltr');
sv1f = svEmpty.add(["B"], 'test-lltr');
sv1 = sv.remove([3 1]);
assert(isequaln(sv1, sv1f), 'indexed variables');

% All variables
sv2 = sv.remove(-1);
assert(isequaln(sv2, svEmpty), 'remove all');

end
function[] = extract

svEmpty = stateVector;
sv = svEmpty.add(["A","B","C"], 'test-lltr');

% Extract none
sv0 = sv.extract([]);
assert(isequaln(svEmpty, sv0), 'extract none');

% Extract all
sva = sv.extract([3 1 2]);
assert(isequaln(sva, sv), 'extract all');

% Duplicate extract
svB = svEmpty.add("B", 'test-lltr');
svdup = sv.extract([2 2 2 2]);
assert(isequaln(svdup, svB), 'duplicate');

% Mixed order
svAC = svEmpty.add(["A","C"], 'test-lltr');
svmix = sv.extract([3 1]);
assert(isequaln(svmix, svAC), 'mixed');

end
function[] = append

% Input vectors
sv1e = stateVector('vector 1');
sv1 = sv1e.add(["A","test","var3"], 'test-lltr');
sv1na = sv1e.add(["A","test","var3"], 'test-lltr', false);
sv1c = sv1e.add(["A","test","var3"], 'test-lltr', [true false true]);

sv2e = stateVector('test 2');
sv2 = sv2e.add(["B","test2","var4"], 'test-lst');
sv2na = sv2e.add(["B","test2","var4"], 'test-lst', false);
sv2c = sv2e.add(["B","test2","var4"], 'test-lst', [false true false]);

svre = stateVector('repeats');
svr = svre.add(["A","testR","var3"], 'test-lst');

% Output vectors
sv12 = sv1e.add(["A","test","var3"], 'test-lltr');
sv12 = sv12.add(["B","test2","var4"], 'test-lst');

sv12na = sv1e.add(["A","test","var3"], 'test-lltr', false);
sv12na = sv12na.add(["B","test2","var4"], 'test-lst', false);

sve2 = sv1e.add(["B","test2","var4"], 'test-lst');

svr1 = sv1e.add(["A","test","var3"], 'test-lltr');
svr1 = svr1.add("testR", 'test-lst');

svr2 = sv1e.add("test", 'test-lltr');
svr2 = svr2.add(["A","testR","var3"], 'test-lst');

svc = sv1e.add(["A","test","var3"], 'test-lltr', [true false true]);
svc = svc.add(["B","test2","var4"], 'test-lst', [false true false]);

tests = {
    % test, should fail, sv 1, sv 2, response, output
    'append vars to vars', true, sv1, sv2, [], sv12
    'empty to empty', true, sv1e, sv2e, [], sv1e
    'vars to empty', true, sv1, sv2e, [], sv1
    'empty to vars', true, sv1e, sv2, [], sve2
    'repeat default', false, sv1, svr, [], []
    'repeat error 1', false, sv1, svr, 0, []
    'repeat error 2', false, sv1, svr, 'error', []
    'repeat first 1', true, sv1, svr, 1, svr1
    'repeat first 2', true, sv1, svr, 'first', svr1
    'repeat second 1', true, sv1, svr, 2, svr2
    'repeat second 2', true, sv1, svr, 'second', svr2
    'autocouple', true, sv1, sv2, [], sv12
    'no autocouple', true, sv1na, sv2na, [], sv12na
    'mixed autocouple', true, sv1c sv2c, [], svc
    };
header = "DASH:stateVector:append";

try
    for t = 1:size(tests,1)
        sv = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.append(tests{t,4:5});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = sv.append(tests{t,4:5});
            assert(isequaln(out, tests{t,6}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = variableIndices

sv = stateVector;
sv = sv.add(["A","test","tes","a_long_name","variable5"], 'test-lltr');


tests = {
    % test, should succeed, allow repeat, output
    'index', true, 3, true, 3
    'indices', true, [2 4 3], true, [2 4 3]
    'repeat mixed indices', true, [3 3 1 4], true, [3 3 1 4]
    'invalid index', false, 10, true, []
    
    'name', true, "test", true, 2
    'names', true, ["test","A"], true, [2 1]
    'repeat mixed names', true, ["test","test","variable5","A"], true, [2 2 5 1]
    'invalid name', false, "blarn", true, []

    'invalid variable', false, struct, true, []
    'empty', true, [], true, []
    'unallowed repeat index', false, [2 2], false, []
    'unallowed repeat name', false, ["test","test"], false, []
    'name is substring of other name', true, "tes", true, 3
    'only substring of name', false, "a_long", true, []
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.variableIndices(tests{t,3:4}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = sv.variableIndices(tests{t,3:4}, header);
            assert(isequal(out, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
    



