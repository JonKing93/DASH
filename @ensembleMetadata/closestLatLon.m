function[rows] = closestLatLon(obj, latlon, varName, verbose)
%% Returns the state vector rows closest to a set of lat-lon coordinates
%
% rows = obj.closestLatLon( coordinate )
% Returns the state vector rows closest to the given coordinate.
%
% rows = obj.closestLatLon( coordinate, varName )
% Returns the state vector rows that are closest to the given coordinate
% for a particular variable.
%
% rows = obj.closestLatLon( coordinate, varName, verbose )
% Optionally disable console messages.
%
% ----- Inputs -----
%
% coordinate: A latitude-longitude coordinate. A vector with two elements.
%    The first element is the latitude coordinate and the second element is
%    the longitude coordinate.
%
% varName: The name of a variable in the state vector ensemble. A string.
%
% verbose: A scalar logical that indicates whether to return console
%    messages when determining coordinates (true -- default) or not (false)
%
% ----- Outputs -----
%
% rows: The rows of the state vector that are closest to the selected
%    lat-lon coordinate.

% Defaults
if ~exist('varName','var') || isempty(varName)
    varName = [];
end
if ~exist('verbose','var') || isempty(verbose)
    verbose = [];
end

% Error check the user-specified coordinate
assert( isnumeric(latlon) & isvector(latlon), 'latlon must be a numeric vector.');
assert(numel(latlon)==2, 'latlon must have two elements.');
dash.assertRealDefined(latlon, 'latlon');
assert(abs(latlon(1))<=90, 'latitude coordinates must be between -90 and 90.');

% Get the state vector lat-lon coordinates and get the distance to each
svLatLon = obj.coordinates(varName, verbose);
dist = dash.haversine(svLatLon, latlon);

% Find the state vector rows associated with the minimum distances
rows = find(dist==min(dist));
if ~isempty(varName)
    rows = obj.findRows(varName, rows);
end

end