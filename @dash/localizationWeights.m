function[wloc, yloc] = localizationWeights(type, varargin)
%% Returns localization weights
%
% [wloc, yloc] = localizationWeights('gc2d', ensCoords, siteCoords, R)
% [...] = localizationWeights('gc2d', ensCoords, siteCoords, R, scale)
% Calculates localization weights using a Gaspari-Cohn 5th order polynomial
% over 2 dimensions. Calculates weights using horizontal (latitude - 
% longitude) distances.
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

% Error check the type
dash.assertStrFlag(type, 'The first input');
allowedTypes = "gc2d";
assert( any(strcmpi(type, allowedTypes)), ...
    sprintf(['The first input must be a recognized localization scheme. ',...
    'Recognized types are: %s.'], dash.messageList(allowedTypes)) );

% Switch to the appropriate localization scheme
if strcmpi(type, 'gc2d')
    [wloc, yloc] = gc2dLocalization(varargin{:});
end

end

