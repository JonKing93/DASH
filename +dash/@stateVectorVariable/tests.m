function[] = tests
%% dash.stateVectorVariable.tests  Unit tests for the stateVectorVariable class
% ----------
%   dash.stateVectorVariable.tests
%   Runs the tests. If successful, exits silently. Otherwise, throws error
%   at the first failed test.
% ----------
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.tests')">Documentation Page</a>

% Move to test folder
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-3);
testpath = fullfile(dash{:}, 'testdata', 'dash', 'stateVectorVariable');

home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);

% Run tests
constructor;

design;
sequence;
mean_;
weightedMean;
metadata;

dimensions;
dimensionIndices;
ensembleSizes;
stateSizes;

validateGrid;
getMetadata;

finalize;
addIndices;

trim;
matchMetadata;
removeOverlap;

indexLimits;
parametersForBuild;
buildMembers1;  % Tests that the correct data is extracted from source
buildMembers2;  % Tests processing of means and sequences

serialization;  % Tests both serialize and deserialize

end

% Tests for each method
function[] = constructor

% No inputs
svv = dash.stateVectorVariable;
assert(isequal(svv.dims, strings(1,0)));
assert(isequal(svv.gridSize, NaN(1,0)));
assert(isequal(svv.isState, true(1,0)));
assert(isequal(svv.indices, cell(1,0)));
assert(isequal(svv.stateSize, NaN(1,0)));
assert(isequal(svv.ensSize, NaN(1,0)));
assert(isequal(svv.hasSequence, false(1,0)));
assert(isequal(svv.sequenceIndices, cell(1,0)));
assert(isequal(svv.sequenceMetadata, cell(1,0)));
assert(isequal(svv.meanType, zeros(1,0)));
assert(isequal(svv.meanSize, zeros(1,0)));
assert(isequal(svv.meanIndices, cell(1,0)));
assert(isequal(svv.omitnan, false(1,0)));
assert(isequal(svv.weights, cell(1,0)));
assert(isequal(svv.metadataType, zeros(1,0)));
assert(isequal(svv.metadata_, cell(1,0)));
assert(isequal(svv.convertFunction, cell(1,0)));
assert(isequal(svv.convertArgs, cell(1,0)));

% Gridfile as input
grid = gridfile('test-llt.grid');
[names, sizes] = grid.dimensions;
nDims = numel(names);

svv = dash.stateVectorVariable(grid);

assert(isequal(svv.dims, names));
assert(isequal(svv.gridSize, sizes));
assert(isequal(svv.isState, true(1,nDims)));
assert(isequal(svv.indices, cell(1,nDims)));
assert(isequal(svv.stateSize, sizes));
assert(isequal(svv.ensSize, ones(1,nDims)));
assert(isequal(svv.hasSequence, false(1,nDims)));
assert(isequal(svv.sequenceIndices, cell(1,nDims)));
assert(isequal(svv.sequenceMetadata, cell(1,nDims)));
assert(isequal(svv.meanType, zeros(1,nDims)));
assert(isequaln(svv.meanSize, zeros(1,nDims)));
assert(isequal(svv.meanIndices, cell(1,nDims)));
assert(isequal(svv.omitnan, false(1,nDims)));
assert(isequal(svv.weights, cell(1,nDims)));
assert(isequal(svv.metadataType, zeros(1,nDims)));
assert(isequal(svv.metadata_, cell(1,nDims)));
assert(isequal(svv.convertFunction, cell(1,nDims)));
assert(isequal(svv.convertArgs, cell(1,nDims)));

end

function[] = dimensions

grid = gridfile('test-lltr');
noens = dash.stateVectorVariable(grid);

svv = noens;
svv.isState(3:4) = false;

nostate = noens;
nostate.isState(:) = false;

