function[wloc, yloc] = gc2d(stateCoordinates, siteCoordinates, R, scale)
%% dash.localize.gc2d  Computes localization weights using a Gaspari-Cohn 5th order polynomial in 2 dimensions
% ----------
%   [wloc, yloc] = dash.localize.gc2d(ensCoords, siteCoords, R)
%   Calculates covariance localization weights for an assimilation using a
%   specified cutoff radius. The method proceeds by using a haversine
%   function to dtermine the distances between 1. proxy sites and state
%   vector elements, and 2. proxy sites with one another. Then, covariance
%   localization weights are calculated by applying a 5th order,
%   Gaspari-Cohn polynomial in 2 dimensions to the distances. If the
%   distance between two points is NaN, returns a weight of 1 (i.e. no
%   localization).
%
%   [wloc, yloc] = dash.localize.gc2d(ensCoords, siteCoords, R, scale)
%   Also specifies the length scale for the polynomial. By default, uses a
%   length scale of 0.5, which sets the localization radius equal to the
%   cutoff radius.
% ----------
%   Inputs:
%       stateCoordinates (numeric matrix [nState x 2]): The coordinates of
%           the state vector elements (in decimal degrees). A matrix with
%           two columns. The first column holds the latitude points, and
%           the second column holds longitude. The method is agnostic to
%           longitudes on -180:180 and 0:360 coordinates systems, so you
%           may use either system or even a mix of both. 
%       siteCoordinates (numeric matrix [nSite x 2]): The coordinates of
%           the proxy / observation sites (in decimal degrees). A matrix with
%           two columns. The first column holds the latitude points, and
%           the second column holds longitude. The method is agnostic to
%           longitudes on -180:180 and 0:360 coordinates systems, so you
%           may use either system or even a mix of both. 
%       R (positive numeric scalar): The localization radius (in kilometers).
%       scale (numeric scalar): The length scale to use for the
%           Gaspari-Cohn polynomial. Must be on the interval
%           0 < scale <= 0.5.  By default, uses a length scale of 0.5,
%           which sets the localization radius equal to the cutoff radius.
%       
%   Outputs:
%       wloc (numeric matrix [nState x nSite]): The covariance localization
%           weights between the state vector elements and proxy\observation sites.
%       yloc (numeric matrix [nSite x nSite]): The covariance localization
%           weights between the proxy/observation sites and one another.
%
% <a href="matlab:dash.doc('dash.localize.gc2d')">Documentation Page</a>

% Header
header = "DASH:localize:gc2d";

% Error check coordinates
name = 'state vector coordinates';
dash.assert.matrixTypeSize(stateCoordinates, 'numeric', [NaN 2], name, header);
dash.assert.defined(stateCoordinates, 4, name, header);

name = 'proxy / observation site coordinates';
dash.assert.matrixTypeSize(siteCoordinates, 'numeric', [NaN 2], name, header);
dash.assert.defined(siteCoordinates, 4, name, header);

% Error check cutoff radius
name = 'localization radius (R)';
dash.assert.scalarType(R, 'numeric', name, header);
dash.assert.defined(R, 3, name, header);
if R<=0
    invalidRadiusError(header);
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

% Infinite radius is no localization
if isinf(R)
    nState = size(stateCoordinates, 1);
    nSite = size(siteCoordinates, 1);
    wloc = ones(nState, nSite);
    yloc = ones(nSite, nSite);
    return
end

% Compute distances between 1. the sites and state vector elements, and
% 2. the sites with one another
wDistance = dash.math.haversine(stateCoordinates, siteCoordinates);
yDistance = dash.math.haversine(siteCoordinates);

% Apply the Gaspari-Cohn polynomial
wloc = dash.math.gaspariCohn(wDistance, R, scale);
yloc = dash.math.gaspariCohn(yDistance, R, scale);

% NaN weights receive no localization
wloc(isnan(wloc)) = 1;
yloc(isnan(yloc)) = 1;

end

%% Error messages
function[] = invalidRadiusError(header)
id = sprintf('%s:invalidCutoffRadius', header);
ME = MException(id, 'The localization cutoff radius must be positive.');
throwAsCaller(ME);
end
function[] = invalidScaleError(header)
id = sprintf('%s:invalidLengthScale', header);
ME = MEXception(id, 'The length scale must be on the interval:  0 < scale <= 0.5');
throwAsCaller(ME);
end