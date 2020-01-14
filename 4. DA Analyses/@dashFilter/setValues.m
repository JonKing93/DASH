function[M, D, R, F, Rtype] = setValues( obj, M, D, R, F )
% Sets the model prior, observations, observation uncertainty, and PSMs to
% use with a data assimilation filter.
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

% Check M 
if isa(M,'ensemble') 
    if ~isscalar(M)
        error('When M is an ensemble object, it must be scalar.');
    end
    v = M.metadata.varCheck( M.loadVars );
    if any( M.hasnan( v, M.loadMembers ), 'all' )
        error('Cannot load NaN values for data assimilation. Please see ensemble.useMembers to only load ensemble members without NaN elements.');
    end
    meta = M.loadMetadata;
    nState = meta.ensSize(1);
else
    if ~ismatrix(M) || ~isreal(M) || ~isnumeric(M) || any(isinf(M(:))) || any(isnan(M(:)))
        error('M must be a matrix of real, numeric, finite values and may not contain NaN.');
    end
    nState = size(M,1);
end

% Check the observations
if ~ismatrix(D) || ~isreal(D) || ~isnumeric(D) || any(isinf(D(:)))
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

if ~isnumeric(R) || ~isreal(R) || any(R(:)<0) || ~ismatrix(R)
    error('R must be a set of real, numeric, positive values and cannot have more than 2 dimensions.');
elseif isrow(R)
    if length(R)~=nTime
        error('The number of elements in R (%.f) does not match the number of time steps (%.f).', length(R), nTime );
    end
elseif iscolumn(R) 
    if length(R)~=nObs
        error('The number of elements in R (%.f) does not match the number of observation sites.', length(R), nObs );
    end
elseif ismatrix(R) && ~isequal( size(R), [nObs, nTime])
    error('R must be a (%.f x %.f) matrix.', nObs, nTime );
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
        F{d}.review( nState );
    catch ME
        error( [sprintf('PSM %.f failed with the following error message:\n',d), ME.message] );
    end
end

% Have the filter do any internal error checking
obj.checkValues( M, D, R, F, Rtype );

% Set the values
obj.M = M;
obj.D = D;
obj.R = R;
obj.F = F;
obj.Rtype = Rtype;

end