function[coordinates, siteIndices] = site(coordinates, siteCoordinates)
%% dash.closest.site  Returns the coordinates of sites closest to a set of coordinates
% ----------
%   coordinates = dash.closest.site(coordinates, siteCoordinates)
%   Searches through latitude-longitude points to find the points that are
%   closest to a set of latitude-longitude coordinates. The first input is
%   the set of coordinates for which to find the closest points. The second
%   input lists the set of available latitude-longitude coordinates. This
%   method is often used to locate the elements of a non-spatially gridded
%   dataset that are closest to a specific set of coordinates.
%
%   This function uses a haversine function to calculate the distance
%   between sites. Since the haversine function is agnostic to longitude
%   coordinate systems, you may use longitudes on -180:180, 0:360, or even a
%   mix of both coordinate systems.
%   
%   [coordinates, siteIndices] = dash.closest.site(...)
%   Also returns the index of the closest site within the set of examined
%   points. These indices can be used to index into the closest element
% ----------
%   Inputs:
%       coordinates (numeric matrix [nCoordinates x 2]): A set of
%           latitude-longitude coordinates in decimal degrees. The method
%           will search for site coordinates that are closest to these
%           points. A numeric matrix with two columns. The first column
%           holds the latitude points, and the second column is longitude.
%       siteCoordinates (numeric matrix): A second set of 
%           latitude-longitude coordinates in decimal degrees. The method
%           will determine which of these site coordinates is closest to
%           each of the coordinate in the first input.
%
%   Outputs:
%       coordinates (numeric matrix [nCoordinates x 2]): The site
%           coordinate closest to each of the input coordinates. First
%           column is latitude, second column is longitude.
%       siteIndices (vector, linear indices [nCoordinates]): The index of
%           the site coordinate closest to each coordinate. These indices
%           are relative to the rows of the "siteCoordinates" input.
%
% <a href="matlab:dash.doc('dash.closest.site')">Documentation Page</a>

% Error check
header = "DASH:closest:site";
dash.assert.matrixTypeSize(coordinates, 'numeric', [NaN 2], 'coordinates', header);
dash.assert.matrixTypeSize(siteCoordinates, 'numeric', [NaN 2], 'siteCoordinates', header);
dash.assert.defined(coordinates, 1, 'coordinates', header);
dash.assert.defined(siteCoordinates, 1, 'siteCoordinates', header);

% Use haversine to locate the closest point
distances = dash.haversine(coordinates, siteCoordinates);
[~, closest] = min(distances, [], 2);
coordinates = siteCoordinates(closest, :);
siteIndices = closest;

end