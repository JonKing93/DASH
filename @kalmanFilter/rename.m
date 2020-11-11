function[kf] = rename(kf, name)
%% Renames a Kalman filter object
%
% kf = kf.rename( name )
%
% ----- Inputs -----
%
% name: The new name. A string.
%
% ----- Outputs -----
%
% kf: The updated kalmanFilter object

kf.name = dash.assertStrFlag(name, 'name');

end