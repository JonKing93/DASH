function[A, Ye] = dash( M, D, R, F, varargin )
%% Implements data assimilation using dynamic PSMs or the tardif method.
%
% [A, Ye] = dash( M, D, R, F )
% Runs a data assimilation using dynamic forward models.
% 
% [A, Yi, Yu, Yf]  = dash( ..., 'append' )
% Runs the DA using the appended Ye method. Model estimates are calculated
% initially, then appended to the state vector and updated linearly via the
% Kalman Gain.
%
% [...] = dash( ... , 'inflate', inflate )
% Specifies an inflation factor. The covariance of the model ensemble will
% be multiplied by the inflation factor.
%
% [...] = dash( ..., 'localize', w )
% Specifies a covariance localization to use in data assimilation.
%
% [...] = dash( ..., 'serial' )
% Specify whether to process observations serially. Default is not serial.
% For non-linear PSMs, serial processing may result in non-deterministic
% analyses relative to the order in which observations are processed.
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. 
%     []: R computed dynamically from PSMs
%     scalar: R is used as the error variance for all observations.
%     column: Each element of R is used as the error-variance for a
%         unique observation. (nObs x 1)
%     matrix: Each column of R is used as the error-variances for a
%         particular time step. (nObs x nTime)
%
%     R values for NaN elements are computed dynamically by the PSMs.
%
% F: A cell vector of PSM objects for each observation. {nObs x 1}
%
% w: Covariance localization weights. (nState x nObs)
%
% inflate: A scalar inflation factor. 
%
% Kmax: A scalar value used to test for ensemble convergence. An
% unreareasonably large update for the variable with the largest units.
%
% ----- Outputs -----
%
% Amean: Update analysis mean. (nState x nTime).
%
% Avar: Update analysis variance (nState x nTime).
%
% Ye: PSM generated model estimates.
%       serial DA: (nObs x nEns x nTime)
%       joint DA: (nObs x nEns)
%
% {Yi, Yu, Yf}: Ye values used during an "append" data assimilation.
%       Yi: The initial Ye calculated using the PSMs. (nObs x nEns x nTime)
%       Yu: The updated Ye values used in a particular update (nObs x nEns x nTime)
%       Yf: The final Ye values resulting from Kalman Gain updates. (nObs x nEns x nTime)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

%% Setup 

% Parse inputs
[inflate, w, append, serial] = parseInputs( varargin, {'inflate','localize','append','serial'}, ...
                                            {1, [], false, false}, {[],[],'b','b'} );
                                        
% Error check. Get R and w if unspecified.
[R, w] = setup( M, D, R, F, inflate, w, append, serial );

% Apply the inflation factor
[Mmean, Mdev] = decomposeEnsemble( M );
Mdev = sqrt(inflate) .* Mdev;
M = Mmean + Mdev;

% If doing the appended method.
if append
    
    % Get sizes
    [nState, nEns] = size(M);
    [nObs] = size(D,1);
    
    % Preallocate the Y estimates
    Yi = NaN( nObs, nEns );
    
    % For each observation
    for d = 1:nObs
        
        % Generate the initial Yi
        Yi(d,:) = F{d}.runPSM( M(F{d}.H, :), d );
        
        % Replace the PSM with the trivial appendPSM
        F{d} = appendPSM;
        F{d}.getStateIndices(nState+d);
    end
    
    % Append Ye to M
    M = [M;Yi];
end

% Run the DA in serial or all-at-once
if serial
    [A, Ye] = serialDA( M, D, R, F, w );
else
    [A, Ye] =  jointDA( M, D, R, F, w );
end

% If using the appended method.
if append
    
    % Unappend
    Yf = A(nState+1:end,:,:);
    A = A(1:nState,:,:);
    
    % Get the Y output cell
    Ye = {Yi, Ye, Yf};
end

end

function[R, w] = setup( M, D, R, F, inflate, w, append, serial )
    
% Get the number of state elements
nState = size(M,1);
[nObs, nTime] = size(D,1);
    
% Check that observations are a matrix of real, numeric values
if ~ismatrix(D) || ~isreal(D) || ~isnumeric(D) || any(isinf(D(:)))
    error('D must be a matrix of real, numeric, finite values.');
end

% Convert R to a nObs x nTime matrix
if isempty(R)
    R = NaN(nObs, nTime);
elseif isscalar(R)
    R = repmat(R, [nObs, nTime]);
elseif iscolumn(R)
    R = repmat( R, nTime );
end

% Check R is real, numeric, finite, and non-negative
if ~ismatrix(R) || ~isreal(R) || ~isnumeric(R) || any(isinf(R(:)))
    error('R must be a matrix of real, numeric, finite values.');
elseif any( R(:) < 0 )
    error('R cannot contain negative values.');
elseif (size(R,1)~=size(D,1) || size(R,2)~=size(D,2))
    error('The number of rows and columns in R do not match the number in D.');
end

% Check F
if ~isvector( F )
    error('F must be a vector of PSM objects.');
elseif numel(F) ~= size(D,1)
    error('The number of PSMs does not match the number of observations.');
end
for k = 1:nObs
    
    % Check that each element is a PSM
    if ~isa( F{k}, 'PSM' )
        error('Element %.f of F is not a PSM', k);
    end
    
    % Have the PSM do an internal error check
    F{k}.reviewPSM;
end

% Inflation factor
if ~isscalar(inflate) || inflate<=0 || isinf(inflate) || isnan(inflate) || ~isnumeric(inflate)
    error('The inflation factor must be a scalar greater than 0. It must be real, numeric, finite and not NaN.');
end

% Covariance localization
if isempty(w)
    w = ones(nState, nObs);
elseif ~ismatrix(w) || ~isnumeric(w) || ~isreal(w)
    error('w must be a real, numeric matrix.');
elseif size(w,1) ~= nState
    error('The number of rows in w does not match the number of state elements (i.e. rows of M).');
elseif size(w,2)~=size(D,1)
    error('The number of columns in w must match the number of rows in D.');
end

% Append and serial
if ~isscalar(append) || ~islogical(append)
    error('append must be a scalar logical.');
elseif ~isscalar(serial) || ~islogical(serial)
    error('serial must be a scalar logical.');
end

end