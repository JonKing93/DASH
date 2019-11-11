function[M] = updateSensor( Mmean, Mdev, H, R)
% Updates the variance field after adding a sensor
%
% Mdev = dash.updateSensor( Mdev, site, Rsite )
%
% ----- Inputs -----
%
% Mdev: Ensemble deviations
%
% H: The state element index of a site in the ensemble
%
% R: The uncertainty of a measurement at the site.

Ymean = Mmean(H);
Ydev = Mdev(H,:);
D = Mmean(H) + Mdev(H,:);

% Get the gain and adjusted gain scaling factor
[K, a] = kalmanFilter.serialKalman( Mdev, Mdev(H,:), ones(size(Mmean)), R );

% Update the ensemble
Mmean = Mmean + K * Mdev(H,:);
Mdev = Mdev - a * K * Mdev(H,:);
M = Mmean + Mdev;


end