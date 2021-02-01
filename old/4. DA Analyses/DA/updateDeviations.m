function[Adev] = updateDeviations( Mdev, Ka, Ydev )
% Updates ensemble deviations in a single time step.
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