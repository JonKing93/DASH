%% stateVector quickstart
% This provides an outline of stateVector use.


% Create new state vector
sv = stateVector('my vector');


% Add a variable
sv = sv.add("T", 'my-temperature-data.grid');


% Design dimensions
grid = gridfile('my-temperature-data.grid');
meta = grid.metadata;
june = month(meta.time==6);
run2 = meta.run==2;
NH = meta.lat>0;

dims = ["lat","time","run"];
type = ["state","ensemble","ensemble"];
indices = {NH, june, run2};
sv = sv.design('T', dims, type, indices);


% Use a sequence
indices = [0 1 2];
metadata = ["June";"July";"August"];
sv = sv.sequence("T", "time", indices, metadata);


% Take a mean
sv = sv.mean('T', 'lat');
sv = sv.mean('T', 'time', [0 1 2]);


% Take a weighted mean
weights = cosd( meta.lat(NH) );
sv = sv.weightedMean('T', 'lat', weights);


% Build an ensemble
X = sv.buildEnsemble(150);
