function[dimID, specs, varName, lonDim, latDim, levDim, timeDim, runDim, triDim] = getDimIDs
%% This creates string IDs for all dimensions that can possibly occur in gridded data.
%
% [dimID, specs, varName, lonDim, latDim, levDim, timeDim, runDim, triDim] = getDimIDs

% Variable specifications. These are non-gridded metadata.
specs = "specs";

% Variable name field in ensemble metadata
varName = "var";

% Longitude (x coordinate)
lonDim = "lon";

% Latitude (y coordinate)
latDim = "lat";

% Tripole (x-y coordinate)
triDim = "tri";

% Level (z or height coordinate)
levDim = "lev";

% Time 
timeDim = "time";

% Ensemble
runDim = "run";

% All grid dimensions
dimID = [lonDim, latDim, triDim, levDim, timeDim, runDim];

end