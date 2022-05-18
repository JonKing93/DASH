function[distances] = haversine(coordinates1, coordinates2)
%% dash.haversine  Returns the distances between latitude-longitude coordinates
% ----------
%   distances = dash.haversine(coordinates)
%   Computes the distance between each latitude-longitude coordinate listed
%   in a matrix. Note that the haversine function is agnostic to longitude
%   coordinate systems. Thus, you may use longitudes on -180:180, or 0:360,
%   or even a mix of both coordinate systems.
%
%   distances = dash.haversine(coordinates1, coordinates2)
%   Computes the distance between each coordinate in the first matrix and
%   all the coordinates in the second matrix.
% ----------
%   Inputs:
%       coordinates (numeric matrix [nCoordinates x 2]): A set of
%           latitude-longitude coordinates in decimal degrees. A numeric
%           matrix with two columns. The first column is the latitude
%           coordinates, and the second column is the longitude coordinates.
%
%   Outputs:
%       distances (numeric matrix): The distance between each pair of
%           considered coordinates. If you input a single coordinate
%           matrix, then distances is a symmetric matrix with one row and
%           one column per latitude-longitude coordinate in the input. If
%           you input two coordinate matrices, then distances will have one
%           row per coordinate in the first input, and one column per
%           coordinate in the second input.

%%% Parameter
R = 6378.137;    % Radius of the Earth
%%%

% Default for the second set of coordinates
if ~exist('coordinates2','var')
    coordinates2 = coordinates1;
end

% Convert to radians
coordinates1 = coordinates1 * pi/180;
coordinates2 = coordinates2 * pi/180;

% Transpose coordinates for singleton expansion
coordinates2 = coordinates2';

% Get the change in lat and lon
dLat = coordinates1(:,1) - coordinates2(1,:);
dLon = coordinates1(:,2) - coordinates2(2,:);

% Get haversine function of the central angle
a = sin(dLat/2).^2 + ( cos(coordinates1(:,1)) .* cos(coordinates2(1,:)) .* sin(dLon/2).^2);
c = 2 * atan2( sqrt(a), sqrt(1-a) );

% Get the distance
distances = R * c;

end