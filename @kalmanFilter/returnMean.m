function[kf] = returnMean(kf, tf)
%% Specify whether to return the posterior mean after running a Kalman
% Filter. By default, a Kalman Filter returns the mean.
%
% kf = kf.returnMean(tf)
%
% ----- Inputs -----
%
% tf: Scalar logical that indicates whether to return the 
%    mean (true -- default), or not (false)
%
% ----- Output -----
%
% kf: The updated kalmanFilter object

% Error check and save
kf.return_mean = dash.assertScalarType(tf, 'tf', 'logical','logical');

end