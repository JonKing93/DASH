function[output] = ensrf( obj )
% Runs an ensemble square root Kalman filter
%
% output = obj.ensrf
%
% ---- Outputs -----
%
% output: A structure that may contain the following fields
%
%   settings - The settings used to run the filter
%
%   Amean - The updated ensemble mean (nState x nTime)
%
%   Avar - Updated ensemble variance (nState x nTime)
%
%   Ye - Proxy estimates
%           Joint Updates:  (nObs x nEns)
%           Serial Updates: (nObs x nEns x nTime)
%
%   Yi - Initial proxy estimates when using the appended Ye method. (nObs x nEns)
%
%   calibRatio - The calibration ratio. (nObs x nTime)
%
%   R - The observation uncertainty used to run the filter. Includes
%       dynamically generated R values. (nObs x nTime).
%
%   sites - A logical array indicating which sites were used to update each
%           time step. (nObs x nTime)

% Get settings. Load the ensemble if necessary
set = obj.settings.ensrf;
M = obj.M;
if isa(M,'ensemble')
    M = M.load;
end

% Inflate ensemble
M = dash.inflate( M, set.inflate );

% Serial updates
if strcmp(type, 'serial')
    
    % Optionally append Ye
    F = obj.F;
    if set.append
        [M, F, Yi] = dash.appendYe( M, F );
    end
    
    % Do the updates
    output = dash.serialENSRF( M, obj.D, obj.R, F, set.localize );
    
    % Unappend if necessary
    output.Append = false;
    if set.append
        dash.unappendYe;
        output.Yi = Yi;
        output.Append = true;
    end
    
% Joint updates
else
    output = dash.jointENSRF( M, obj.D, obj.R, obj.F, set.localize{1}, set.localize{2}, set.meanOnly );
end

end