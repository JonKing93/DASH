function[weights, yloc] = localizationWeights( siteCoord, stateCoord, R, scale)
% Redirects to dash.spatialLocalization

warning(['dash.localizationWeights has been renamed to dash.spatialLocalization, and ', ...
         'will be removed in a future release. Please consider updating your code.']);

if ~exist('siteCoord','var')
    siteCoord = [];
end
if ~exist('stateCoord','var')
    stateCoord = [];
end
if~exist('R','var')
    R = [];
end
if ~exist('scale','var')
    scale = [];
end
[weights, yloc] = dash.spatialLocalization( siteCoord, stateCoord, R, scale );

end