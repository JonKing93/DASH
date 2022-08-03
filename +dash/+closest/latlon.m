function[coordinates, latIndices, lonIndices] = latlon(coordinates, lats, lons)
%% dash.closest.latlon  Returns the latitude-longitude points closest to a set of coordinates
% ----------
%   [coordinates] = dash.closest.latlon(coordinates, lats, lons)
%   Searches through combinations of latitude and longitude points to find
%   the values that are closest to specified latitude-longitude
%   coordinates. This method is often used to locate the elements of a
%   gridded dataset that are closest to a specific set of coordinates. Thus,
%   the second and third inputs are usually the latitude and longitude
%   metadata of a gridded dataset. 
% 
%   This function uses a haversine function to calculate the distance
%   between sites. The haversine function is agnostic to longitude
%   coordinate systems, so you may use longitudes on either -180:180 or
%   0:360, or even a mix of both coordinate systems.
%
%   [coordinates, latIndices, lonIndices] = dash.closest.latlon(...)
%   Also returns the indices of the closest latitude and closest longitude
%   points within the examined sets of points. These outputs can be used to
%   index into the closest elements of a gridded dataset.
% ----------
%   Inputs:
%       coordinates (numeric matrix [nCoordinates x 2]): A set of
%           latitude-longitude coordinates in decimal degrees. The method
%           will search for latitude-longitude combinations that are closest
%           to these points. A numeric matrix with two columns. The first column
%           holds the latitude points, and the second column is longitude.
%       lats (numeric vector [nLats]): The latitude points (decimal degrees) for the
%           latitude-longitude combinations that will be tested. This is
%           often the latitude metadata of a gridded dataset.
%       lons (numeric vector [nLons]): The longitude points (decimal degrees) for the
%           latitude-longitude combinations that will be tested. This is
%           often the longitude metadata of a gridded dataset.
%
%   Outputs:
%       coordinates (numeric matrix [nCoordinates x 2]): The
%           latitude-longitude combination closest to each of the input
%           coordinates. First column is latitude, second column is
%           longitude.
%       latIndices (vector, linear indices [nCoordinates]): The index of
%           the latitude value in the closest point for each coordinate.
%           These indices are relative to the "lats" input.
%       lonIndices (vector, linear indices [nCoordinates]): The index of
%           the longitude value in the closest point for each coordinate.
%           These indices are relative to the "lons" input.
%
% <a href="matlab:dash.doc('dash.closest.latlon')">Documentation Page</a>

% Header
header = "DASH:closest:latlon";

% Error check
dash.assert.matrixTypeSize(coordinates, 'numeric', [NaN 2], 'coordinates', header);
dash.assert.vectorTypeN(lats, 'numeric', [], 'lats', header);
dash.assert.vectorTypeN(lons, 'numeric', [], 'lons', header);

% Don't allow NaN, Inf, complex values
dash.assert.defined(coordinates, 1, 'coordinates', header);
dash.assert.defined(lats, 1, 'lats', header);
dash.assert.defined(lons, 1, 'lons', header);

% Get all latitude, longitude combinations
[latGrid, lonGrid] = ndgrid(lats, lons);
latlons = [latGrid(:), lonGrid(:)];

% Locate the closest lat-lon combination to each coordinate. Optionally
% return the lat and lon indices
[coordinates, closest] = dash.closest.site(coordinates, latlons);
if nargout>1
    siz = [numel(lats), numel(lons)];
    [latIndices, lonIndices] = ind2sub(siz, closest);
end

end