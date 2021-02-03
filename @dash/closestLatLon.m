function[closest] = closestLatLon(coords, lats, lons)
%% Searches vectors of latitudes and longitudes to find the points closest
% to a set of coordinates.
%
% closest = dash.closestLatLon(coords, lats, lons)
%
% ----- Inputs -----
%
% coords: A set of latitude-longitude coordinates. A matrix with two
%    columns. The first column contains latitude coordinates and the second
%    contains longitude coordinates.
%
% lats: A vector of latitude points
%
% lons: A vector of longitude points
%
% ----- Outputs -----
%
% closest: The latitude-longitude points that are closest to the input
%    coordinates. A matrix with two columns. First column is latitude,
%    second column is longitude. Each row holds the closest point for an
%    input coordinate.

% Error check
assert(isnumeric(coords)&&ismatrix(coords)&&size(coords,2)==2, 'coords must be a numeric matrix with 2 columns');
assert(isnumeric(lats)&&isvector(lats), 'lats must be a numeric vector');
assert(isnumeric(lons)&&isvector(lons), 'lons must be a numeric vector');
dash.assertRealDefined(coords, 'coords');
dash.assertRealDefined(lats, 'lats');
dash.assertRealDefined(lons, 'lons');
assert(abs(lats)<=90, 'The elements of "lats" must be between -90 and 90');
assert(abs(coords(:,1))<=90, 'The latitude points in the first column of "coords" must be between -90 and 90');

% Propagate the lats and lons into all points
nLat = numel(lats);
nLon = numel(lons);
lats = repmat(lats(:)', [nLon, 1]);
lons = repmat(lons(:) , [1, nLat]);
latlon = [lats(:), lons(:)];

% Use haversine to find the closest point to each coordinate
dist = dash.haversine(coords, latlon);
[~, closest] = min(dist, [], 2);
closest = latlon(closest, :);

end