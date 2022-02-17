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

%%% Current test
indexLimits
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

validateGrid;
getMetadata;

ensembleSizes;
trim;
matchMetadata;
removeOverlap;

finalize;
addIndices;
indexLimits;
parametersForBuild;
buildMembers;

serialize;
deserialize;

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

    'state to state, weights conflict',false, svvWeight, 1, true, {1:3}
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
svv = svv.design(1:4, [true true false false], {lons, lats, times, runs}, "test");

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

function[] = ensembleSizes

grid = gridfile('test-lltr');
svvState = dash.stateVectorVariable(grid);
svvEns = svvState.design(1:4, [false, false, false, false], {[],[],[],[]}, 'test');
svv = svvState.design(3:4, [false, false], {[],[]}, 'test');

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
function[] = trim

timeAddP = [-4 -1];
timeAddE = [1 4];
timeAddPE = [-4 1 -1 4];

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design([3 4], [false false], {[],[]}, 'test');

allLon = (1:svv.gridSize(1))';
allLat = (1:svv.gridSize(2))';
allTime = (1:svv.gridSize(3))';
allRun = (1:svv.gridSize(4))';
altMeta = [allTime, 1000+allTime];

svvN = svv.design(3, false, {1}, 'test');
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
svv = svv.design(3, false, {[]}, 'test');
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
svv = svv.design(1:3, [false false false], {[],[],[]}, 'test');
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

empty = svv.design([3 4], [false false], {[],[]}, 'test');
mixedIndex = svv.design(1:4, [true true false false], {[],lats,[],runs}, 'test');
allIndex = svv.design(1:4, [true true false false], {lons,lats,times,runs}, 'test');
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
svv = svv.design(3, false, {[]}, 'test');
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
function[] = indexLimits

grid = gridfile('test-lltr');
svv = dash.stateVectorVariable(grid);
svv = svv.design(1:4,[false true false false], {[],[],[],[]}, 'test');
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



