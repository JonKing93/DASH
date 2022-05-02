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
uncouple;
couple;
autocouple;
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
serialization;

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

% Extract mixed all
sva = sv.extract([3 1 2]);
assert(isequaln(sva, sv), 'extract mixed all');

% Extract all
sva = sv.extract(-1);
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
    % test, should succeed, input, allow repeat, output
    '-1', true, -1, true, 1:5
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
    
function[] = variables

sve = stateVector;
names = ["A";"test";"var3";"another"];
sv = sve.add(names, 'test-lltr');

tests = {
    'no input', true, sv, {}, names
    'empty', true, sv, {[]}, names
    '-1', true, sv, {-1}, names
    'list all, but no variables', true, sve, {}, strings(0,1)
    'index', true, sv, {2}, "test"
    'mixed repeat indices', true, sv, {[3 1 1 4]}, ["var3";"A";"A";"another"]
    'invalid index', false, sv, {10}, []
    'invalid input', false, sv, {struct}, []
};
header = "DASH:stateVector:variables";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.variables(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = obj.variables(tests{t,4}{:});
            assert(isequal(out, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = rename

sve = stateVector;
sv = sve.add(["A","test",'var3',"another"], 'test-lltr');
sv2 = sve.add(["A","X","var3","Z"], 'test-lltr');

tests = {
    'indices', true, [2 4], ["X","Z"]
    'misordered indices', true, [4 2], ["Z","X"]
    'names', true, ["test","another"], ["X","Z"]
    'misordered names', true, ["another","test"], ["Z","X"]

    'invalid index', false, 7, "Q"
    'invalid old name', false, "blarn", "Q"
    'invalid variables', false, struct, "Q"

    'invalid new name', false, 2, "123q"
    'repeat indices', false, [2 2], ["Q","Q"]
    'repeat old names', false, ["test","test"], ["Q","Q"]
    'repeat new names', false, [2 4], ["Q","Q"]
    'duplicates existing', false, [2 4], ["A","B"]
    };
header = "DASH:stateVector:rename";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.rename(tests{t,3:4});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = sv.rename(tests{t,3:4});
            assert(isequaln(out, sv2), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = assertValidNames

sv = stateVector;
sv = sv.add(["A","test","var3"], 'test-lltr');

tests = {
    'valid name', true, "Precip"
    'valid names', true, ["temp","precip","slp"]
    'matlab keyword', false, "for"
    'punctuation', false, "asd,fgh"
    'starts with number', false, "12dfg"
    'contains duplicates', false, ["temp","precip","temp"]
    'duplicates existing vars', false, ["temp","test"]
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.assertValidNames(tests{t,3}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            sv.assertValidNames(tests{t,3}, header);
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = dimensions

sv = stateVector;
sv = sv.add(["Temp","Precip"], 'test-lltr', false);
sv = sv.add(["SLP","X"], 'test-lst', false);
sv = sv.design(-1, ["time","run"], 'ensemble');

dims = ...
    {["lon"    "lat"    "time"    "run"]
     ["lon"    "lat"    "time"    "run"]
     ["lev"    "site"    "time"        ]
     ["lev"    "site"    "time"        ]};

state = {["lon","lat"];["lon","lat"];["lev","site"];["lev","site"]};
ens = {["time","run"];["time","run"];"time";"time"};

tests = {
    'no input', {}, dims
    'empty', {[]}, dims
    '-1', {-1}, dims
    'indexed', {[3 1 1 4]}, dims([3,1,1,4])
    'names', {["SLP","Temp","Temp","X"]}, dims([3 1 1 4])
    
    'all A', {0, 0}, dims
    'all B', {0, 'all'}, dims
    'state A', {0, 1}, state
    'state B', {0, 'state'}, state
    'ens A', {0, 2}, ens
    'ens B', {0, 'ens'}, ens

    'single variable', {1}, dims{1}
    'single force cell', {1,[],'cell'}, dims(1)
    'single default', {1,[],'default'}, dims{1}
    'multiple force cell', {[3 1],[],'cell'}, dims([3 1])
    'multiple default', {[3 1],[],'default'}, dims([3 1])
    };

try
    for t = 1:size(tests,1)
        out = sv.dimensions(tests{t,2}{:});
        assert(isequal(out, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = dimensionIndices

sv1 = stateVector;
sv1 = sv1.add(["A","B"], "test-lltr");

sv2 = stateVector;
sv2 = sv2.add(["A","B"],["test-lltr","test-lst"]);

tests = {
    'all dims in all vars', true, sv1, ["time","lon","run"], [3 1 4;3 1 4]
    'all dims in some vars', true, sv2, ["time","lat","site"], [3 2 0;3 0 2]
    'some dims in no vars', false, sv2, ["time","bad"], []
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.dimensionIndices(1:2, tests{t,4}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            indices = obj.dimensionIndices(1:2, tests{t,4}, header);
            assert(isequal(indices, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = sequence

sv = stateVector;
sv = sv.add(["Temp","Precip"], 'test-lltr');
sv = sv.add(["SLP","X"], 'test-lst');
sv = sv.design(-1, ["time","run"], 'ensemble');

ts = (-2:2)';
rs = [1;2];

varsT = sv.variables_;
for k = 1:4
    varsT(k) = varsT(k).sequence(3, {ts}, {ts}, 'test');
end
varsTR = varsT;
varsTR(1) = varsTR(1).sequence(4, {rs}, {rs}, 'test');
varsTR(2) = varsTR(2).sequence(4, {rs}, {rs}, 'test');

svT4 = sv;
svT4.variables_ = varsT;
svT4 = svT4.updateLengths(1:4);
svT2 = sv;
svT2.variables_([1 3]) = varsT([1 3]);
svT2 = svT2.updateLengths(1:4);
svTR = sv;
svTR.variables_ = varsTR;
svTR = svTR.updateLengths(1:4);

header = "DASH:stateVector:sequence";
tests = {
    % test, should succeed, object, variables, dims, indices, metadata, output
    '-1', true, sv, {-1, "time", ts, ts}, svT4
    'indexed vars', true, sv, {[1 3], "time", ts, ts}, svT2
    'repeat vars', false, sv, {[1 1], "time", ts, ts}, header
    'invalid variable', false, sv, {"blarn", "time", 1, 1}, header

    'mixed dims', true, sv, {1:4, ["time","run"], {ts,rs}, {ts,rs}}, svTR
    'missing dim', false, sv, {1:4, "blarn", 1, 1}, header
    'none', true, svTR, {1:4, ["time","run"], "none"}, sv
    'inputs after none', false, svTR, {1:4, "time", "none", []}, 'MATLAB:TooManyInputs'
    'invalid sequence parameters', false, sv, {1:4, "time", 100000000, 1}, header
    'empty indices', true, svTR, {1:4, ["time","run"], "none"}, sv

    'wrong number indices', false, sv, {1:4, ["time","run"], {ts}, {ts,rs}}, header
    'invalid indices', false, sv, {1:4, "time", 2.2, 2.2}, header
    '1 indices cell', true, sv, {1:4, "time", {ts}, {ts}}, svT4
    '1 indices direct', true, sv, {1:4, "time", ts, {ts}}, svT4

    'wrong number metadata', false, sv, {1:4, ["time","run"], {ts,rs}, {ts}}, header
    'invalid metadata', false, sv, {1:4, "time", ts, reshape(ts,1,1,[])}, "DASH:gridMetadata"
    '1 metadata cell', true, sv, {1:4, "time", ts, {ts}}, svT4
    '1 metadata direct', true, sv, {1:4, "time", ts, ts}, svT4
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,3};
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.sequence(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, tests{t,5}), 'invalid error');
            
        else
            obj = obj.sequence(tests{t,4}{:});
            assert(isequaln(obj, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = metadata

sv = stateVector;
sv2 = sv.add(["Temp","Precip"], 'test-lltr');
sv4 = sv2.add(["SLP","X"], 'test-lst');

vars = sv2.variables_;
varsL = vars;
varsLc = vars;
varsLc0 = vars;
varsLT = vars;

for k = 1:2
    varsL(k) = varsL(k).metadata(2, 1, {(101:120)'}, [], 'test');
    varsLc(k) = varsLc(k).metadata(2, 2, {@plus}, {{100}}, 'test');
    varsLc0(k) = varsLc0(k).metadata(2, 2, {@plus}, {{}}, 'test');
    varsLT(k) = varsL(k).metadata(3, 1, {(1:1000)'}, [], 'test');
end

sv2L = sv2;
sv2Lc = sv2;
sv2Lc0 = sv2;
sv2LT = sv2;
sv4L = sv4;

sv2L.variables_ = varsL;
sv2Lc.variables_ = varsLc;
sv2Lc0.variables_ = varsLc0;
sv2LT.variables_ = varsLT;
sv4L.variables_(1:2) = varsL;

header = "DASH:stateVector:metadata";
tests = {
    '-1', true, sv2, {-1, "lat", 'set', (101:120)'}, sv2L
    'indexed', true, sv4, {1:2, "lat", 'set', (101:120)'}, sv4L
    'repeat vars', false, sv4, {[1 1 2], "lat", "set", (101:120)'}, header
    'invalid var', false, sv4, {"blarn","lat","set", (101:120)'}, header

    'multiple dims', true, sv2, {-1, ["lat","time"], "set", {(101:120)',(1:1000)'}}, sv2LT
    'mixed dims', true, sv4, {-1, "lat", "set", (101:120)'}, sv4L
    'missing dim', false, sv2, {-1, "blarn", "raw"}, header

    'invalid type', false, sv2, {-1, "lat", 3}, header
    'raw', true, sv2L, {-1, "lat", "raw"}, sv2
    'inputs after raw', false, sv2L, {-1 "lat", "raw", []}, 'MATLAB:TooManyInputs'
    
    'set 1 direct', true, sv2, {-1, "lat", "set", (101:120)'}, sv2L
    'set 1 cell', true, sv2, {-1, "lat", "set", {(101:120)'}}, sv2L
    'no args after set', false, sv2, {-1, "lat", "set"}, 'MATLAB:minrhs'
    '2+ args after set', false, sv2, {-1, "lat", "set", (101:120)', []}, 'MATLAB:TooManyInputs'
    'incorrect number of metadata', false, sv2, {-1, ["lat","time"], "set", {(101:120)'}}, header
    'invalid metadata', false, sv2, {-1, "lat", "set", ones(20,1)}, header

    'convert', true, sv2, {-1, "lat", "convert", @plus, {{100}}}, sv2Lc
    'no args after convert', false, sv2, {-1 "lat","convert"}, 'MATLAB:minrhs'
    '3+ args after convert', false, sv2, {-1,"lat","convert",@plus,{100},[]}, 'MATLAB:TooManyInputs'
    '1 handle direct', true, sv2, {-1 "lat", "convert" @plus, {100}}, sv2Lc
    '1 handle cell', true, sv2, {-1 "lat", "convert", {@plus} {100}}, sv2Lc
    'incorrect number of handles', false, sv2, {-1, ["lat","time"], "convert", {@plus}}, header
    'invalid handles', false, sv2, {-1 "lat", "convert", 5}, header
    'no handle args', true, sv2, {-1, "lat","convert",@plus}, sv2Lc0
    '1 arg direct', true, sv2, {-1 "lat", "convert", @plus {100}}, sv2Lc
    '1 arg cell', true, sv2, {-1 "lat", "convert", @plus {{100}}}, sv2Lc
    'incorrect number of handle args', false, sv2, {-1 ["lat","time"], "convert", {@plus @plus}, {{100}}}, header
    'invalid handle args', false, sv2, {-1 "lat", "convert", @plus, 100}, header
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.metadata(tests{t,4}{:});                
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, tests{t,5}), 'invalid error');
            
        else
            obj = obj.metadata(tests{t,4}{:});
            assert(isequaln(obj, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = mean_

sv = stateVector;
sv2 = sv.add(["Temp","Precip"], 'test-lltr');
sv2 = sv2.design(-1, "time", 'ensemble');
sv4 = sv2.add(["SLP","X"], 'test-lst');

vars2L = sv2.variables_;
vars2T = sv2.variables_;
vars2LT = sv2.variables_;
vars2LToo = sv2.variables_;
vars2LToi = sv2.variables_;
vars2LTw = sv2.variables_;

for k = 1:2
    vars2L(k)  = vars2L(k).mean(2, {[]}, false, 'test');
    vars2T(k)  = vars2T(k).mean(3, {-2:2}, false, 'test');
    vars2LT(k) = vars2L(k).mean(3, {-2:2}, false, 'test');

    vars2LTw(k) = vars2LT(k).weightedMean(2:3, {1:20,1:5}, 'test');
    vars2LToo(k) = vars2L(k).mean(2:3, {[],-2:2}, [true true], 'test');
    vars2LToi(k) = vars2L(k).mean(2:3, {[],-2:2}, [true,false], 'test');
end

sv2L = sv2;
sv2L.variables_ = vars2L;
sv2L = sv2L.updateLengths(1:2);

sv2T = sv2;
sv2T.variables_ = vars2T;
sv2T = sv2T.updateLengths(1:2);

sv2LT = sv2;
sv2LT.variables_ = vars2LT;
sv2LT = sv2LT.updateLengths(1:2);

sv2LTw = sv2;
sv2LTw.variables_ = vars2LTw;
sv2LTw = sv2LTw.updateLengths(1:2);

sv2LToo = sv2;
sv2LToo.variables_ = vars2LToo;
sv2LToo = sv2LToo.updateLengths(1:2);

sv2LToi = sv2;
sv2LToi.variables_ = vars2LToi;
sv2LToi = sv2LToi.updateLengths(1:2);

sv4T2 = sv4;
sv4T2.variables_(1:2) = vars2T;
sv4T2 = sv4T2.updateLengths(1:2);

sv4L = sv4;
sv4L.variables_(1:2) = vars2L;
sv4L = sv4L.updateLengths(1:2);

header = "DASH:stateVector:mean";
tests = {
    '-1', true, sv2, {-1, "lat"}, sv2L
    'indexed', true, sv4, {1:2, "time", -2:2}, sv4T2
    'repeat vars', false, sv4, {[1 1 2], "lat"}, header
    'invalid var', false, sv4, {"blarn",["lat"]}, header
    
    'state, no indices', true, sv2, {0, "lat"}, sv2L
    'state, empty indices', true, sv2, {0, "lat", []}, sv2L
    'state, indices', false, sv2, {0 "lat", 1}, header
    'ensemble, no indices', false, sv2, {0, "time"}, header
    'ensemble, empty indices', false, sv2, {0, "time", []}, header
    'ensemble, indices', true, sv2, {0 "time", -2:2}, sv2T
    'wrong number indices', false, sv2, {0, ["lat","time"], {-2:2}}, header
    
    'mutliple dims', true, sv2, {0, ["lat","time"], {[],-2:2}}, sv2LT
    'multiple dims, some invalid indices', false, sv2, {0, ["lat","time"], {1,-2:2}}, header
    'mixed dims', true, sv4, {0, "lat"}, sv4L
    'missing dim', false, sv4, {0, "blarn"}, header

    'single omitnan', true, sv2, {0, ["lat","time"], {[],-2:2}, true}, sv2LToo
    'vector omitnan', true, sv2, {0, ["lat","time"], {[],-2:2}, [true false]}, sv2LToi
    'single nanflag', true, sv2, {0, ["lat","time"], {[],-2:2}, 'omitnan'}, sv2LToo
    'vector nanflag', true, sv2, {0, ["lat","time"], {[],-2:2}, ["omitnan","includenan"]}, sv2LToi
    'wrong number nanflag', false, sv2, {0, ["lat","time"], {[],-2:2}, true(3,1)}, header

    'none', true, sv2LT, {0, ["lat","time"], "none"}, sv2
    'inputs after none', false, sv2LT, {0, "lat", "none", []}, 'MATLAB:TooManyInputs'
    'unweighted', true, sv2LTw, {0, ["lat","time"], "unweighted"}, sv2LT
    'inputs after unweighted', false, sv2LTw, {0, "lat","unweighted", []}, 'MATLAB:TooManyInputs'
    'unweighted dimensions with no mean', false, sv2LTw, {0, ["lat","lon"], "unweighted"}, header
};

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.mean(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, tests{t,5}), 'invalid error');
            
        else
            obj = obj.mean(tests{t,4}{:});
            assert(isequaln(obj, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = weightedMean

sv = stateVector;
sv2 = sv.add(["Temp","Precip"], 'test-lltr');
sv4 = sv2.add(["SLP","X"], 'test-lst');

vars = sv4.variables_;
varsL = vars;
varsLm = vars;
varsLT2 = vars;
varsT = sv2.variables_;
for k = 1:2
    varsL(k) = varsL(k).weightedMean(2, {1:20}, 'test');
    varsLm(k) = varsLm(k).mean(2, {[]}, false, 'test');
    varsLT2(k) = varsL(k).weightedMean(3, {1:1000}, 'test');
    varsT(k) = varsT(k).weightedMean(3, {1:1000}, 'test');
end

svT = sv2;
svT.variables_ = varsT;
svT = svT.updateLengths(1:2);

svL = sv4;
svL.variables_ = varsL;
svL = svL.updateLengths(1:2);

svLm = sv4;
svLm.variables_ = varsLm;
svLm = svLm.updateLengths(1:2);

svLT2 = sv4;
svLT2.variables_ = varsLT2;
svLT2 = svLT2.updateLengths(1:2);

header = "DASH:stateVector:weightedMean";
tests = {
    '-1', true, sv2, {-1, "time", 1:1000}, svT
    'indexed', true, sv4, {1:2, "lat", 1:20}, svL
    'repeat vars', false, sv4, {[2 2], "lat", 1:20}, header
    'invalid var', false, sv4, {"blarn", "lat", 1:20}, header

    'multiple dims', true, sv4, {1:2, ["lat","time"], {1:20, 1:1000}}, svLT2
    'mixed dims', true, sv4, {1:4, "lat", 1:20}, svL
    'missing dim', false, sv4, {1:4, "blarn", 1:20}, header

    '1 weights, direct', true, sv4, {1:2, "lat", 1:20}, svL
    '1 weights, cell', true, sv4, {1:2, "lat", {1:20}}, svL
    'incorrect number of weights', false, sv4, {1:2, ["lat","time"], 1:20}, header
    'invalid weights', false, sv4, {1:2, "lat", NaN(1,20)}, header
    'array weights', false, sv4, {1:2, "lat", ones(4,5)}, header
    'empty weights', true, svL, {1:4, "lat", []}, svLm
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.weightedMean(tests{t,4}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, tests{t,5}), 'invalid error');
            
        else
            obj = obj.weightedMean(tests{t,4}{:});
            assert(isequaln(obj, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = editVariables

grid = gridfile('test-lltr');
sv = stateVector;
sv = sv.add(["T","Precip","SLP"], grid);
svv = dash.stateVectorVariable(grid);
svv = svv.mean(2, {[]}, false, 'test');
sv2 = sv;
sv2.variables_(2) = svv;

tests = {
    'success', true, 2, 2, 'mean', {{[]},false,'DASH:test'}, 'test task', sv2
    'DASH error', false, 2, 2, 'mean', {{2}, false,'DASH:test'}, 'test task', 'DASH'
    'other error', false, 2, 2, 'mean', {{[]},false,'DASH:test',1,1,1,1,1}, [], 'MATLAB:TooManyInputs'
    };

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.editVariables(tests{t,3:7});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, tests{t,8}), 'identifier');
            if ~isempty(tests{t,7})
                assert(contains(ME.message, tests{t,7}), 'message');
            end
            
        else
            out = sv.editVariables(tests{t,3:7});
            assert(isequaln(out, tests{t,8}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = overlap

sv = stateVector;
sv = sv.add(["A","B","C","D"], 'test-lltr');
sv.allowOverlap = [true;false;true;false];

svF = sv;
svF.allowOverlap = false(4,1);
svF1 = sv;
svF1.allowOverlap(1) = false;
sv2 = sv;
sv2.allowOverlap = [true;true;false;false];

tests = {
    % test, should succeed, inputs, output
    'return, no inputs', true, {}, [true;false;true;false]
    'return, -1', true, {-1}, [true;false;true;false]
    'return, indexed', true, {[1 3]}, [true;true]
    'return, repeat vars', true, {[1 1 3 4 4]}, [true;true;true;false;false]
    'return, invalid var', false, {5}, []

    'set, -1', true, {-1, false}, svF
    'set, indexed', true, {1, false}, svF1
    'set, repeat', false, {[1 1], false}, []
    'set, invalid var', false, {5, false}, []

    'single setting', true, {-1, false}, svF
    'vector setting', true, {-1, [true;true;false;false]}, sv2
    'incorrect number of settings', false, {-1 , [true;true;false]}, []
    };
header = "DASH:stateVector:overlap";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.overlap(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = sv.overlap(tests{t,3}{:});
            assert(isequaln(out, tests{t,4}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = couple

sv = stateVector;

sv0 = sv.add(["Temp","Precip","SLP"], 'test-lltr', 'manual');
sv0 = sv0.add(["A","B","C"], 'test-lst', 'manual');
sv0 = sv0.design([1 4], "time", 'ensemble');

sv1 = sv0.design(-1, "time", 'ensemble');
sv1.coupled = true(6,6);
sv2 = sv0.design([1 2 4 5], "time", 'ensemble');
sv2.coupled([2 4 5],[2 4 5]) = true;

svc = sv.add(["Temp","Precip","SLP"], 'test-lltr');
svc = svc.design(1, "time","ensemble");

svm = sv.add(["Temp","Precip","SLP","X"], 'test-lltr', [true false true false]);
svm = svm.design(1,'time','ensemble');
svm2 = svm.design(-1, 'time','ensemble');
svm2.autocouple_(:) = true;
svm2.coupled = true(4,4);
svm3 = svm.design(1:3,'time','ensemble');
svm3.autocouple_ = [true;true;true;false];
svm3.coupled = [true(1,3),false;true(1,3),false;true(1,3),false;false(1,3), true];

svf = sv.add("T",'test-lltr','manual');
svf = svf.add("X", 'test-lst', 'manual');
svf = svf.design(1, 'run', 'ensemble');

tests = {
    'empty vector', true, sv, {}, sv
    'no inputs', true, sv0, {}, sv1
    '-1', true, sv0, {-1}, sv1
    'variables', true, sv0, {[4 2 5]}, sv2

    'variables not coupled', true, sv0, {[4 2 5]}, sv2
    'variables already coupled', true, svc, {-1}, svc
    'variables mixed coupled', true, svm, {-1}, svm2

    'variables, template 1', true, sv0, {-1}, sv1
    'secondary variables', true, svm, {[1 2]}, svm3

    'repeat variables', true, sv0, {[4 2 2 4 5 2 5]}, sv2
    'invalid variables', false, sv0, {12}, []
    'empty variables', true, sv0, {[]}, sv0

    'template not in variables', true, sv0, {[2 5], 4}, sv2
    'template in variables', true, sv0, {[4 2 5], 4}, sv2
    'invalid template', false, sv0, {-1, 12}, []
    'multiple templates', false, sv0, {-1, [1 4]}, []
    'repeat unique template', true, sv0, {[2 5], [4 4 4 4]}, sv2

    'coupling failed', false, svf, {-1}, []
    };
header = "DASH:stateVector:couple";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.couple(tests{t,4}{:});
                error('test:succeeded','did not fail');
            catch ME
                if strcmp(ME.identifier, 'test:succeeded')
                    throw(ME);
                end
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = obj.couple(tests{t,4}{:});
            assert(isequaln(out, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = uncouple

sv0 = stateVector;
sv = sv0.add(["Temp","Precip","SLP","X","Y"], 'test-lltr');

sv1 = sv;
sv1.coupled = false(5,5);
sv1.coupled(1:6:end) = true;
sv1.autocouple_ = false(5,1);

sv2 = sv;
sv2.coupled([1 3 4],:) = false;
sv2.coupled(:, [1 3 4]) = false;
sv2.coupled(1:6:end) = true;
sv2.autocouple_ = [false;true;false;false;true];


tests = {
    'empty vector', true, sv0, {}, sv0
    'no inputs', true, sv, {}, sv1
    '-1', true, sv, {-1}, sv1
    'variables', true, sv, {[3 4 1]}, sv2
    'repeat variables', true, sv, {[3 4 3 3 1 4 1]}, sv2
    'empty variables', true, sv, {[]}, sv
    'invalid variables', false, sv, {10}, []
};
header = "DASH:stateVector:uncouple";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.uncouple(tests{t,4}{:});
                error('test:succeeded','did not fail');
            catch ME
                if strcmp(ME.identifier, 'test:succeeded')
                    throw(ME);
                end
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = obj.uncouple(tests{t,4}{:});
            assert(isequaln(out, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = autocouple

sv = stateVector;
sv0 = sv.add(["A","B","C","D"], 'test-lltr', 'manual');
sv1 = sv.add(["A","B","C","D"], 'test-lltr');
svm = sv.add(["A","B","C","D"], 'test-lltr', [true true false false]);
svc = sv0.couple;
sv12c = sv0.couple([1 2]);

sv2t = sv0.design(2,'time','ensemble');
svt = sv1.design(-1, 'time', 'ensemble');

svf = sv.add("A", 'test-lltr','manual');
svf = svf.add("B", 'test-lst', 'manual')';
svf = svf.design(1, 'run', 'ensemble');

header = "DASH:stateVector:autocouple";
tests = {
    'empty vector', true, sv, {}, sv
    'no inputs', true, sv0, {}, sv1
    'auto', true, sv0, {'auto'}, sv1
    'manual', true, sv1, {'manual'}, svc
    
    'auto, some current', true, svm, {true}, sv1
    'auto, no current', true, sv0, {true}, sv1
    'manual, stay same', true, sv0, {false}, sv0
    'manual, switch', true, sv1, {false}, svc

    '-1', true, sv0, {true, -1}, sv1
    'variables', true, sv0, {'a', [1 2]}, svm
    'invalid variables', false, sv0, {'a', 7}, header
    'empty variables', true, sv0, {'a', []}, sv0
    'repeat variables', true, sv0, {'a', [1 2 2 2 1]}, svm

    'template with manual', false, sv0, {'manual', 1, 1}, 'MATLAB:TooManyInputs'
    'template with existing auto', false, svm, {true, 3, 1}, strcat(header,':templateNotAllowed')
    'template with no auto', true, sv2t, {true, -1, 2}, svt
    'invalid template', false, sv0, {true, -1, 12}, header
    'multiple template', false, sv0, {true,-1,[1 2]}, strcat(header,':tooManyTemplates')
    'unique repeat template', true, sv2t, {true, -1, [2 2 2 2]}, svt

    'auto, update coupling', true, sv2t, {true, -1}, sv1
    'manual, retain coupling', true, svm, {false, -1}, sv12c
    'coupling failed', false, svf, {true}, header
    };


try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.autocouple(tests{t,4}{:});
                error('test:succeeded','did not fail');
            catch ME
                if strcmp(ME.identifier, 'test:succeeded')
                    throw(ME);
                end
            end
            assert(contains(ME.identifier, tests{t,5}), 'invalid error');
            
        else
            out = obj.autocouple(tests{t,4}{:});
            assert(isequaln(out, tests{t,5}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end



function[] = assertUnserialized

svUn = stateVector;
svSer = svUn;
svSer.isserialized = true;
svempty = svUn;
svempty(1) = [];

tests = {
    'serialized scalar', false, svSer
    'unserialized scalar', true, svUn
    'empty array', true, svempty
    'array unserialized', true, [svUn, svUn;svUn svUn];
    'array with serialized elements', false, [svUn, svSer;svUn, svUn]
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                tests{t,3}.assertUnserialized(header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            tests{t,3}.assertUnserialized(header);
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = serialization

%% Unfinalized
sv = stateVector('my sv label');
sv = sv.add(["Temp","Precip"], 'test-lltr', false);
sv = sv.add(["SLP","X"], 'test-lst', [true false]);
sv = sv.uncouple;
sv = sv.design(-1, 'time', 'ensemble');
sv = sv.couple([1 3]);
sv = sv.overlap([2 3], 'allow');

assert(~sv.isserialized, 'initial isserialized');
svs = sv.serialize;
assert(svs.isserialized, 'post isserialized');
sv2 = svs.deserialize;
assert(isequaln(sv, sv2), 'deserialized');

%% Finalized
sv = stateVector('my sv label');
sv = sv.add(["Temp","Precip"], 'test-lltr', false);
sv = sv.add(["SLP","X"], 'test-lst', false);
sv = sv.couple(1:2);
sv = sv.couple(3:4);
sv = sv.design(-1, ["time","run"], 'ensemble');

sv.iseditable = false;
sv.unused = {(1:4000)', (1:2000)'};
sv.subMembers = {rand(345,2), rand(345,1)};

svs = sv.serialize;
sv2 = svs.deserialize;
assert(isequaln(sv, sv2), 'finalized deserialized');

end


function[] = info

sv = stateVector('my sv label');
sv = sv.add(["Temp","Precip"], 'test-lltr', false);
sv = sv.add(["SLP","X"], 'test-lst', [true false]);
sv = sv.uncouple;
sv = sv.design(-1, 'time', 'ensemble');
sv = sv.couple([1 3]);
sv = sv.overlap([2 3], 'allow');
sv.iseditable = false;
sv.subMembers = {rand(345,1)};

info0 = struct('label',"my sv label",'length',22000,'members',345,...
    'variables',["Temp";"Precip";"SLP";"X"], 'coupled_variables',[], ...
    'finalized', true, 'serialized', false);
info0.coupled_variables = {["Temp";"SLP"];"Precip";"X"};

T = sv.variables_(1).info;
P = sv.variables_(2).info;
S = sv.variables_(3).info;
X = sv.variables_(4).info;
vars = [T;P;S;X];
nFields = numel(fieldnames(vars));

names = {"Temp";"Precip";"SLP";"X"};
gridfiles = mat2cell(sv.gridfiles, ones(4,1), 1);
coupled = {"SLP",strings(0,1),"Temp",strings(0,1)};
overlap = {false;true;true;false};
autocouple = {false;false;true;false};

[vars.name] = names{:};
[vars.gridfile] = gridfiles{:};
[vars.coupled_variables] = coupled{:};
[vars.allow_overlap] = overlap{:};
[vars.auto_couple] = autocouple{:};
vars = orderfields(vars, [nFields+(1:2), 1:nFields, nFields+(3:5)]);

tests = {
    'no input', true, {}, info0
    '0', true, {0}, info0
    '-1', true, {-1}, vars
    'indexed', true, {[3 1 1]}, vars([3 1 1])
    'invalid variable', false, {5}, []

    'serialized global', true, {}, info0
    'serialized variable', false, {1}, []
    };
header = "DASH:stateVector:info";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                sv.info(tests{t,3}{:});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            out = sv.info(tests{t,3}{:});
            assert(isequaln(out, tests{t,4}), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = dispVariables

%% No variables
sv = stateVector;
try
    sv.dispVariables;
catch
    error('no variables');
end

% No variables with name
try
    sv.dispVariables('test');
catch
    error('no variables with name');
end

% variables
sv = sv.add(["T","SLP"], 'test-lltr');
try
    sv.dispVariables;
catch
    error("variables");
end

% variables with name
try
    sv.dispVariables('test');
catch
    error('variables with name');
end

% Serialization link
sv.isserialized = true;
try
    sv.dispVariables;
catch
    error('serialization link');
end

clc;

end
function[] = dispCoupled

% No sets
sv = stateVector;
sets = {};
try
    sv.dispCoupled(sets);
catch
    error('no sets');
end

% Sets
sv = sv.add(["Temp","Precip","SLP","X"], 'test-lltr');
sets = {[1 2],[3 4]};
try
    sv.dispCoupled(sets);
catch
    error('coupling sets');
end

clc;

end

function[] = relocate

path1 = fullfile(pwd, "test-lltr");
path2 = fullfile(pwd, "test-lst");
badpath = fullfile(pwd, "invalid.grid");

sv = stateVector;
sv = sv.add(["Temp","Precip","SLP","X"],[path1;path1;path2;path2]);

lltr = gridfile('test-lltr');
lst = gridfile('test-lst');
invalid = gridfile.new("invalid",gridMetadata('lat',1),true);
delete(badpath);

tests = {
    '1 var, 1 path', true, 1, path1
    'vars, 1 path', true, 1:2, path1
    'vars paths', true, [1 3], [path1,path2]
    'vars repeat paths', true,[1 3 2 4],[path1,path2,path1,path2]
    'incorrect number of paths', false, 1:3, [path1,path1,path2,path2]
    'failed path', false, 1:3, [path1,badpath,path2]
    'failed 1 path', false, 1:3, path1
    'invalid path', false, 1:3, [path1,path1,path1]
    'invalid 1 path', false, 1:3 path1

    '1 var, 1 object', true, 1, lltr
    'vars, 1 object', true, 1:2, lltr
    'vars objects', true, [1 3], [lltr,lst]
    'vars repeat objects', true, [1 3 2 4], [lltr,lst,lltr,lst]
    'incorrect number of objects', false, 1:3, [lltr,lltr,lst,lst]
    'failed object', false, 1:3, [lltr,invalid,lst]
    'invalid object', false, 1:3, [lltr,lltr,lltr]

    'invalid grids', false, 1, 5
    };
header = "DASH:stateVector:relocate";

try
    for t = 1:size(tests,1)
        obj = sv;
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.relocate(tests{t,3:4});
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            obj = obj.relocate(tests{t,3:4});
            assert(isequaln(obj, sv), 'output');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = validateGrids

sv = stateVector;
sv = sv.add(["Temp","Precip"], 'test-lltr');
sv = sv.add("SLP", 'test-lst');

lltr = gridfile('test-lltr');
lst = gridfile('test-lst');

gridsValid = struct('gridfiles',lltr,'whichGrid',[1;1]);
gridsInvalid = struct('gridfiles',lst,'whichGrid',[1;1]);
gridsMixed = struct('gridfiles',lltr,'whichGrid',[1;1;1]);


tests = {
    'all valid', true, gridsValid, 1:2, 0
    'invalid grid', false, gridsInvalid, 1:2, 1
    'some invalid', false gridsMixed, 1:3, 3
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        [failed, cause] = sv.validateGrids(tests{t,3:4}, header);

        shouldFail = ~tests{t,2};
        if shouldFail
            assert(isequal(failed, tests{t,5}), 'failed index');
            assert(isa(cause,'MException') && contains(cause.identifier, header), 'cause');
        else
            assert(failed==0, 'failed index on success');
            assert(isequal(cause,[]), 'cause on success');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = parseGrids

path1 = fullfile(pwd, "test-lltr");
path2 = fullfile(pwd, "test-lst");
badpath = fullfile(pwd, "invalid.grid");

lltr = gridfile("test-lltr");
lst = gridfile("test-lst");
invalid = gridfile.new('invalid', gridMetadata('lat',1), true);
delete(badpath);

tests = {
    % test, no error, successful build, grids, nVariables, .gridfiles, .whichGrid, failed index
    '1 path, 1 var', true, true, path1, 1, lltr, 1, []
    '1 path, vars', true, true, path1, 5, lltr, ones(5,1), []
    'paths vars', true, true, [path1,path2], 2, [lltr;lst], [1;2], []
    'repeat paths vars', true, true, [path1,path1,path2], 3, [lltr;lst], [1;1;2], []
    'incorrect number of paths', false, [], [path1, path2], 3, [], [], []
    'failed path', true, false, [path1, badpath, path2], 3, [], [], 2

    '1 object, 1 var', true, true, lltr, 1, lltr, 1, []
    '1 object, vars', true, true, lltr, 5, lltr, ones(5,1), []
    'objects vars', true, true, [lltr, lst], 2, [lltr;lst], [1;2], []
    'repeat objects vars', true, true, [lltr lltr, lst], 3, [lltr;lltr;lst], [1;2;3], []
    'incorrect number of objects', false, [], [lltr, lst], 3, [], [], []
    'failed object', true, false, [lltr, invalid, lst], 3, [], [], 2

    'invalid grids', false, [], 5, 1, [], [], []
    };
header = "test:header";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        if shouldFail
            try
                stateVector.parseGrids(tests{t,4:5}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            [grids, failed, cause] = stateVector.parseGrids(tests{t,4:5}, header);
            success = tests{t,3};
            if success
                assert(isequaln(grids.gridfiles, tests{t,6}), '.gridfiles');
                assert(isequal(grids.whichGrid, tests{t,7}), '.whichGrid');
                assert(failed==0, 'failed index on success');
                assert(isequal(cause, []), 'cause on success');
            else
                assert(isequaln(grids, []), 'grids on failure');
                assert(isequal(failed, tests{t,8}), 'failed index');
                assert(isa(cause,'MException'), 'cause');
            end
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = buildGrids

lltr = gridfile('test-lltr');
lst = gridfile('test-lst');
path1 = fullfile(pwd, "test-lltr");
path2 = fullfile(pwd, "test-lst");
badpath = fullfile(pwd, "not-a-file");

tests = {
    'single path', true, path1, lltr, 1, []
    'multiple paths', true, [path1, path2], [lltr;lst], [1;2], []
    'repeat paths', true, [path1, path1, path2, path1, path2, path2], [lltr;lst], [1;1;2;1;2;2], []
    'path failed', false, [path1, badpath, path2], [], [], 2
    };

try
    for t = 1:size(tests,1)
        [grids, failed, cause] = stateVector.buildGrids(tests{t,3});

        shouldFail = ~tests{t,2};
        if shouldFail
            assert(isequal(grids, []), 'failed grids');
            assert(isequal(failed, tests{t,6}), 'failed index');
            assert(isa(cause, 'MException'), 'failed cause');
        else
            assert(isequaln(grids.gridfiles, tests{t,4}), '.gridfiles');
            assert(isequal(grids.whichGrid, tests{t,5}), '.whichGrid');
            assert(failed==0, 'failure index on success');
            assert(isequal(cause,[]), 'cause on success');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end




