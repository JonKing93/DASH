function[Adev] = updateDeviations( Mdev, Ka, Ydev )
% Updates ensemble deviations.
%
% (Note that time steps with the same covariance, observations, and R
% values will have the same ensemble deviations. So this function can be
% used to return the ensemble deviations for multiple time steps.)
%
% Adev = updateDeviations(Mdev, Ka, Ydev)
%
% ----- Inputs -----
%
% Mdev: Ensemble deviations. (nState x nEns)
%
% Ka: The adjusted Kalman Gain. (nState x nSite)
%
% Ydev: Y estimate deviations. (nSite x nEns)
%
% ----- Outputs -----
%
% Adev: Updated ensemble deviations (nState x nEns)

Adev = Mdev - Ka * Ydev;

end