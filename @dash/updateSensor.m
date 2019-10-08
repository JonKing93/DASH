function[Mdev] = updateSensor( Mdev, H, R)
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

% Get the sensed deviations -- analogous to Ye
Msite = Mdev(H,:);

% Get the gain and adjusted gain scaling factor
[K, a] = dash.serialKalman( Mdev, Msite, ones(size(Mdev,1),1), R );

% Update the deviations
Mdev = Mdev - a * K * Msite;

end