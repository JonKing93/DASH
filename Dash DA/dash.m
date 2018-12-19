function[A, Ye] = dash( M, D, R, w, inflate, daType, F, H, Fobs)
%% Implements data assimilation using dynamic PSMs or the tardif method.
%
% [A, Ye] = dash( M, D, R, w, inflate, 'full', H, F)
% Runs the DA using a dynamic PSM. Returns analysis ensemble mean and
% variance, and the dynamically calculated Ye values.
% 
% [A, {Yi, Ymv, Yf}]  = dash( M, D, R, w, inflate, 'append', Ha, Fa, Fobs)
% Runs the DA using the appended Ye method.
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. (nObs x nTime) OR [] for dynamic generation.
%      NaN elements will be dynamically generated.
%
% w: Covariance localization weights. Leave empty for no localization.
%
% inflate: A scalar inflation factor. Leave empty for no inflation.
%
% F: An array of proxy system models for each observation. (nObs x 1)
%
% Fa: An array of proxy system models for ??? How best to implement...
%
% H: A cell of state variable indices needed to run the forward model for
%      each site. {nObs x 1}(nSite x 1)
%
% Ha: State variable indices needed to run the forward model for each site.
%      A cell array (for serial Ye calculation) {nObs x 1}(nSite x 1)
%      OR a matrix (for bulk Ye calculation) (nObs x nSite)
%
% ----- Outputs -----
%
% A: Output Analysis mean and variance. (nState x nTime x 2)
%
% Ye: Dynamically generated model estimates for sequential updates. (nObs x nEns x nTime)
%
% Yi: The initial Ye values calculated for the appended method. (nObs x nEns x nTime)
%
% Ymv: The mean and variance of Ye values used for each serial update in
%      the appended method. The first element of dim3 is the mean, and the
%      second element is the variance. (nObs x nTime x 2)
%
% Yf: The final Ye values at the end of the appended method. (nObs x nEns x nTime)

% Error checking
% errorCheck(); 

% Get some sizes
[nState, nEns] = size(M);
nObs = size(D,1);

% Get the default weights for covariance localization
if isempty(w)
    w = ones(nState, nObs);
end

% Get default weights for inflation
if isempty(inflate)
    inflate = 1;
end

% Set the toggle for the appended method vs dynamic PSM
if strcmpi(daType, 'append')
    append = true;
elseif strcmpi( daType, 'full')
    append = false;
else
    error('Unrecognized daType');
end

% Apply the inflation factor
[Mmean, Mdev] = decomposeEnsemble( M );
Mdev = sqrt(inflate) .* Mdev;
M = Mmean + Mdev;

% If doing the appended method.
if append
    
    % Check that Fa is an appendPSM
    if ~isa(F, 'appendPSM')
        error('Fa must be of the class "appendPSM"');
    end
    
    % Preallocate the Y estimates
    Yi = NaN( nObs, nEns );
    
    % For each type of forward model...
    for m = 1:numel(F)
        
        % Get the associated observations
        currObs = Fobs{m};
        
        % Generate the associated Y estimates
        Yi(currObs,:) = F.calculateYe( M, H(currObs), currObs );
    end
    
    % Use the trivial PSM for the DA. Just going to return the Ye values in
    % the appended state as the PSM output.
    F = repmat( trivialPSM, nObs, 1);
    
    % Determine the sampling indices for the appended Ye
    H = nState + (1:nObs)';
    H = num2cell(H);
    
    % Append Ye to M
    M = [M;Yi];
end

% Now, run the DA
[A, Ye] = dashDA( M, D, R, w, F, H );

% If using the appended method...
if append
    
    % Unappend the Ymeans    
    Yf = A(nState+1:end,:,1);
    A = A(1:nState,:,:);
    
    % Create the output cell
    Ye = {Yi, Ye, Yf};
end

end