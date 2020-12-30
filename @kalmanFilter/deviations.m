function[kf] = deviations(kf, tf)
%% Specify whether to return the posterior deviations after running a Kalman
% Filter. By default, a Kalman Filter does not return deviations.
%
% kf = kf.deviations(tf)
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
dash.assertScalarType(tf, 'tf', 'logical', 'logical');
kf.return_devs = tf;

end