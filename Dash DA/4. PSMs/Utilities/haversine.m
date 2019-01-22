function[D] = haversine( lli, llf )
%% Calculate the surface distance between lat-lon coordinates (in kilometers).
%
% D = haversine( lli, llf )
% Computes the distance between sets of lat, lon coordinates.
%
% ----- Inputs -----
% 
% lli: Initial lat lon coordinates. Lat is first column, lon is second.
%
% llf: Final lat-lon coordinates. Lat is first column, lon is second.
%
% ----- Outputs -----
%
% D: The distance between initial and final coordinates in kilometers.

% Set the radius of the Earth (in kilometers)
R = 6371;

% Convert latitude to radians
lli = lli * pi/180;
llf = llf * pi/180;

% Get the change in latitude
dLat = llf(:,1) - lli(:,1);

% Get the change in longitude
dLon = llf(:,2) - lli(:,2);

% Get the haversine function of the central angle
a = sin(dLat/2).^2 + ( cos(lli(:,1)) .* cos(llf(:,1)) .* sin(dLon/2).^2 );

% Get the distance
D = R * 2 * atan2( sqrt(a), sqrt(1-a) );

end