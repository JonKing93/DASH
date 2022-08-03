function[Xdev] = updateDeviations(Xdev, Ka, Ydev)
%% dash.kalman.updateDeviations  Updates the ensemble deviations
% ----------
%   Adev = dash.kalman.updateDeviations(Xdev, Ka, Ydev)
%   Updates the ensemble deviations using the adjusted Kalman gain.
% ----------
%   Inputs:
%       Xdev (numeric matrix [nState x nMembers]): The prior ensemble deviations
%       Ka (numeric matrix [nState x nSite]): The adjusted Kalman gain
%       Ydev (numeric matrix [nSite x nMembers]): The ensemble deviations
%           of the observation estimates
%
%   Outputs:
%       Adev (numeric matrix [nState x nMembers]): The updated ensemble
%           deviations
%   
% <a href="matlab:dash.doc('dash.kalman.updateDeviations')">Documentation Page</a>

Xdev = Xdev - Ka * Ydev;

end