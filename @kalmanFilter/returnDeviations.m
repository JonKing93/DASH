function[kf] = returnDeviations(kf, tf)
%% Specify whether to return the posterior deviations after running a Kalman
% Filter. By default, a Kalman Filter does not return deviations.
%
% kf = kf.returnDeviations(tf)
%
% ----- Inputs -----
%
% tf: Scalar logical that indicates whether to return the 
%    deviations (true -- default), or not (false)
%
% ----- Output -----
%
% kf: The updated kalmanFilter object

% Error check and save
kf.return_devs = dash.assertScalarType(tf, 'tf', 'logical', 'logical');

end