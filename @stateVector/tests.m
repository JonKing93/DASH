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
assert(isequal(sv.label_, ""), 'label');
assert(isequal(sv.iseditable, true), 'editable');
assert(isequal(sv.nVariables, 0), 'nVariables');
assert(isequal(sv.variableNames, strings(0,1)), 'variable names');
assert(isequal(sv.variables_, []), 'variables');
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






