function[M, F, Yi, reconstruct] = appendYe( M, F, reconstruct )
%% Precalculates Ye and appends them to the end of the prior.
%
% [Ma, Fa, Yi] = dash.appendYe( M, F );
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
% reconstruct: Logical vector indicating which state vector elements to
%              reconstruct. (nState x 1)
%
% ----- Outputs -----
%
% Ma: The appended model. (nState + nObs x nEns)
%
% F: A set of trivial PSMs. {nObs x 1}
%
% Yi: The initial Ye values. (nObs x nEns)
%
% reconstruct: Updated reconstruction indices (nState + nObs x nEns)

% Get sizes, preallocate
nObs = numel(F);
[nState, nEns] = size(M);
M = [M; NaN(nObs, nEns)];

% Generate Ye for each observation. Replace PSM with trivialPSM
for d = 1:nObs    
    M( nState+d, : ) = F{d}.run( M(F{d}.H, :), NaN, d );
    F{d} = trivialPSM;
    F{d}.getStateIndices( nState + d );
end

% Get the initial Ye values
Yi = M( nState+(1:nObs), : );

% Update the reconstruction indices
reconstruct = [reconstruct; true(nObs,1)];

end