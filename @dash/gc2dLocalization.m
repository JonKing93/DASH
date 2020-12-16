function[wloc, yloc] = gc2dLocalization(ensCoords, siteCoords, R, scale)
%% Determines localization weights using a Gaspari-Cohn 5th order polynomial
% in 2 dimensions.
%
% [wloc, yloc] = gc2dLocalization(ensCoords, siteCoords, R)
% Determines localization weights for a specified cutoff radius.
%
% [wloc, yloc] = gc2dLocalization(ensCoords, siteCoords, R, scale)
% Also sets the length scale for the polynomial.
%
% ----- Inputs -----
%
% ensCoords: Latitude-longitude coordinates for an ensemble. A numeric
%    matrix with two columns. The first column contains latitude
%    coordinates and the second column is longitude.
%
% siteCoords: Latitude-longitude coordinates for proxy/observation sites. A
%    numeric matrix with two columns. The first column hold latitude
%    coordinates and the second column is longitude.
%
% R: The localization radius in kilometers. A positive scalar.
%
% scale: The length scale for the Gaspari-Cohn polynomial. A scalar on the
%    interval (0, 0.5]. By default, the length scale is set to 0.5, which
%    sets the covariance cutoff radius equal to R.
%
% ----- Outputs -----
%
% wloc: Localization weights between each state vector element (rows) and
%    the proxy sites (columns). A numeric matrix.
%
% yloc: Localization weights between each proxy site and the other proxy
%    sites. A symmetric numeric matrix.

% Default for unset scale
if ~exist('scale','var')
    scale = [];
end

% Error check the coordinates
assert(isnumeric(ensCoords), 'ensCoords must be numeric');
assert(isnumeric(siteCoords), 'siteCoords must be numeric');
dash.assertRealDefined(ensCoords, 'ensCoords', true, true);
dash.assertRealDefined(siteCoords, 'siteCoords', true, true);
assert(ismatrix(ensCoords), 'ensCoords must be a matrix');
assert(ismatrix(siteCoords), 'siteCoords must be a matrix');
assert(size(ensCoords,2)==2, 'ensCoords must have 2 columns');
assert(size(siteCoords,2)==2, 'siteCoords must have 2 columns');

% Get the distances
wdist = dash.haversine(stateCoord, siteCoords);
ydist = dash.haversine(siteCoord);

% Apply the Gaspari-Cohn polynomial
wloc = dash.gaspariCohn2D(wdist, R, scale);
yloc = dash.gaspariCohn2D(ydist, R, scale);

end