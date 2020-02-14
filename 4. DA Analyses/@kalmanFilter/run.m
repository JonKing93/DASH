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
%   Aperc - Percentiles of the updated ensemble (nState x nPercentile x nTime)
%           (See output.settings for the percentiles calculated) 
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

% Load the ensemble if necessary
M = obj.M;
if isa(M,'ensemble')
    M = M.load;
end

% Default reconstruction indices
if isempty( obj.reconstruct )
    reconstruct = true( size(M,1), 1 );
else
    reconstruct = obj.reconstruct;
end

% Inflate ensemble
M = dash.inflate( M, obj.inflate );

% Sizes
nState = size(M,1);
nObs = size(obj.D,1);

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
        [M, F, Yi, reconstruct] = obj.appendYe( M, F, reconstruct );
    end
    
    % Reduce prior to reconstructed variables. Adjust H indices
    M = M( reconstruct, : );
    F = obj.adjustH( F, reconstruct );
    
    % Do the updates
    output = obj.serialENSRF( M, obj.D, obj.R, F, w, obj.fullDevs, obj.percentiles );
    
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
        w = ones( sum(reconstruct), nObs);
        yloc = ones( nObs, nObs);
    else
        w = obj.localize{1};
        yloc = obj.localize{2};
    end
        
    % Do the updates
    output = obj.jointENSRF( M, obj.D, obj.R, obj.F, w, yloc, obj.meanOnly, obj.fullDevs, obj.percentiles, reconstruct );
end

end