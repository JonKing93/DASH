function[] = tests

% Move to test folder
here = mfilename('fullpath');
folders = strsplit(here, filesep);
dash = folders(1:end-3);
testpath = fullfile(dash{:}, 'testdata', 'dash', 'stateVectorVariable');

home = pwd;
gohome = onCleanup( @()cd(home) );
cd(testpath);

%%% Current test
validateGrid;
%%%

% Run tests
constructor;

dimensions;
dimensionIndices;

design;
sequence;
mean;
weightedMean;
metadata;

validateGrid
getMetadata

ensembleSizes
trim
matchMetadata
removeOverlap

finalize
addIndices
indexLimits
parametersForBuild
buildMembers

serialize
deserialize

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
assert(isequal(svv.meanSize, NaN(1,0)));
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
assert(isequaln(svv.meanSize, NaN(1,nDims)));
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

function[] = design

% Initial svv
% svv with ens dims
% svv with indexed ens dims
% svv with sequence
% svv with metadata
% svv with weights


tests = {
    'single design', true, svv, 3, false, {[]},
    'multiple dims',true, svv, [3 4], [false, false], {[],[]}
    'dims with 0',true, svv, [4 0 3], [false false false], {[],[],[]}

    'state to ens',true, 3, false, {1:3}
    'ens to state',true, svv2, 3, true, {1:5}
    'state to mixed',true, svv, [1 2], [true false], {1:9,1:6}
    'ens to mixed',true, svv2, [3 4], [true false], {1:9,2}
    'mixed to mixed',true, svv2, 1:4, [true false true false], {[],[],[],[]}

    'ens to state, reset sequence', true,
    'ens to state, reset metadata', true,
    'ens to state, previous mean', true,

    'logical indices wrong length',false, svv, 3, false, {true(4,1)}
    'linear indices too large',false, svv, 3, false, {10000}
    'empty indices, state',true, svv2, 3, true, {[]}
    'empty indices, ens',true, svv, 3, false, {[]}
    'repeat indices, state',true, svv, 1, true, {[1 1 1]}
    'repeat indices, ens', true, svv, 3, false, {[1 1 1]}

    'weights conflict',false, svvWeight, 1, true, {1:3}
    'metadata conflict',false, svvMeta, 3, false, {1:3}
    'mean indices conflict',false,svvMean, 3, true, {[]} 
    };






error('unfinished');
end
function[] = sequence

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [false false], {[],[]}, 'test');
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
function[] = mean

grid = gridfile('test-lltr.grid');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [false false], {[],[]}, 'test');
svvM = svv.mean(1:4, {[],[],1:3,2}, false(1,4), 'test');
svvW = svvM.weightedMean([1 3], {ones(100,1), ones(3,1)}, 'test');

