function[] = setValues( obj, M, D, R, F)
% Specify a model prior, observations, observation uncertainty, PSMs, and
% sensor sites to use for data assimilation. Error checks everything.
%
% obj.setValues( M, D, R, F )
%
% ***Note: Use an empty array to keep the current value of a variable in
% the dash object. For example:
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

% Get any saved variables
Rtype = 'new';
if ~exist(M,'var') || isempty(M)
    M = obj.M;
end
if ~exist(D,'var') || isempty(D)
    D = obj.D;
end
if ~exist(R,'var') || isempty(R)
    R = obj.R;
    Rtype = obj.Rtype;
end
if ~exist(F,'var') || isempty(F)
    F = obj.F;
end

% Check M and D and get sizes
if isa(M,'ensemble') && ~isscalar(M)
    error('When M is an ensemble object, it must be scalar.');
elseif isa(M, 'ensemble') && any( ismember( M.loadMembers, find(M.hasnan) ) )
    error('Cannot load NaN values for data assimilation. Please use ensemble.load to only load ensemble members without NaN elements.');
elseif ~ismatrix(M) || ~isreal(M) || ~isnumeric(M) || any(isinf(M(:))) || any(isnan(M(:)))
    error('M must be a matrix of real, numeric, finite values and may not contain NaN.');
elseif ~ismatrix(D) || ~isreal(D) || ~isnumeric(D) || any(isinf(D(:)))
    error('D must be a matrix of real, numeric, finite values.');
end
[nObs, nTime] = size(D);

% Get R. Error check. Replicate
if strcmp(Rtype, 'scalar')
    R = R(1);
elseif strcmp(Rtype, 'row')
    R = R(1,:);
elseif strcmp(Rtype, 'column')
    R = R(:,1);
end

if ~isnumeric(R) || ~isreal(R) || any(R(:)<0) || ~ismatrix(R)
    error('R must be a set of real, numeric, positive values and cannot have more than 2 dimensions.');
elseif isrow(R) && length(R)~=nTime
    error('The number of elements in R (%.f) does not match the number of time steps (%.f).', length(R), nTime );
elseif iscolumn(R) && length(R)~=nObs
    error('The number of elements in R (%.f) does not match the number of observation sites.', length(R), nObs );
elseif ismatrix(R) && ~isequal( size(R), [nObs, nTime])
    error('R must be a (%.f x %.f) matrix.', nObs, nTime );
end

if isscalar(R)
    R = R * ones( size(D) );
    Rtype = 'scalar';
elseif isrow(R)
    R = repmat( R, [nObs, 1] );
    Rtype = 'row';
elseif iscolumn(R)
    R = repmat( R, [1, nTime] );
    Rtype = 'column';
else
    Rtype = 'matrix';
end

% Check the PSMs. Have them do an internal review
if ~isvector(F) || ~iscell(F) || length(F)~=nObs
    error('F must be a cell vector with %.f elements.', nObs );
end
for d = 1:nObs
    if ~isa( F{d}, 'PSM' ) || ~isscalar( F{d} )
        error('Element %.f of F must be a scalar "PSM" object', d );
    end
    try
        F{d}.review;
    catch ME
        ME.message = sprintf( ['PSM %.f failed with the following error message:\n', ME.message], d );
        rethrow( ME );
    end
end

% Save the values
obj.M = M;
obj.D = D;
obj.R = R;
obj.F = F;
obj.Rtype = Rtype;
        
end