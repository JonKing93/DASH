function[M, F, Yi] = appendSetup( M, F )
%% Updates a model prior and PSM array for use with the appended DA method.
%
% [Ma, Fa, Yi] = appendSetup( M, F );
% Calculates Ye values, appends them to the end of a prior. Converts PSMs
% to trivial "appendPSMs" that sample the appropriate appended value
%
% ----- Inputs -----
%
% M: A prior model ensemble. (nState x nEns)
%
% F: A cell vector of PSMs {nObs x 1}
%
% Yi: The initial, appended Ye values. (nObs x 1)
%
% ----- Outputs -----
%
% Ma: The appended model. (nState + nObs x nEns)
%
% F: A set of "appendPSMs". {nObs x 1}
%
% Yi: The initial Ye values. (nObs x nEns)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check
errCheck(M,F);

% Get sizes
nObs = numel(F);
[nState, nEns] = size(M);

% Preallocate the Ye values on the ensemble
M = [M; NaN(nObs, nEns)];

% For each observation
for d = 1:nObs
    
    % Generate the initial Ye estimates
    M( nState+d, : ) = F{d}.runPSM( M(F{d}.H, :), NaN, d );
    
    % Replace the PSM with the trivial appendPSM and set the sampling
    % indices.
    F{d} = appendPSM;
    F{d}.getStateIndices( nState + d );
end

% Get the initial Ye values
Yi = M( nState+(1:nObs), : );

end

function[] = errCheck(M,F)

% Check that M is a matrix of real, numeric value without NaN or Inf
if ~ismatrix(M) || ~isreal(M) || ~isnumeric(M) || any(isinf(M(:))) || any(isnan(M(:)))
    error('M must be a matrix of real, numeric, finite values and may not contain NaN.');
end

% Check that the forward models are ready
if ~isvector(F)
    error('F must be a vector of PSM objects.');
end
for k = 1:numel
    
    % Check that each element is a PSM
    if ~isa( F{k}, 'PSM' )
        error('Element %.f of F is not a PSM', k);
    end
    
    % Have the PSM do an internal error check
    F{k}.reviewPSM;
end

end