tests = {
    % test, succeed, object, dims, indices, omitnan,...
    % meanType, meanSize, stateSize, meanIndices, omitnan, weights
    'disable mean, weighted', true, svvW, [1 3], "none", [], [0 1 0 1], [NaN 20 NaN 1], [100 1 1 1], {[],[],[],2}, false(1,4), {[],[],[],[]}
    'disable mean, unweighted', true, svvM, [1 3], "none", [], [0 1 0 1], [NaN 20 NaN 1], [100 1 1 1], {[],[],[],2}, false(1,4), {[],[],[],[]}
    'disable mean, no mean', true, svv, [1 3], "none", [], [0 0 0 0], NaN(1,4), [100 20 1 1], {[],[],[],[]}, false(1,4), {[],[],[],[]}
    'disable weights', true, svvW, [1 3], "unweighted", [], [1 1 1 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, false(1,4), {[],[],[],[]}
    'disable weights, no weights', true, svvM, [1 3], "unweighted", [], [1 1 1 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, false(1,4), {[],[],[],[]}
    'disable weights, no mean', false, svv, [1 3], "unweighted", [], [],[],[],[],[],[]
    
    'state mean', true, svv, [1 2], {[],[]}, [true true], [1 1 0 0], [100 20 NaN NaN], [1 1 1 1], {[],[],[],[]}, [true true false false], {[],[],[],[]}
    'mean indices for state', false, svv, [1 2], {[],-2:2}, [true true],[],[],[],[],[],[]
    'state mean, previous mean', true, svvM, [1 2], {[],[]}, [true true], [1 1 1 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, [true true false false], {[],[],[],[]}
    'state mean, previous weights', true, svvW, [1 2], {[],[]}, [true true], [2 1 2 1], [100 20 3 1], [1 1 1 1], {[],[],(1:3)',2}, [true true false false], {ones(100,1),[],ones(3,1),[]}

    'ens mean',true, svv, [3 4], {1:3, 2}, [true true], [0 0 1 1], [NaN NaN 3 1], [100 20 1 1], {[],[],(1:3)',2}, [false false, true true], {[],[],[],[]}
    'ens mean, no indices', false, svv, [3 4], {1:3, []}, [true true],[],[],[],[],[],[]
    'indices too large', false, svv, 3, {10000}, true,[],[],[],[],[],[]
    'indices too small', false, svv, 3, {-100000}, true,[],[],[],[],[],[]
    'ens mean, previous mean', true, svvM, 3, {1:5}, false, [1 1 1 1], [100 20 5 1], [1 1 1 1], {[],[],(1:5)',2}, false(1,4), {[],[],[],[]}
    'ens mean, previous weights', true, svvW, 3, {-1:1}, false, [2 1 2 1], [100 20 3 1], [1 1 1 1], {[],[],(-1:1)',2}, false(1,4), {ones(100,1),[],ones(3,1),[]}
    'ens mean, weights conflict', false, svvW, 3, {-2:1}, false,[],[],[],[],[],[]

    'ens, include nan', true, svv, 3, {-1:1}, true, [0 0 1 0], [NaN NaN 3 NaN], [100 20 1 1], {[],[],(-1:1)',[]}, [false false true false], {[],[],[],[]}
    'state, include nan', true, svv, 1, {[]}, true, [1 0 0 0], [100 NaN NaN NaN], [1 20 1 1], {[],[],[],[]}, [true false false false], {[],[],[],[]}
    'mixed ens/state', true, svv, [1 3], {[], -1:1}, [false true], [1 0 1 0], [100 NaN 3 NaN], [1 20 1 1], {[],[],(-1:1)',[]}, [false false true false], {[],[],[],[]}
    'dims with 0', true, svv, [3 0 1], {-1:1,[],[]}, [true false false], [1 0 1 0], [100 NaN 3 NaN], [1 20 1 1], {[],[],(-1:1)',[]}, [false false true false], {[],[],[],[]}
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
svv = svv.design([3 4], [false false], {[],[]}, 'test');
svvM = svv.mean(1:4, {[],[],(12:12:36)',2}, false(1,4), 'test');
svvW = svvM.weightedMean([1 2 3], {ones(100,1), ones(20,1), ones(3,1)}, 'test');

tests = {
    % test, succeed, obj, dims, weights, ...
    % (output) meanType, weights, state size, mean size
    'remove weights, no mean' true, svv, [1 3], {[],[]}, [0 0 0 0], {[],[],[],[]}, [100 20 1 1], NaN(1,4)
    'remove weights, no weights', true, svvM, [1 3], {[],[]}, [1 1 1 1], {[],[],[],[]}, [1 1 1 1], [100 20 3 1]
    'remove weights, weighted', true, svvW, [1 3], {[],[]}, [1 2 1 1], {[],ones(20,1),[],[]}, [1 1 1 1], [100 20 3 1]

    'set new weights', true, svvM, [1 3], {ones(100,1), ones(3,1)}, [2 1 2 1], {ones(100,1),[],ones(3,1),[]}, [1 1 1 1], [100 20 3 1]
    'update existing weights', true, svvW, [1 3], {5*ones(100,1), 6*ones(3,1)}, [2 2 2 1], {5*ones(100,1), ones(20,1),6*ones(3,1),[]}, [1 1 1 1], [100 20 3 1]
    'mean index size conflict', false, svvM, 3, {ones(4,1)}, [],[],[],[]
    'state size conflict', false, svvM, 1, {ones(101,1)}, [],[],[],[]
    'size conflict, weighted', false, svvW, 3, {ones(4,1)}, [],[],[],[]
    
    'set new state mean', true, svv, 1, {ones(100,1)}, [2 0 0 0], {ones(100,1),[],[],[]}, [1 20 1 1], [100 NaN NaN NaN], 
    'new state, size conflict', false, svv, 1, {ones(101,1)}, [],[],[],[]
    'set new ens mean', false, svv, 3, {ones(3,1)}, [],[],[],[]
    'new ens mean no weights', true, svv, 3, {[]}, [0 0 0 0], {[],[],[],[]}, [100 20 1 1], NaN(1,4)

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
svv = svv.design([3 4], [false false], {[],[]}, 'test');
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
    
    'state dimension', false, svv,1,0,[],[], [],[],[],[]
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







