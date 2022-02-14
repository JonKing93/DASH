function[] = tests

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