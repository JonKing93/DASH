function[] = setValues( obj, M, D, R, F )
% Changes values of model prior, observations, observation uncertainty, PSMs, and
% sensor sites to use for a kalman filter.
%
% obj.setValues( M, D, R, F )
%
% ***Note: Use an empty array to keep the current value of a variable in
% the kalman filter object. For example:
%
%    >> obj.setValues( [], D, R )
%    would set new values for D and R, but use existing values for M and F
%
% ----- Inputs -----
%
% M: A model prior. Either an ensemble object or a matrix (nState x nEns)
%
% D: A matrix of observations (nObs x nTime)
%
% R: Observation uncertainty. NaN entries in time steps with observations
%    will be calculated dynamically via the PSMs.
%
%    scalar: (1 x 1) The same value will be used for all proxies in all time steps
%    row vector: (1 x nTime) The same value will be used for all proxies in each time step
%    column vector: (nObs x 1) The same value will be used for each proxy in all time steps.
%    matrix: (nObs x nTime) Each value will be used for one proxy in one time step.
%
% F: A cell vector of PSM objects. {nObs x 1}

% Get saved/default values
Rtype = 'new';
if ~exist('M','var') || isempty(M)
    M = obj.M;
end
if ~exist('D','var') || isempty(D)
    D = obj.D;
end
if ~exist('R','var') || isempty(R)
    R = obj.R;
    Rtype = obj.Rtype;
end
if ~exist('F','var') || isempty(F)
    F = obj.F;
end

% Error check, process as generic filter
[M, D, R, F, Rtype] = obj.checkValues( M, D, R, F, Rtype );

% Get some sizes
if isa(M, 'ensemble')
    meta = M.loadMetadata;
    nState = meta.ensSize(1);
else
    nState = size(M,1);
end
nObs = size(D,1);

% Check that localization still works
if ~isempty( obj.localize )
    if strcmpi(obj.type, 'serial')
        w = obj.localize;
    else
        w = obj.localize{1};
    end
    if ~isequal( size(w), [nState,nObs] )
        error('The previous w localization weights are (%.f x %.f), which would no longer be the correct size (%.f x %.f). You can reset them with the command:\n\t>> obj.settings(''localize'', [])', size(w,1), size(w,2), nState, nObs );
    end
    % Note that we don't need to reset yloc, because w already scales to nObs
end

% Check that reconstruction indices are still allowed
if ~isempty( obj.reconstruct )
    if length(obj.reconstruct)~=nState
        error('The size of the prior would change, so the previously specified reconstruction indices would not be valid. You can reset them with the command:\n\t>> obj.settings(''reconstruct'', [])%s','');
    end
    
    % Check against PSM H indices if doing serial updates
    if strcmpi(type, 'serial')
        psmIndices = cell(nObs,1);
        for d = 1:nObs
            psmIndices{d} = F{d}.H;
        end
        psmIndices = cell2mat(psmIndices);
        if any( ~ismember(psmIndices, find(obj.reconstruct) ))
            error('The previously specified reconstruction indices would no longer include the PSM state indices (H). Consider switching to joint updates, or resetting the reconstruction indices with the command:\n\t>> obj.settings(''reconstruct'', [])%s','');
        end
    end
end

% Everything is good, set the values
obj.M = M;
obj.D = D;
obj.R = R;
obj.F = F;
obj.Rtype = Rtype;

end