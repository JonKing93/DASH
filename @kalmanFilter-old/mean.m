function[kf] = mean(kf, tf)
%% Specify whether to return the posterior mean after running a Kalman
% Filter. By default, a Kalman Filter returns the mean.
%
% kf = kf.mean(tf)
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
dash.assert.scalarType(tf, 'tf', 'logical','logical');
kf.return_mean = tf;

end