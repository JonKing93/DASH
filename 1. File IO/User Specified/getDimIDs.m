function[dimID, varSpecs, lonDim, latDim, levDim, timeDim, ensDim, triDim] = getDimIDs
%% This creates string IDs for all dimensions that can possibly occur in gridded data.

% Variable specifications.
varSpecs = 'varSpecs';

% Longitude (x coordinate)
lonDim = 'lon';

% Latitude (y coordinate)
latDim = 'lat';

% Level (z / height coordinate)
levDim = 'lev';

% Time 
timeDim = 'time';

% Ensemble
ensDim = 'run';

% Tripole
triDim = 'tripole';

% All dimensions
dimID = {lonDim, latDim, levDim, timeDim, ensDim, triDim};

end