empty = strings(1,0);
tests = {...
    'all, no flag', svv, {}, ["lon","lat","time","run"]
    'all, flag', svv, {'all'}, ["lon","lat","time","run"]
    'state', svv, {'state'}, ["lon","lat"]
    'state, no state', nostate, {'state'}, empty
    'ens', svv, {'ensemble'}, ["time","run"]
    'ens, no ens', noens, {'ensemble'}, empty
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        inputs = tests{t,3};
        dims = obj.dimensions(inputs{:});
        assert(isequal(dims, tests{t,4}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = dimensionIndices

grid = gridfile('test-lltr.grid');
svv = dash.stateVectorVariable(grid);

tests = {...
    'all present, ordered', ["lon","lat","time","run"], 1:4
    'all, unordered', ["time","lon","run","lat"], [3 1 4 2]
    'none present', ["a","b","C"], [0 0 0]
    'mixed, ordered', ["a","lon","b","run","c"], [0 1 0 4 0]
    'mixed, unordered', ["a","run","b","c","d","lat"], [0 4 0 0 0 2]
    'mixed, repeat', ["a","run","b","run","run","c","lat"], [0 4 0 4 4 0 2]
    };

try
    for t = 1:size(tests,1)
       d = svv.dimensionIndices(tests{t,2});
       assert(isequal(d, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = ensembleSizes

grid = gridfile('test-lltr');
svvState = dash.stateVectorVariable(grid);
svvEns = svvState.design(1:4, [2 2 2 2], {[],[],[],[]}, 'test');
svv = svvState.design(3:4, [2 2], {[],[]}, 'test');

tests = {
    % test, object, sizes, dim names
    'all ensemble', svvEns, [100 20 1000 3], ["lon","lat","time","run"]
    'all state', svvState, NaN(1,0), strings(1,0)
    'mixed dimensions', svv, [1000 3], ["time","run"]
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        [sizes, dims] = obj.ensembleSizes;

        assert(isequal(sizes, tests{t,3}), 'sizes');
        assert(isequal(dims, tests{t,4}), 'dimension names');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = stateSizes

grid = gridfile('test-llt');
svv0 = dash.stateVectorVariable(grid);
svvx = svv0.design(1:3, [2 2 2], {[],[],[]}, 'test');
svv1 = svv0.design(3, 2, {[]}, 'test');
svv2 = svv1.mean(1, {[]}, false, 'test');
svv3 = svv2.mean(3, {-2:2}, false, 'test');
svv4 = svv3.sequence(3, {-2:2}, {(-2:2)'}, 'test');

tests = {...
    'all state dimensions', svv0, [100 20 1000], ["lon","lat","time"]
    'some state dimensions', svv1, [100 20], ["lon","lat"]
    '+ state mean', svv2, [1 20], ["lon mean", "lat"]
    '+ ensemble mean', svv3, [1 20], ["lon mean","lat"]
    '+ ensemble sequence', svv4, [1 20 5], ["lon mean", "lat", "time sequence"]
    'no state dimensions', svvx, [], strings(1,0)
    };

try
    for t = 1:size(tests,1)
        svv = tests{t,2};
        [siz, type] = svv.stateSizes;

        assert(isequal(siz, tests{t,3}), 'size');
        assert(isequal(type, tests{t,4}), 'type');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = design

% Initial svv
grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svvSM = svv.mean(2, {[]}, false, 'test');
svvSW = svv.weightedMean(2, {ones(20,1)}, 'test');
svvE = svv.design(3, 2, {[]}, 'test');
svvEM = svvE.mean(3, {-2:2}, false, 'test');
svvEW = svvEM.weightedMean(3, {ones(5,1)}, 'test');
svvES = svvE.sequence(3, {-2:2}, {(-2:2)'}, 'test');
svvMeta = svv.metadata(2, 1, {string((1:20)')}, [], 'test');


tests = {...
    % description, should fail, object, dimension, type, indices,...
    %(output) isState, stateSize, ensSize, meanSize, hasSequence, sequenceIndices, sequence Metadata, ...
    % (error) error id
    'state to state', true, svv, 2, 1, {[]}, true(1,4), [100 20 1000 3], [1 1 1 1], [0 0 0 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'state with mean to state', true, svvSM, 2, 1, {[]}, true(1,4), [100 1 1000 3], ones(1,4), [0 20 0 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'state with weighted mean to state', true, svvSW, 2, 1, {[]}, true(1,4), [100 1 1000 3], ones(1,4), [0 20 0 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []

    'ens to ens', true, svvE, 3, 2, {[]}, [true true false true], [100 20 1 3], [1 1 1000 1], zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'ens with mean to ens', true, svvEM, 3, 2, {[]}, [true true false true], [100 20 1 3], [1 1 1000 1], [0 0 5 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'ens with weighted mean to ens', true, svvEW, 3, 2, {[]}, [true true false true], [100 20 1 3], [1 1 1000 1], [0 0 5 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'ens with sequence to ens', true, svvES, 3, 2, {[]}, [true true false true], [100 20 5 3], [1 1 1000 1], zeros(1,4), [false false true false], {[],[],(-2:2)',[]}, {[],[],(-2:2)',[]}, []

    'state to ens', true, svv, 2, 2, {[]}, [true false true true], [100 1 1000 3], [1 20 1 1], zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'state with mean to ens', false, svvSM, 2, 2, {[]}, [], [], [], [], [], [], [], 'noMeanIndices'

    'ens to state', true, svvE, 3, 1, {[]}, true(1,4), [100 20 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'ens with mean to state', true, svvEM, 3, 1, {[]}, true(1,4), [100 20 1 3], ones(1,4), [0 0 1000 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'ens with weighted mean to state', true, svvEW, 3, 1, {1:5}, true(1,4), [100 20 1 3], ones(1,4), [0 0 5 0], false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'weight size conflict', false, svvEW, 3, 1, {[]}, [],[],[],[],[],[],[],'weightsSizeConflict'
    'ens with sequence to state', true, svvES, 3, 1, {[]}, true(1,4), [100 20 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []

    'empty indices', true, svv, 2, 1, {[]}, true(1,4), [100 20 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'linear indices', true, svv, 2, 1, {(2:2:20)'}, true(1,4), [100 10 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'logical indices', true, svv, 2, 1, {[true(10,1);false(10,1)]}, true(1,4), [100 10 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'invalid logical indices', false, svv, 2, 1, {false(5,1)}, [], [], [], [], [], [], [], 'logicalIndicesWrongLength'
    'invalid linear indices', false, svv, 2, 1, {22}, [], [], [], [], [], [], [], 'linearIndicesTooLarge'
    'row indices', true, svv, 2, 1, {2:2:20}, true(1,4), [100 10 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []

    'alternate metadata', true, svvMeta, 2, 1, {[]}, true(1,4), [100 20 1000 3], ones(1,4), zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'metadata size conflict', false, svvMeta, 2, 1, {1:10}, [], [], [], [], [], [], [], 'metadataSizeConflict'

    'multiple dimensions, same', true, svv, [3 4], [2 2], {[],[]}, [true true false false], [100 20 1 1], [1 1 1000 3], zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'multiple dimensions, mixed', true, svv, [3 2 4], [2 1 2], {[],[],[]}, [true true false false], [100 20 1 1], [1 1 1000 3], zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    'dimensions with 0', true, svv, [0 4 0 3], [2 2 1 2], {[],[],[],[]}, [true true false false], [100 20 1 1], [1 1 1000 3], zeros(1,4), false(1,4), {[],[],[],[]}, {[],[],[],[]}, []
    };
header = 'DASH';

try
    for t = 1:size(tests,1)
        svv = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                svv.design(tests{t,4:6}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, tests{t,14}), 'invalid error');
            
        else
            svv = svv.design(tests{t,4:6}, header);

            assert(isequal(svv.isState, tests{t,7}), 'is state');
            assert(isequal(svv.stateSize, tests{t,8}), 'state size');
            assert(isequal(svv.ensSize, tests{t,9}), 'ens size');
            assert(isequal(svv.meanSize, tests{t,10}), 'mean size');
            assert(isequal(svv.hasSequence, tests{t,11}), 'has sequence');
            assert(isequal(svv.sequenceIndices, tests{t,12}), 'sequence indices');
            assert(isequal(svv.sequenceMetadata, tests{t,13}), 'sequence metadata');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = sequence

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [2 2], {[],[]}, 'test');
nLon = svv.stateSize(1);
nLat = svv.stateSize(2);

hasseq = svv;
hasseq.stateSize(3:4) = 3;
hasseq.hasSequence(3:4) = true;
hasseq.sequenceIndices(3:4) = {(-2:0)', (1:3)'};
hasseq.sequenceMetadata(3:4) = {rand(3,2), ["A";"B";"C"]};

tests = {
    % description, success, object, dim indices, seq indices, metadata,
    % state size, hasSequence, sequenceindices, sequence metadata
    'sequence', true, svv, 3, {1:3}, {[1 2;3 4;5 6]}, [nLon, nLat, 3, 1], [false false true false], {[],[],(1:3)',[]}, {[],[],[1 2;3 4;5 6],[]}
    'dims with 0', true, svv, [4 0 3], {1:2, 3:10, -2:2}, {["A","B"]', [], (1:5)'}, [nLon,nLat,5,2], [false,false,true,true], {[],[],(-2:2)',(1:2)'}, {[],[],(1:5)',["A";"B"]}
    'delete sequences', true, hasseq, [3 4], {[], []}, {[],[]}, [nLon,nLat,1,1], false(1,4), {[],[],[],[]}, {[],[],[],[]}

    'state dimension', false, svv, 1, {2:4}, {(2:4)'}, [], [], [], []
    'mixed state and ens', false, svv, [3 1], {2, 2}, {'a','b'}, [], [], [], []
    'sequence indices too large', false, svv, 3, {10002:10004}, {(2:4)'}, [], [], [], []
    'sequence indices too small', false, svv, 3, {-10004:-10002}, {(2:4)'}, [], [], [], []
    };
header = "DASH";

try
    for t = 1:size(tests,1)
        shouldFail = ~tests{t,2};
        obj = tests{t,3};
        if shouldFail
            try
                obj.sequence(tests{t,4}, tests{t,5}, tests{t,6}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            obj = obj.sequence(tests{t,4}, tests{t,5}, tests{t,6}, header);

            assert(isequal(tests{t,7}, obj.stateSize), 'state size');
            assert(isequal(tests{t,8}, obj.hasSequence), 'hasSequence');
            assert(isequal(tests{t,9}, obj.sequenceIndices), 'sequence indices');
            assert(isequal(tests{t,10}, obj.sequenceMetadata), 'sequence metadata');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = mean_

grid = gridfile('test-lltr.grid');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [2 2], {[],[]}, 'test');
svvM = svv.mean(1:4, {[],[],1:3,2}, false(1,4), 'test');
svvW = svvM.weightedMean([1 3], {ones(100,1), ones(3,1)}, 'test');

tests = {
    % test, succeed, object, dims, indices, omitnan,...
    % meanType, meanSize, stateSize, meanIndices, omitnan, weights
    'disable mean, weighted', true, svvW, [1 3], "none", [], [0 1 0 1], [0 20 0 1], [100 1 1 1], {[],[],[],2}, false(1,4), {[],[],[],[]}
    'disable mean, unweighted', true, svvM, [1 3], "none", [], [0 1 0 1], [0 20 0 1], [100 1 1 1], {[],[],[],2}, false(1,4), {[],[],[],[]}
    'disable mean, no mean', true, svv, [1 3], "none", [], [0 0 0 0], zeros(1,4), [100 20 1 1], {[],[],[],[]}, false(1,4), {[],[],[],[]}
    'disable weights', true, svvW, [1 3], "unweighted", [], [1 1 1 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, false(1,4), {[],[],[],[]}
    'disable weights, no weights', true, svvM, [1 3], "unweighted", [], [1 1 1 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, false(1,4), {[],[],[],[]}
    'disable weights, no mean', false, svv, [1 3], "unweighted", [], [],[],[],[],[],[]
    
    'state mean', true, svv, [1 2], {[],[]}, [true true], [1 1 0 0], [100 20 0 0], [1 1 1 1], {[],[],[],[]}, [true true false false], {[],[],[],[]}
    'mean indices for state', false, svv, [1 2], {[],-2:2}, [true true],[],[],[],[],[],[]
    'state mean, previous mean', true, svvM, [1 2], {[],[]}, [true true], [1 1 1 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, [true true false false], {[],[],[],[]}
    'state mean, previous weights', true, svvW, [1 2], {[],[]}, [true true], [2 1 2 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, [true true false false], {ones(100,1),[],ones(3,1),[]}

    'ens mean',true, svv, [3 4], {1:3, 2}, [true true], [0 0 1 1], [0 0 3 1], [100 20 1 1], {[],[],(1:3)',2}, [false false, true true], {[],[],[],[]}
    'ens mean, no indices', false, svv, [3 4], {1:3, []}, [true true],[],[],[],[],[],[]
    'indices too large', false, svv, 3, {10000}, true,[],[],[],[],[],[]
    'indices too small', false, svv, 3, {-100000}, true,[],[],[],[],[],[]
    'ens mean, previous mean', true, svvM, 3, {1:5}, false, [1 1 1 1], [100 20 5 1], [1 1 1 1], {[],[],(1:5)',2}, false(1,4), {[],[],[],[]}
    'ens mean, previous weights', true, svvW, 3, {-1:1}, false, [2 1 2 1], [100 20 3 1], [1 1 1 1], {[],[],(-1:1)',2}, false(1,4), {ones(100,1),[],ones(3,1),[]}
    'ens mean, weights conflict', false, svvW, 3, {-2:1}, false,[],[],[],[],[],[]

    'ens, include nan', true, svv, 3, {-1:1}, true, [0 0 1 0], [0 0 3 0], [100 20 1 1], {[],[],(-1:1)',[]}, [false false true false], {[],[],[],[]}
    'state, include nan', true, svv, 1, {[]}, true, [1 0 0 0], [100 0 0 0], [1 20 1 1], {[],[],[],[]}, [true false false false], {[],[],[],[]}
    'mixed ens/state', true, svv, [1 3], {[], -1:1}, [false true], [1 0 1 0], [100 0 3 0], [1 20 1 1], {[],[],(-1:1)',[]}, [false false true false], {[],[],[],[]}
    'dims with 0', true, svv, [3 0 1], {-1:1,[],[]}, [true false false], [1 0 1 0], [100 0 3 0], [1 20 1 1], {[],[],(-1:1)',[]}, [false false true false], {[],[],[],[]}
    };
header = "DASH";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.mean(tests{t,4:6}, header)
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            obj = obj.mean(tests{t,4:6}, header);

            assert(isequaln(tests{t,7}, obj.meanType), 'mean type');
            assert(isequaln(tests{t,8}, obj.meanSize), 'mean size');
            assert(isequaln(tests{t,9}, obj.stateSize), 'state size');
            assert(isequaln(tests{t,10}, obj.meanIndices), 'mean indices');
            assert(isequaln(tests{t,11}, obj.omitnan), 'omitnan');
            assert(isequaln(tests{t,12}, obj.weights), 'weights');
            %...
            % assert(output)
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = weightedMean

grid = gridfile('test-lltr.grid');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [2 2], {[],[]}, 'test');
svvM = svv.mean(1:4, {[],[],(12:12:36)',2}, false(1,4), 'test');
svvW = svvM.weightedMean([1 2 3], {ones(100,1), ones(20,1), ones(3,1)}, 'test');

tests = {
    % test, succeed, obj, dims, weights, ...
    % (output) meanType, weights, state size, mean size
    'remove weights, no mean (state)', true, svv, 1 {[]}, [1 0 0 0], {[],[],[],[]}, [1 20 1 1], [100 0 0 0]
    'remove weights, no mean (ens)', false, svv, 3, {[]}, [],[],[],[]
    'remove weights, no weights', true, svvM, [1 3], {[],[]}, [1 1 1 1], {[],[],[],[]}, [1 1 1 1], [100 20 3 1]
    'remove weights, weighted', true, svvW, [1 3], {[],[]}, [1 2 1 1], {[],ones(20,1),[],[]}, [1 1 1 1], [100 20 3 1]

    'set new weights', true, svvM, [1 3], {ones(100,1), ones(3,1)}, [2 1 2 1], {ones(100,1),[],ones(3,1),[]}, [1 1 1 1], [100 20 3 1]
    'update existing weights', true, svvW, [1 3], {5*ones(100,1), 6*ones(3,1)}, [2 2 2 1], {5*ones(100,1), ones(20,1),6*ones(3,1),[]}, [1 1 1 1], [100 20 3 1]
    'mean index size conflict', false, svvM, 3, {ones(4,1)}, [],[],[],[]
    'state size conflict', false, svvM, 1, {ones(101,1)}, [],[],[],[]
    'size conflict, weighted', false, svvW, 3, {ones(4,1)}, [],[],[],[]
    
    'set new state mean', true, svv, 1, {ones(100,1)}, [2 0 0 0], {ones(100,1),[],[],[]}, [1 20 1 1], [100 0 0 0]
    'new state, size conflict', false, svv, 1, {ones(101,1)}, [],[],[],[]
    'set new ens mean', false, svv, 3, {ones(3,1)}, [],[],[],[]

    'set multiple dims', true, svvM, [3 1], {ones(3,1), ones(100,1)}, [2 1 2 1], {ones(100,1),[],ones(3,1),[]}, [1 1 1 1], [100 20 3 1]
    'dims with 0', true, svvM, [3 0 1], {ones(3,1), 5, ones(100,1)}, [2 1 2 1], {ones(100,1),[],ones(3,1),[]}, [1 1 1 1], [100 20 3 1]
    };
header = "DASH";


try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.weightedMean(tests{t,4:5}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            obj = obj.weightedMean(tests{t,4:5}, header);

            assert(isequaln(tests{t,6}, obj.meanType), 'mean type');
            assert(isequaln(tests{t,7}, obj.weights), 'weights');
            assert(isequaln(tests{t,8}, obj.stateSize), 'state size');
            assert(isequaln(tests{t,9}, obj.meanSize), 'mean size');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = metadata

convert = @(x,y,z) 5+x;
args = {1,2};

grid = gridfile('test-lltr.grid');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [2 2], {[],[]}, 'test');
svvA = svv.metadata([3 4], 1, {(1:1000)',(1:3)'}, [], 'test');
svvC = svv.metadata([3 4], 2, {convert, convert}, {args,args}, 'test');

tests = {
    % test, succeed, object, dims, type, arg1, arg2,...
    % (output):   metadata type, metadata, convertFunction, convertArgs
    'raw to raw', true, svv,3,0,[],[], [0 0 0 0], {[],[],[],[]}, {[],[],[],[]}, {[],[],[],[]}
    'raw to alternate', true,svv,3,1,{(1:1000)'},[], [0 0 1 0], {[],[],(1:1000)',[]}, {[],[],[],[]}, {[],[],[],[]}
    'raw to convert', true,svv,3,2,{convert},{args}, [0 0 2 0], {[],[],[],[]}, {[],[],convert,[]}, {[],[],args,[]}

    'alternate to raw', true, svvA,3,0,[],[], [0 0 0 1], {[],[],[],(1:3)'}, {[],[],[],[]}, {[],[],[],[]}
    'alternate to alternate', true, svvA,3,1,{(1:1000)'},[], [0 0 1 1], {[],[],(1:1000)',(1:3)'}, {[],[],[],[]}, {[],[],[],[]}
    'alternate to convert', true, svvA,3,2,{convert},{args}, [0 0 2 1], {[],[],[],(1:3)'}, {[],[],convert,[]}, {[],[],args,[]}

    'convert to raw', true, svvC,3,0,[],[], [0 0 0 2], {[],[],[],[]}, {[],[],[],convert}, {[],[],[],args}
    'convert to alternate', true, svvC,3,1,{(1:1000)'},[], [0 0 1 2], {[],[],(1:1000)',[]}, {[],[],[],convert}, {[],[],[],args}
    'convert to convert', true, svvC,3,2,{convert},{args}, [0 0 2 2], {[],[],[],[]}, {[],[],convert,convert}, {[],[],args,args}
    
    'alternate metadata wrong size', false, svv,3,1,{(1:2000)'},[], [],[],[],[]

    'multiple dims', true, svv,[4 3],1,{(1:3)',(1:1000)'},[], [0 0 1 1], {[],[],(1:1000)',(1:3)'}, {[],[],[],[]}, {[],[],[],[]}
    'dims with 0', true, svv,[4 0 3],1,{(1:3)',5,(1:1000)'},[], [0 0 1 1], {[],[],(1:1000)',(1:3)'}, {[],[],[],[]}, {[],[],[],[]}
    };
header = "DASH";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};

        shouldFail = ~tests{t,2};
        if shouldFail
            try
                obj.metadata(tests{t,4:7}, header);
                error('did not fail');
            catch ME
            end
            assert(contains(ME.identifier, header), 'invalid error');
            
        else
            obj = obj.metadata(tests{t,4:7}, header);
            
            assert(isequaln(tests{t,8}, obj.metadataType), 'metadata type');
            assert(isequaln(tests{t,9}, obj.metadata_), 'metadata');
            assert(isequaln(tests{t,10}, obj.convertFunction), 'convert function');
            assert(isequaln(tests{t,11}, obj.convertArgs), 'convert args');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = validateGrid

grid = gridfile('test-lltr');
diffSize = gridfile('test-lltr-different-size');
diffDims = gridfile('test-llt');

svv = dash.stateVectorVariable(grid);

tests = {
    'valid', grid, true
    'different dimensions', diffDims, false
    'different size', diffSize, false
};
header = "DASH";

try
    for t = 1:size(tests,1)
        [isvalid, cause] = svv.validateGrid(tests{t,2}, header);

        assert(isequal(isvalid, tests{t,3}), 'isvalid');
        if isvalid
            assert(isempty(cause), 'empty cause');
        else
            assert(contains(cause.identifier, header), 'cause');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = getMetadata

file = "test-lltr";
grid = gridfile(file);
diffSize = "test-lltr-different-size";
notfile = fullfile(pwd, 'not-a-file');

svv = dash.stateVectorVariable(grid);
lons = 2:2:48;
lats = [7 2 19 5 1];
times = [7 2 19 5 1];
runs = [3 1];
svv = svv.design(1:4, [1 1 2 2], {lons, lats, times, runs}, "test");

convert1 = @datevec;
convert2 = @(x,y,z) datevec(x)+y+z;
failConvert = @() error('failed');
invalidConvert = @(x) num2cell(rand(size(x)), ones(size(x,1),1), ones(size(x,2),1));
repeatConvert = @(x) ones(size(x));
rowsConvert = @() 5;

altMeta = [1 2;3 4;5 6;7 8;9 10];
svvA = svv.metadata(3, 1, {altMeta}, [], 'test');
svvC1 = svv.metadata(3, 2, {convert1}, {{}}, 'test');
svvC2 = svv.metadata(3, 2, {convert2}, {{5,6}}, 'test');
svvF = svv.metadata(3, 2, {failConvert}, {{}}, 'test');
svvI = svv.metadata(3, 2, {invalidConvert}, {{}}, 'test');
svvR = svv.metadata(3, 2, {repeatConvert}, {{}}, 'test');
svvRows = svv.metadata(3, 2, {rowsConvert}, {{}}, 'test');

latMeta = grid.metadata.lat(lats,:);
lonMeta = grid.metadata.lon(lons,:);
timeMeta = grid.metadata.time(times,:);
convertMeta1 = convert1(timeMeta);
convertMeta2 = convert2(timeMeta, 5, 6);

tests = {
    % test, should succeed, object, dimension, gridfile, output metadata
    'metadata', true, svv, 2, grid, latMeta
    'metadata, multiple cols', true, svv, 1, grid, lonMeta

    'state dimension, object', true, svv, 1, grid, lonMeta
    'state dimension, filename', true, svv, 1, file, lonMeta 
    'state dimension, failed build', false, svv, 1, notfile, []
    'state dimension, invalid build', false, svv, 1, diffSize, []

    'raw, object', true, svv, 3, grid, timeMeta
    'raw, filename', true, svv, 3, file, timeMeta
    'raw, failed build', false, svv, 3, notfile, timeMeta
    'raw, invalid build', false, svv, 3, diffSize, timeMeta

    'alternate, object', true, svvA, 3, grid, altMeta
    'alternate, filename', true, svvA, 3, file, altMeta
    'alternate, failed build', true, svvA, 3, notfile, altMeta
    'alternate, invalid build', true, svvA, 3, diffSize, altMeta

    'convert, object', true, svvC1, 3, grid, convertMeta1
    'convert, filename', true, svvC1, 3, file, convertMeta1
    'convert, failed build', false, svvC1, 3, notfile, []
    'convert, invalid build', false, svvC1, 3, diffSize, []

    'convert, extra args', true, svvC2, 3, grid, convertMeta2
    'failed conversion function', false, svvF, 3, grid, []
    'convert metadata invalid', false, svvI, 3, grid, []
    'convert metadata not unique', false, svvR, 3, grid, []
    'convert metadata wrong rows', false, svvRows, 3, grid, []
    };
header = "DASH";

try
    for t = 1:size(tests,1)
        obj = tests{t,3};
        [metadata, failed, cause] = obj.getMetadata(tests{t,4:5}, header);

        shouldSucceed = tests{t,2};
        if shouldSucceed
            assert(isequal(tests{t,6}, metadata), 'metadata');
            assert(isequal(failed, false), 'failed is false');
            assert(isempty(cause), 'empty cause');
        else
            assert(isempty(metadata), 'empty metadata');
            assert(isequal(failed, true), 'failed is true');
            assert(contains(cause.identifier, header), 'cause');
        end
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = finalize

grid = gridfile('test-lltr.grid');
svv = dash.stateVectorVariable(grid);

allLon = (1:svv.gridSize(1))';
allLat = (1:svv.gridSize(2))';
allTime = (1:svv.gridSize(3))';
allRun = (1:svv.gridSize(4))';

lons = [2 57 19 1]';
lats = (2:2:18)';
times = [1 209 55 811 3]';
runs = [3 1]';

timeAdd = [-4 8 0 -1]';
runAdd = (-2:1)';

empty = svv.design([3 4], [2 2], {[],[]}, 'test');
mixedIndex = svv.design(1:4, [1 1 2 2], {[],lats,[],runs}, 'test');
allIndex = svv.design(1:4, [1 1 2 2], {lons,lats,times,runs}, 'test');
mixedMean = empty.mean([2 4], {[],runAdd}, [true true], 'test');
allMean = empty.mean(1:4, {[],[], timeAdd, runAdd}, true(1,4), 'test');
mixedSeq = empty.sequence(4, {runAdd}, {(1:4)'}, 'test');
meanSeq = mixedMean.sequence(3, {timeAdd}, {(1:4)'}, 'test');


tests = {
    % test, object, (output) indices, mean size, mean indices, sequence indices
    'all empty indices', empty, {allLon,allLat,allTime,allRun}, [1 1 1 1], {[],[],0,0}, {[],[],0,0}
    'mixed indices', mixedIndex, {allLon,lats,allTime,runs}, [1 1 1 1], {[],[],0,0}, {[],[],0,0}
    'no empty indices', allIndex, {lons,lats,times,runs}, [1 1 1 1], {[],[],0,0}, {[],[],0,0}

    'all empty mean', empty, {allLon,allLat,allTime,allRun}, [1 1 1 1], {[],[],0,0}, {[],[],0,0}
    'mixed empty mean', mixedMean, {allLon,allLat,allTime,allRun}, [1 20 1 4], {[],[],0,runAdd}, {[],[],0,0}
    'no empty mean', allMean, {allLon,allLat,allTime,allRun}, [100 20 4 4], {[],[],timeAdd,runAdd}, {[],[],0,0}

    'mean indices, no sequence', mixedMean, {allLon,allLat,allTime,allRun}, [1 20 1 4], {[],[],0,runAdd}, {[],[],0,0}
    'sequence indices, no mean', mixedSeq, {allLon,allLat,allTime,allRun}, [1 1 1 1], {[],[],0,0}, {[],[],0,runAdd} 
    'mean and sequence', meanSeq, {allLon,allLat,allTime,allRun}, [1 20 1 4], {[],[],0,runAdd}, {[],[],timeAdd,0}
    'no mean, no sequence', empty, {allLon,allLat,allTime,allRun}, [1 1 1 1], {[],[],0,0}, {[],[],0,0}
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        obj = obj.finalize;

        assert(isequal(obj.indices, tests{t,3}), 'indices');
        assert(isequal(obj.meanSize, tests{t,4}), 'meanSize');
        assert(isequal(obj.meanIndices, tests{t,5}), 'mean indices');
        assert(isequal(obj.sequenceIndices, tests{t,6}), 'sequence indices');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = addIndices

timeMean = [-2 8 0 4 -3]';
timeSeq = -2:1;
allIndex = timeMean + timeSeq;
allIndex = allIndex(:);

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design(3, 2, {[]}, 'test');
svvM = svv.mean(3, {timeMean}, true, 'test');
svvS = svv.sequence(3, {timeSeq}, {(1:4)'}, 'test');
svvMS = svvM.sequence(3, {timeSeq}, {(1:4)'}, 'test');

tests = {
    'no mean, no sequence', svv, 0
    'mean, no sequence', svvM, timeMean
    'sequence, no mean', svvS, timeSeq'
    'sequence and mean', svvMS, allIndex
};

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        obj = obj.finalize;
        indices = obj.addIndices(3);

        assert(isequal(indices, tests{t,3}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = trim

timeAddP = [-4 -1];
timeAddE = [1 4];
timeAddPE = [-4 1 -1 4];

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [2 2], {[],[]}, 'test');

allLon = (1:svv.gridSize(1))';
allLat = (1:svv.gridSize(2))';
allTime = (1:svv.gridSize(3))';
allRun = (1:svv.gridSize(4))';
altMeta = [allTime, 1000+allTime];

svvN = svv.design(3, 2, {1}, 'test');
svvN = svvN.mean(3, {-5}, true, 'test');
svvP = svv.mean(3, {timeAddP}, true, 'test');
svvE = svv.mean(3, {timeAddE}, true, 'test');
svvPE = svv.mean(3, {timeAddPE}, true, 'test');
svvA = svvPE.metadata(3, 1, {altMeta}, [], 'test');

tests = {
    % test, object, indices, ensSize, metadata
    'all valid', svv, {allLon,allLat,allTime,allRun}, [1 1 1000 3], {[],[],[],[]}
    'none valid', svvN, {allLon, allLat, NaN(1,0), allRun}, [1 1 0 3], {[],[],[],[]}
    'precede', svvP, {allLon,allLat,allTime(5:end),allRun}, [1 1 996 3], {[],[],[],[]}
    'exceed', svvE, {allLon,allLat,allTime(1:end-4),allRun}, [1 1 996 3], {[],[],[],[]}
    'precede and excede', svvPE, {allLon,allLat,allTime(5:end-4),allRun}, [1 1 992 3], {[],[],[],[]}
    'remove alternate metadata', svvA, {allLon,allLat,allTime(5:end-4),allRun}, [1 1 992 3], {[],[],altMeta(5:end-4,:),[]}
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        obj = obj.finalize;
        obj = obj.trim;

        assert(isequal(tests{t,3}, obj.indices), 'indices');
        assert(isequal(tests{t,4}, obj.ensSize), 'ensSize');
        assert(isequal(tests{t,5}, obj.metadata_), 'metadata');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = matchMetadata

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design(3, 2, {[]}, 'test');
svvM = svv.metadata(3, 1, {grid.metadata.time}, [], 'test');

ordered = 5:50;
unordered = [6 19 200 7 599 2];
[~, reorder] = sort(unordered);

allLon = (1:svv.gridSize(1))';
allLat = (1:svv.gridSize(2))';
allTime = (1:svv.gridSize(3))';
allRun = (1:svv.gridSize(4))';

metaA = grid.metadata.time;
metaN = grid.metadata.time + calyears(3000);
metaO = grid.metadata.time(ordered);
metaU = grid.metadata.time(unordered);
metaM = [grid.metadata.time(unordered); metaN];

tests = {
    % test, object, metadata, (output) indices, ensSize, metadata
    'all matching', svv, metaA, {allLon,allLat,allTime,allRun}, [1 1 1000 1], {[],[],[],[]}
    'no matching', svv, metaN, {allLon,allLat,NaN(0,1),allRun}, [1 1 0 1], {[],[],[],[]}
    'some match, ordered', svv, metaO, {allLon,allLat,allTime(ordered),allRun}, [1 1 numel(ordered), 1], {[],[],[],[]}
    'some match, unordered', svv, metaU, {allLon,allLat,allTime(unordered(reorder)),allRun}, [1 1 numel(unordered),1], {[],[],[],[]}
    'non-matching in metadata', svv, metaM, {allLon,allLat,allTime(unordered(reorder)),allRun}, [1 1 numel(unordered),1], {[],[],[],[]}
    'update metadata', svvM, metaU, {allLon,allLat,allTime(unordered(reorder)),allRun}, [1 1 numel(unordered),1], {[],[],metaU(reorder,:),[]}
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        obj = obj.finalize;
        obj = obj.matchMetadata(3, tests{t,3}, grid);

        assert(isequal(tests{t,4}, obj.indices), 'indices');
        assert(isequal(tests{t,5}, obj.ensSize), 'ensSize');
        assert(isequal(tests{t,6}, obj.metadata_), 'metadata');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = removeOverlap

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design(1:3, [2 2 2], {[],[],[]}, 'test');
svvP1 = svv.mean(1:3, {0:1, 0:1, 0:1}, true(1,3), 'test');
svvP3 = svv.mean(1:3, {0:3,0:3,0:3}, true(1,3), 'test');
svvPM1 = svv.mean(1:3, {-1:1, -1:1, -1:1}, true(1,3), 'test');

membersP1 = [1 1 1;2 2 2;3 3 3;4 4 4;5 5 5];
members3P1 = [1 1 1;1 1 2;1 1 3;1 1 4];
membersDims = [10 20 30;11 21 31;12 22 32;13 23 33;14 24 34;15 25 35];
membersUnordered = [4 4 4;2 2 2;1 1 1;3 3 3;5 5 5];
membersProp = [2 2;3 3;4 4;5 5;6 6;7 7;8 8];

tests = {
    % test, object, dims, members, output members
    'no overlap', svv, 1:3, membersP1, membersP1
    'overlap but not all dims', svv, 1:3, members3P1, members3P1
    'overlap all dims', svvP1, 1:3, membersP1, [1 1 1;3 3 3;5 5 5] 
    'overlap, unordered dims', svvP1, [2 1 3], membersDims, [10 20 30;12 22 32; 14 24 34] 
    'overlap, multiple matches', svvP3, 1:3, membersP1, [1 1 1;5 5 5]
    'overlap, unordered members', svvP1, 1:3, membersUnordered, [4 4 4;2 2 2]
    'multiple propagation of add indices', svvPM1, [1 3], membersProp, [2 2;5 5;8 8]
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        obj = obj.finalize;
        subMembers = obj.removeOverlap(tests{t,3:4});

        assert(isequal(subMembers, tests{t,5}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = indexLimits

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design(1:4,[2 1 2 2], {[],[],[],[]}, 'test');
svvA = svv.mean(3, {-3:1}, true(1,2), 'test');
svvA = svvA.sequence(3, {6:8}, {(1:3)'}, 'test');

members = [17 12 1;77 301 2;22 509 1;86 899 3;86 899 1];

addLimits = [17 86;1 20;15 908;1 3];
noaddLimits = [17 86;1 20;12 899;1 3];

tests = {
    % test, object, dims, subMembers, include state, (output) limits
    'all, no add indices', svv, [1 3 4], members, true, noaddLimits
    'all, with add indices', svvA, [1 3 4], members, true, addLimits
    'all, unordered dims', svvA, [4 1 3], members(:,[3 1 2]), true, addLimits
    'ens, no add indices', svv, [1 3 4], members, false, noaddLimits([1 3 4],:)
    'ens, with add indices', svvA, [1 3 4], members, false, addLimits([1 3 4],:)
    'ens, unordered dims',svvA, [4 1 3], members(:,[3 1 2]), false, addLimits([4 1 3],:)
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        obj = obj.finalize;
        limits = obj.indexLimits(tests{t,3:5});
        assert(isequal(limits, tests{t,6}), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = parametersForBuild

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design(3:4, [2 2], {[],[]}, 'test');
svvM = svv.mean([1 3], {[], -2:2}, [false false], 'test');
svvS = svv.sequence([3 4], {-1:1, -1:1}, {(-1:1)', (-1:1)'}, 'test');
svvMS = svvS.mean([1 3], {[], -2:2}, [false false], 'test');

tests = {
    % description, object, rawSize, meanDims, nState
    'no means, no sequences', svv, [100 20 1 1], [1 2 3 4], 100*20
    'means', svvM, [100 20 5 1], [1 2 3 4], 1*20
    'sequences', svvS, [100 20 1 3 1 3], [1 2 3 5], 100*20*3*3
    'means and sequences', svvMS, [100 20 5 3 1 3], [1 2 3 5], 1*20*3*3
    };

try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        params = obj.parametersForBuild;

        assert(isequal(params.rawSize, tests{t,3}), 'raw size');
        assert(isequal(params.meanDims, tests{t,4}), 'mean dims');
        assert(isequal(params.nState, tests{t,5}), 'nState');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
function[] = buildMembers1

% Basic design
grid = gridfile('load-lltr');
ds1 = dash.dataSource.mat('load-data', 'X1');
ds2 = dash.dataSource.mat('load-data', 'X2');
ds3 = dash.dataSource.mat('load-data', 'X1');
ds4 = dash.dataSource.mat('load-data', 'X2');
ds5 = dash.dataSource.mat('load-data', 'X3');

svv0 = dash.stateVectorVariable(grid);
svv0 = svv0.design([1 3 4], [1 2 2], {33:99,10:500,[]}, 'test');
dims = [3 4];

%% Preloaded data

svv = svv0.finalize;
subMembers = [ 41 1
               41 2
              191 1
              191 2];

Xall = grid.load(["lon","lat","time","run"], {33:99,[],50:200,1:2});
source = struct(...
    'isloaded', true,...
    'data', Xall,...
    'limits', [33 99;1 20;50 200; 1 2] ...
    );

parameters = svv.parametersForBuild;
parameters.indexLimits = svv.indexLimits(dims, subMembers, true);
parameters.loadAllMembers = false;

precision = 'double';

X = svv.buildMembers(dims, subMembers, grid, source, parameters, precision);

Xtest = grid.load(["lon","lat","time","run"], {33:99, 1:20, [50 200], 1:2});
Xtest = reshape(Xtest, 1340, 4);
Xtest = Xtest(:,[1 3 2 4]);

assert(isequal(X, Xtest), 'pre-loaded output');


%% Load all members - success

svv = svv0.finalize;

subMembers = [ 41 1
               41 2
              191 1
              191 2];

source = struct;
source.isloaded = false;
source.indices = [1 2 3 4];
source.dataSources = {ds1;ds2;ds3;ds4};

parameters = svv.parametersForBuild;
parameters.indexLimits = svv.indexLimits(dims, subMembers, false);
parameters.loadAllMembers = true;

precision = 'double';

X = svv.buildMembers(dims, subMembers, grid, source, parameters, precision);
assert(isequal(X, Xtest), 'all loaded success');


%% Load all members - failed

svv = svv0.finalize;

subMembers = [ 41 1
               41 10000
               41 2
              191 1 ];

source = struct();
source.isloaded = false;
source.indices = [1 5 3 2];
source.dataSources = {ds1;ds5;ds3;ds2};

parameters = svv.parametersForBuild;
parameters.indexLimits = svv.indexLimits(dims, subMembers, false);
parameters.loadAllMembers = true;

precision = 'double';

X = svv.buildMembers(dims, subMembers, grid, source, parameters, precision);

Xtest = grid.load(["lon","lat","time","run"], {33:99, 1:20, [50 200], [1 10000 2]});
Xtest = reshape(Xtest, 1340, 6);
Xtest = Xtest(:,[1 3 5 2]);
assert(isequal(X, Xtest), 'all load fails and redirects');


%% Load members

svv = svv0.finalize;

subMembers = [ 41 1
               41 10000
               41 2
              191 1 ];

source = struct();
source.isloaded = false;
source.indices = [1 5 3 2];
source.dataSources = {ds1;ds5;ds3;ds2};

parameters = svv.parametersForBuild;
parameters.indexLimits = svv.indexLimits(dims, subMembers, false);
parameters.loadAllMembers = false;

precision = 'double';

X = svv.buildMembers(dims, subMembers, grid, source, parameters, precision);

assert(isequal(X, Xtest), 'load members');


end
function[] = buildMembers2

% Gridfile and data sources
grid = gridfile('load-lltr');
ds1 = dash.dataSource.mat('load-data', 'X1');
ds2 = dash.dataSource.mat('load-data', 'X2');
ds3 = dash.dataSource.mat('load-data', 'X1');
ds4 = dash.dataSource.mat('load-data', 'X2');

% Common inputs
dims = [3 4];
source = struct;
source.isloaded = false;
source.indices = [1 2 3 4];
source.dataSources = {ds1;ds2;ds3;ds4};

% SVV object
svv = dash.stateVectorVariable(grid);
svv = svv.design([1 3 4], [1 2 2], {33:99,10:500,[]}, 'test');

% Output array
Xg = grid.load(["lon","lat","time","run"], {33:99,[],[50 200 350],1:4});

%% Multiple sequence sources

grid2 = gridfile('load-seq');
dseq = dash.dataSource.mat('load-seq','X');
dims2 = [2 4 6];
source2 = struct;
source2.isloaded = false;
source2.indices = 1;
source2.dataSources = {dseq};
svv2 = dash.stateVectorVariable(grid2);
svv2 = svv2.design([2 4 6], [2 2 2], {[],[],[]}, 'test');
Xg2 = grid2.load(["lon","lat","lev","time","run","var"]);

%% State mean

subSM = [41 1;41 2];
svvSM = svv.mean(2, {[]}, true, 'test');
Xsm = Xg(:,:,1,1:2);
Xsm = mean(Xsm,2);
Xsm = reshape(Xsm, [], 2);

%% Ensemble mean

subEM = [41 1; 191 1];
svvEM = svv.mean(4, {0:1}, true, 'test');
Xem = Xg(:,:,1:2,1:2);
Xem = mean(Xem, 4);
Xem = reshape(Xem, [], 2);

%% Mixed mean

subXM = [41 1; 191 1];
svvXM = svv.mean([2 4], {[],0:1}, [true true], 'test');
Xxm = Xg(:,:,1:2,1:2);
Xxm = mean(Xxm, [2 4]);
Xxm = reshape(Xxm, [], 2);

%% Sequence

subSeq = [41 1; 191 1];
svvSeq = svv.sequence(4, {0:1}, {[0;1]}, 'test');
Xseq = [reshape(Xg(:,:,1,1:2),[],1), reshape(Xg(:,:,2,1:2),[],1)];

%% Multiple sequences

subXSeq = [1 1 1;
           11 11 11];
svvXSeq = svv2.sequence([2 4 6], {0:2, 0:2, 0:2}, {[0;1;2],[0;1;2],[0;1;2]}, 'test');

Xxs1 = Xg2(:,1:3,:,1:3,:,1:3);
Xxs1 = reshape(Xxs1, [], 1);
Xxs2 = Xg2(:,11:13,:,11:13,:,11:13);
Xxs2 = reshape(Xxs2, [], 1);
Xxseq = [Xxs1, Xxs2];

%% Sequence and mean

subSeqM = [1 1 1;
           11 11 11];
svvSeqM = svv2.sequence(4, {[0 3]}, {[0;1]}, 'test');
svvSeqM = svvSeqM.mean(4, {0:1}, false, 'test');

Xsm1 = Xg2(:,1,:,[1 2 4 5],:,1);
Xsm1 = reshape(Xsm1, [3 1 3 2 2 3 1]);
Xsm1 = mean(Xsm1, 4);
Xsm1 = reshape(Xsm1, [], 1);

Xsm2 = Xg2(:,11,:,[11 12 14 15],:,11);
Xsm2 = reshape(Xsm2, [3 1 3 2 2 3 1]);
Xsm2 = mean(Xsm2, 4);
Xsm2 = reshape(Xsm2, [], 1);

Xseqm = [Xsm1, Xsm2];

%% Multiple sequence and mean

subXSeqM = [1 1 1;11 11 11];
svvXSeqM = svv2.sequence([2 4 6], {[0;3],[0;3],[0;3]}, {[0;1],[0;1],[0;1]}, 'test');
svvXSeqM = svvXSeqM.mean([2 4 6], {0:1,0:1,0:1}, true(1,3), 'test');

Xxsm1 = Xg2(:,[1 2 4 5],:,[1 2 4 5],:,[1 2 4 5]);
Xxsm1 = reshape(Xxsm1, [3 2 2 3 2 2 3 2 2]);
Xxsm1 = mean(Xxsm1, [2 5 8]);
Xxsm1 = reshape(Xxsm1, [], 1);

Xxsm2 = Xg2(:,[11 12 14 15],:,[11 12 14 15],:,[11 12 14 15]);
Xxsm2 = reshape(Xxsm2, [3 2 2 3 2 2 3 2 2]);
Xxsm2 = mean(Xxsm2, [2 5 8]);
Xxsm2 = reshape(Xxsm2, [], 1);

Xxseqm = [Xxsm1, Xxsm2];

%% Multiple mixed sequence and mean

subX2sm = [1 1 1;11 11 11];
svvX2sm = svv2.sequence([2 4], {[0;3],[0;3]}, {[0;1],[0;1]}, 'test');
svvX2sm = svvX2sm.mean([1 2 5 6], {[],0:1,[],0:1}, true(1,4), 'test');

Xx2sm1 = Xg2(:,[1 2 4 5],:,[1 4],:,1:2);
Xx2sm1 = reshape(Xx2sm1, [3 2 2 3 2 3 2]);
Xx2sm1 = mean(Xx2sm1, [1 2 6 7]);
Xx2sm1 = reshape(Xx2sm1, [], 1);

Xx2sm2 = Xg2(:,[11 12 14 15],:,[11 14],:,11:12);
Xx2sm2 = reshape(Xx2sm2, [3 2 2 3 2 3 2]);
Xx2sm2 = mean(Xx2sm2, [1 2 6 7]);
Xx2sm2 = reshape(Xx2sm2, [], 1);

Xx2sm = [Xx2sm1, Xx2sm2];

%% Include NaN

subI = [41 1;41 2];
svvI = svv.mean(4, {0:1}, false, 'test');
Xi1 = Xg(:,:,1,1:2);
Xi1 = mean(Xi1, 4, 'includenan');
Xi1 = reshape(Xi1, [], 1);
Xi2 = Xg(:,:,1,2:3);
Xi2 = mean(Xi2, 4, 'includenan');
Xi2 = reshape(Xi2, [], 1);
Xi = [Xi1, Xi2];

%% Omit NaN

subO = [41 1;41 2];
svvO = svv.mean(4, {0:1}, false, 'test');
Xo1 = Xg(:,:,1,1:2);
Xo1 = mean(Xo1, 4, 'includenan');
Xo1 = reshape(Xo1, [], 1);
Xo2 = Xg(:,:,1,2:3);
Xo2 = mean(Xo2, 4, 'includenan');
Xo2 = reshape(Xo2, [], 1);
Xo = [Xo1, Xo2];

%% Mixed nanflag

subXN = [41 1;191 2];
svvXN = svv.mean([3 4], {[0 150], 0:1}, [true, false], 'test');
Xxn1 = Xg(:,:,1:2,1:2);
Xxn1 = mean(Xxn1, 4, 'includenan');
Xxn1 = mean(Xxn1, 3, 'omitnan');
Xxn1 = reshape(Xxn1, [], 1);
Xxn2 = Xg(:,:,2:3,2:3);
Xxn2 = mean(Xxn2, 4, 'includenan');
Xxn2 = mean(Xxn2, 3, 'omitnan');
Xxn2 = reshape(Xxn2, [], 1);
Xxn = [Xxn1, Xxn2];

%% Weighted include nan

subWI = [19 19 19;
         20 20 20];
svvWI = svv2.mean(2, {0:1}, false, 'test');
svvWI = svvWI.weightedMean(2, {1:2}, 'test');
w = [1 2];

Xwi1 = Xg2(:,19:20,:,19,:,19);
Xwi1 = Xwi1 .* w;
Xwi1 = sum(Xwi1, 2, 'includenan') ./ sum(w);
Xwi1 = reshape(Xwi1, [], 1);

Xwi2 = Xg2(:,20:21,:,20,:,20);
Xwi2 = Xwi2 .* w;
Xwi2 = sum(Xwi2, 2, 'includenan') ./ sum(w);
Xwi2 = reshape(Xwi2, [], 1);

Xwi = [Xwi1, Xwi2];

%% Weighted omit nan

subWO = [19 19 19;20 20 20];
svvWO = svv2.mean(2, {0:1}, true, 'test');
svvWO = svvWO.weightedMean(2, {1:2}, 'test');
w = repmat([1 2], [3 1 3 1 3 1]);

Xwo1 = Xg2(:,19:20,:,19,:,19);
w1 = w;
w1(isnan(Xwo1)) = NaN;
Xwo1 = Xwo1 .* w1;
Xwo1 = sum(Xwo1, 2, 'omitnan') ./ sum(w1,2,'omitnan');
Xwo1 = reshape(Xwo1, [], 1);

Xwo2 = Xg2(:,20:21,:,20,:,20);
w2 = w;
w2(isnan(Xwo2)) = NaN;
Xwo2 = Xwo2 .* w2;
Xwo2 = sum(Xwo2, 2, 'omitnan') ./ sum(w2,2,'omitnan');
Xwo2 = reshape(Xwo2, [], 1);

Xwo = [Xwo1, Xwo2];


%% Multiple weighted include nan

subXWI = [19 19 19;20 20 20];
svvXWI = svv2.mean([2 4], {0:1, 0:1}, [false false], 'test');
svvXWI = svvXWI.weightedMean([2 4], {1:2,3:4}, 'test');
w2 = [1 2];
w4 = cat(4,3,4);

X1 = Xg2(:,19:20,:,19:20,:,19);
X1 = X1 .* w2;
X1 = sum(X1, 2, 'includenan') ./ sum(w2);
X1 = X1 .* w4;
X1 = sum(X1, 4, 'includenan') ./ sum(w4);
X1 = reshape(X1, [], 1);

X2 = Xg2(:,20:21,:,20:21,:,20);
X2 = X2 .* w2;
X2 = sum(X2, 2, 'includenan') ./ sum(w2);
X2 = X2 .* w4;
X2 = sum(X2, 4, 'includenan') ./ sum(w4);
X2 = reshape(X2, [], 1);

Xxwi = [X1, X2];


%% Multiple weighted omitnan

subXWO = [19 19 19;20 20 20];
svvXWO = svv2.mean([2 4], {0:1,0:1}, [true true], 'test');
svvXWO = svvXWO.weightedMean([2 4], {1:2,3:4}, 'test');
w2 = repmat([1 2], [3 1 3 2 3 1]);
w4 = cat(4,3,4);
w4 = repmat(w4, [3 1 3 1 3 1]);

X1 = Xg2(:,19:20,:,19:20,:,19);
w = w2;
w(isnan(X1)) = NaN;
X1 = X1 .* w;
X1 = sum(X1,2,'omitnan') ./ sum(w,2,'omitnan');
w = w4;
w(isnan(X1)) = NaN;
X1 = X1 .*w;
X1 = sum(X1,4,'omitnan') ./ sum(w,4,'omitnan');
X1 = reshape(X1, [],1);

X2 = Xg2(:,20:21,:,20:21,:,20);
w = w2;
w(isnan(X2)) = NaN;
X2 = X2 .* w;
X2 = sum(X2,2,'omitnan') ./ sum(w,2,'omitnan');
w = w4;
w(isnan(X2)) = NaN;
X2 = X2 .*w;
X2 = sum(X2,4,'omitnan') ./ sum(w,4,'omitnan');
X2 = reshape(X2, [],1);

Xxwo = [X1, X2];


%% Mixed weighted nanflag



%% Tests

tests = {
    % Description, object, subMembers, output
    'state mean', svvSM, subSM, Xsm, grid, source, dims
    'ensemble mean', svvEM, subEM, Xem, grid, source, dims
    'mixed mean', svvXM, subXM, Xxm, grid, source, dims

    'sequence', svvSeq, subSeq, Xseq, grid, source, dims
    'multiple sequences', svvXSeq, subXSeq, Xxseq, grid2, source2, dims2
    'sequence and mean', svvSeqM, subSeqM, Xseqm, grid2, source2, dims2
    'multiple sequence and mean', svvXSeqM, subXSeqM, Xxseqm, grid2, source2, dims2
    'multiple mixed sequence and mean', svvX2sm, subX2sm, Xx2sm, grid2, source2, dims2
 
    'include nan', svvI, subI, Xi, grid, source, dims
    'omit nan', svvO, subO, Xo, grid, source, dims
    'mixed nan', svvXN, subXN, Xxn, grid, source, dims

    'weighted includenan', svvWI, subWI, Xwi, grid2, source2, dims2
    'weighted omitnan', svvWO, subWO, Xwo, grid2, source2, dims2
    'multiple weighted includenan', svvXWI, subXWI, Xxwi, grid2, source2, dims2
    'multiple weighted omitnan', svvXWO, subXWO, Xxwo, grid2, source2, dims2
    };


try
    for t = 1:size(tests,1)
        obj = tests{t,2};
        subMembers = tests{t,3};
        obj = obj.finalize;

        parameters = obj.parametersForBuild;
        parameters.indexLimits = obj.indexLimits(tests{t,7}, subMembers, false);
        parameters.loadAllMembers = true;

        X = obj.buildMembers(tests{t,7}, subMembers, tests{t,5}, tests{t,6}, parameters, 'double');
        Xout = tests{t,4};
        assert(isequaln(X, Xout), 'output');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end

function[] = serialization

% Build a large selection of variables. Variables should have different
% dimension sizes and use different options.
gridLLT = gridfile('test-llt');
gridLLTR = gridfile('test-lltr');

svv1 = dash.stateVectorVariable(gridLLTR);
svv2 = dash.stateVectorVariable(gridLLT);

svv1 = svv1.design(3:4, [2 2], {[],[]}, 'test');
svv2 = svv2.design([1 3], [2 2], {[],[]}, 'test');
svvTest = [svv1;svv2;svv2;svv1;svv2];

mean1 = svv1.mean([1 4],{[],-1:1}, [false true], 'test');
mean2 = svv2.mean([2 3], {[],[-4 0 9]}, [true false], 'test');
convert1 = svv1.metadata([1 4], 2, {@mean, @svd}, {{1,'includenan',"arg",5},{}}, 'test');
convert2 = svv2.metadata([2 3], 2, {@times, @plus}, {{},{6}}, 'test');
index1 = svv1.design([1 4], [1 2], {[2 6 19 22 87], []}, 'test');
index2 = svv2.design([2 3], [1 2], {[], 200:5:499}, 'test');
seq1 = svv1.sequence([3 4], {-4:9, 0:1}, {rand(14,3), ["A","String";"meta","matrix"]}, 'test');
seq2 = svv2.sequence(3, {-4:9}, {(1:14)'}, 'test');
weights1 = mean1.weightedMean([1 4], {5*ones(100,1), rand(3,1)}, 'test');
weights2 = mean2.weightedMean(2, {7*ones(20,1)}, 'test');
meta1 = svv1.metadata([1 4], 1, {rand(100,3), [1;2;3]}, [], 'test');
meta2 = svv2.metadata([2 3], 1, {rand(20,2), rand(1000,2)}, [], 'test');

tests = {
    'omitnan', [mean1;mean2]
    'NaN mean size', svvTest
    'mixed NaN mean size', [mean1;mean2]
    'empty convertFunctions', svvTest
    'mixed convertFunctions',[convert1;convert2]
    'empty convert args', svvTest
    'mixed convert args',[convert1;convert2]
    'empty indices',svvTest
    'mixed indices', [index1;index2]
    'ens, empty mean indices', [mean2;mean2;svv2;svv1]
    'ens, mixed mean indices', [mean1;mean2]
    'ens, no sequences', svvTest
    'ens, mixed sequences', [seq1;seq2]
    'empty weights', svvTest
    'mixed weights', [weights1;weights2]
    'no alt metadata',svvTest
    'mixed alt metadata',[meta1;meta2]
    };

try
    for t = 1:size(tests,1)
        svv = tests{t,2};
        s = svv.serialize;
        rebuilt = dash.stateVectorVariable.deserialize(s);
        assert(isequaln(svv, rebuilt), 'not equivalent');
    end
catch cause
    ME = MException('test:failed', '%.f: %s', t, tests{t,1});
    ME = addCause(ME, cause);
    throw(ME);
end

end
