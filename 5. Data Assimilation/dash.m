function[A, Ye] = dash( M, D, R, w, inflate, daType, F, varargin)
%% Implements data assimilation using dynamic PSMs or the tardif method.
%
% [A, Ye] = dash( M, D, R, w, inflate, 'full', F)
% Runs the DA using dynamic PSMs. Returns analysis ensemble mean and
% variance, and the PSM-calculated Ye values.
% 
% [A, Yi, Yu, Yf]  = dash( M, D, R, w, inflate, 'append', Fa )
% Runs the DA using the appended Ye method. Returns ensemble analysis mean
% and variance. Also returns the initial Ye (calculated using the PSMs),
% the linearly updated Ye used in each serial update, and the final value
% Ye for each time step. 
% 
% [...] = dash(..., 'maxUpdate', Kmax)
% Sets a maximum update size to monitor for ensemble convergence.
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. (nObs x nTime).
%
% w: Covariance localization weights. Use [] for no localization.
%
% inflate: A scalar inflation factor. Use [] for no inflation.
%
% F: A cell vector of PSM objects for each observation. {nObs x 1}
%
% Kmax: A scalar value used to test for ensemble convergence. An
% unreareasonably large update for the variable with the largest units.
%
% ----- Outputs -----
%
% A: Update analysis mean and variance. (nState x nTime x 2). The first
%       element of dim3 is mean, the second element is variance.
%
% Ye: Dynamically generated model estimates for sequential updates. (nObs x nEns x nTime)
%
% Yi: The initial Ye values for the appended method calculated using PSMs. (nObs x nEns)
%
% Yu: The linearly updated Ye value used in each serial update of the 
%      appended method. (nObs x nEns x nTime)
%
% Yf: The final Ye values at each time step for the appended method. (nObs x nEns x nTime)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

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


%% Covariance adjustments. Inflation. Convergence monitor

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

% Convergence monitor
Kmax = parseInputs( varargin, 'maxUpdate', {Inf}, {[]} );
if ~isscalar( Kmax) || Kmax <= 0
    error('Kmax must be a scalar larger than 0.');
end

%% Appended method
%
% Decided to remove the requirement of supporting bulk calculations.
% Instead, going to just generate the Ye serially, as you would with the
% normal DA.
%
% If this is a problem, we can implement the appendPSM class later.

% If doing the appended method.
if append
    
    % Preallocate the Y estimates
    Yi = NaN( nObs, nEns );
    
    % For each observation
    for d = 1:nObs 
        
        % Ensure that F is a PSM
        if ~isa(F{d}, 'PSM')
            error('Element %0.f of F is not of the "PSM" class', d);
        end
        
        % Generate the associated Y estimates
        Yi(d,:) = F{d}.runPSM( M(F{d}.H, :), d, 1 );
    end
    
    % Use the trivial PSM for the DA. Just going to return the Ye values in
    % the appended state as the PSM output.
    F = repmat( {appendPSM}, [nObs, 1]);
    
    % Determine the sampling indices for the appended Ye
    H = nState + (1:nObs)';
    H = num2cell(H);
    
    % Append Ye to M
    M = [M;Yi];
    
    % Run the DA
    [A, Ye] = dashDA( M, D, R, w, F, Kmax );
    
    % Unappend
    Yf = A(nState+1:end,:,:);
    A = A(1:nState,:,:);
    
    % Get the Y output cell
    Ye = {Yi, Ye, Yf};

    
%% Full DA
% Super simple, just run DA directly.
else
    [A, Ye] = dashDA( M, D, R, w, F, Kmax );
end

end