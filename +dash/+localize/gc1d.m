function[wloc, yloc] = gc1d(stateDepths, siteDepths, distance, scale)
%% dash.localize.gc1d  Computes localization weights along a depth/height/Z dimension using a Gaspari-Cohn 5th order polynomial
% ----------
%   [wloc, yloc] = dash.localize.gc1d(stateDepths, siteDepths, distance)
%   Calculates covariance localization weights for an assimilation using a
%   specified cutoff distance. The method proceeds by determining the
%   distances between a set of depths/heights/Z-coordinates and then applying 
%   a Gaspari-Cohn 5th order polynomial to the distances. This can be used 
%   to implement localization along the depth/height/Z coordinate of 
%   an ensemble.
%
%   [wloc, yloc] = dash.localize.gc1d(stateDepths, siteDepths, distance, scale)
%   Specifies the length scale for the polynomial. By default, uses a
%   length scale of 0.5, which sets the localization distance equal to the
%   cutoff distance.
% ----------
%   Inputs:
%       stateDepths (numeric vector [nState]): The depth/height/Z coordinate
%           of the state vector elements. Any units are permitted so long 
%           as the siteDepths and cutoff distance use the same units.
%       siteDepths (numeric vector [nSite]): The depth/height/Z coordinate
%           of the proxy sites. Should use the same units as stateDepths.
%       distance (positive numeric scalar): The localization cutoff
%           distance. Should use the same units as stateDepths
%       scale (numeric scalar): The length scale to use for the
%           Gaspari-Cohn polynomial. Must be on the interval
%           0 < scale <= 0.5.  By default, uses a length scale of 0.5,
%           which sets the localization distance equal to the cutoff distance
%
%   Outputs:
%       wloc (numeric matrix [nState x nSite]): The covariance localization
%           weights between the state vector elements and proxy\observation sites.
%       yloc (numeric matrix [nSite x nSite]): The covariance localization
%           weights between the proxy/observation sites and one another.
%
% <a href="matlab:dash.doc('dash.localize.gc1d')">Documentation Page</a>

% Header
header = "DASH:localize:gc1d";

% Check state depths
name = 'state vector coordinates';
dash.assert.vectorTypeN(stateDepths, 'numeric', [], 'stateDepths', header);
dash.assert.defined(stateDepths, 4, name, header);

% Check site depths
name = 'proxy / observation site coordinates';
dash.assert.vectorTypeN(siteDepths, 'numeric', [], 'siteDepths', header);
dash.assert.defined(siteDepths, 4, name, header);

% Check cutoff distance
name = 'localization distance';
dash.assert.scalarType(distance, 'numeric', name, header);
dash.assert.defined(distance, 3, name, header);
if distance<=0
    invalidDistanceError(header);
end

% Default and error check length scale
if ~exist('scale','var') || isempty(scale)
    scale = 0.5;
else
    dash.assert.scalarType(scale, 'numeric', 'scale', header);
    dash.assert.defined(scale, 1, 'scale', header);
    if scale<=0 || scale>0.5
        invalidScaleError(header);
    end
end

% Infinite distance is no localization
if isinf(distance)
    nState = length(stateDepths);
    nSite = length(siteDepths);
    wloc = ones(nState, nSite);
    yloc = ones(nSite, nSite);
    return
end

% Begin with column vectors to ensure correct sizing
if isrow(stateDepths)
    stateDepths = stateDepths';
end
if isrow(siteDepths)
    siteDepths = siteDepths';
end

% Compute distances between 1. sites and state vector elements, 2. sites
% and one another
wDistance = abs(stateDepths - siteDepths');
yDistance = abs(siteDepths - siteDepths');

% Apply the Gaspari-Cohn polynomial
wloc = dash.math.gaspariCohn(wDistance, distance, scale);
yloc = dash.math.gaspariCohn(yDistance, distance, scale);

end

%% Error messages
function[] = invalidDistanceError(header)
id = sprintf('%s:invalidCutoffDistnace', header);
ME = MException(id, 'The localization cutoff distance must be positive.');
throwAsCaller(ME);
end
function[] = invalidScaleError(header)
id = sprintf('%s:invalidLengthScale', header);
ME = MEXception(id, 'The length scale must be on the interval:  0 < scale <= 0.5');
throwAsCaller(ME);
end