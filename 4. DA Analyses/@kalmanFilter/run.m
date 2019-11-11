function[output] = run( obj )
% Runs an ensemble square root Kalman filter for a specific object
%
% output = obj.run
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
%   Adev - Updated ensemble deviations (nState x nEns x nTime)
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
M = obj.M;
if isa(M,'ensemble')
    M = M.load;
end

% Inflate ensemble
M = dash.inflate( M, obj.inflate );

% Sizes
nState = size(M,1);
nObs = size(D,1);

% Serial updates
if strcmp(obj.type, 'serial')
    
    % Default localization
    w = obj.localize;
    if isempty(w)
        w = ones( nState, nObs );
    end 
    
    % Optionally append Ye
    F = obj.F;
    if obj.append
        [M, F, Yi] = obj.appendYe( M, F );
    end
    
    % Do the updates
    output = obj.serialENSRF( M, obj.D, obj.R, F, w, obj.fullDevs );
    
    % Unappend if necessary
    output.Append = false;
    if obj.append
        obj.unappendYe;
        output.Yi = Yi;
        output.Append = true;
    end
    
% Joint updates
else
    
    % Default localization
    if isempty(obj.localize)
        w = ones( nState, nObs);
        yloc = ones( nObs, nObs);
    else
        w = obj.localize{1};
        yloc = obj.localize{2};
    end
    
    % Do the updates
    output = dash.jointENSRF( M, obj.D, obj.R, obj.F, w, yloc, obj.meanOnly, obj.fullDevs );
end

end