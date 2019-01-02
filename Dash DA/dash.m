function[A, Ye] = dash( M, D, R, w, inflate, daType, H, F)
%% Implements data assimilation using dynamic PSMs or the tardif method.
%
% [A, Ye] = dash( M, D, R, w, inflate, 'full', H, F)
% Runs the DA using dynamic PSMs. Returns analysis ensemble mean and
% variance, and the dynamically calculated Ye values.
% 
% [A, {Yi, Ymv, Yf}]  = dash( M, D, R, w, inflate, 'append', Ha, Fa )
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
% H: A cell of state variable indices needed to run the forward model for
%      each site. {nObs x 1}(nVars x 1)
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

%% Setup 

% Error checking
% errorCheck(); 

% Get some sizes
[nState, nEns] = size(M);
nObs = size(D,1);

% Set the toggle for the appended method vs dynamic PSM
if strcmpi(daType, 'append')
    append = true;
elseif strcmpi( daType, 'full')
    append = false;
else
    error('Unrecognized daType');
end


%% Covariance adjustments. Inflation.

% If unspecified, do no covariance localization.
if isempty(w)
    w = ones(nState, nObs);
end

% If unspecified, do no covariance inflation.
if isempty(inflate)
    inflate = 1;
end

% Apply the inflation factor
[Mmean, Mdev] = decomposeEnsemble( M );
Mdev = sqrt(inflate) .* Mdev;
M = Mmean + Mdev;


%% Appended method
%
% Decided to remove the requirement of supporting bulk calculations.
% Instead, going to just generate the Ye serially, as you would with the
% normal DA.
%
% If this is a problem, we can implement the appendPSM class later.

% If doing the appended method.
if append
    
    % Check that F is a PSM
    if ~isa(F, 'PSM')
        error('Fa must be of the class "PSM"');
    end
    
    % Preallocate the Y estimates
    Yi = NaN( nObs, nEns );
    
    % For each observation
    for d = 1:nObs        
        % Generate the associated Y estimates
        Yi(d,:) = F(d).runPSM( M(H{d},:), d, H{d} );
    end
    
    % Use the trivial PSM for the DA. Just going to return the Ye values in
    % the appended state as the PSM output.
    F = repmat( trivialPSM, nObs, 1);
    
    % Determine the sampling indices for the appended Ye
    H = nState + (1:nObs)';
    H = num2cell(H);
    
    % Append Ye to M
    M = [M;Yi];
    
    % Run the DA
    [A, Ye] = dashDA( M, D, R, w, F, H );
    
    % Unappend
    Yf = A(nState+1:end,:,:);
    A = A(1:nState,:,:);
    
    % Get the Y output cell
    Ye = {Yi, Ye, Yf};

    
%% Full DA
% Super simple, just run DA directly.
else
    [A, Ye] = dashDA( M, D, R, w, F, H );
end

end