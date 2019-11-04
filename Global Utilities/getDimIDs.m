function[dimID, atts, varName, lonDim, latDim, levDim, timeDim, runDim, triDim, varDim] = getDimIDs
%% This creates string IDs for all dimensions that can possibly occur in gridded data.
%
% dimID = getDimIDs
% Returns a list of data dimensions.
%
% [dimID, specs, varName, lonDim, latDim, levDim, timeDim, runDim, triDim] = getDimIDs
% Returns a list of data dimensions and all unique names used by Dash.

% Variable specifications. These are non-gridded metadata.
atts = "attributes";

% Variable name field in ensemble metadata
varName = "varName";

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

% Variable dimension
varDim = "var";

% All grid dimensions
dimID = [lonDim, latDim, triDim, levDim, timeDim, runDim, varDim];

end