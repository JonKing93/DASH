function[] = setValues( obj, M, Fj, S )
% Specify a model prior, forward model for J metric, and sensor sites to
% use in an optimal sensor test. Error checks everything
%
% obj.setValues( M, Fj, S )
%
% **Note: Use an empty array to keep the current value of a variable in the
% sensorTest object.
%
% ----- Inputs -----
%
% M: A model prior. Either an ensemble object or a matrix (nState x nEns)
%
% Fj: A scalar PSM used to generate the J metric.
%
% S: A sensorSites object.

% Get any saved variables
if ~exist('M','var') || isempty(M)
    M = obj.M;
end
if ~exist('Fj','var') || isempty(Fj)
    Fj = obj.Fj;
end
if ~exist('S','var') || isempty(S)
    S = obj.S;
end

% Check M
if ~ismatrix(M) || ~isreal(M) || ~isnumeric(M) || any(isinf(M(:))) || any(isnan(M(:)))
    error('M must be a matrix of real, numeric, finite values and may not contain NaN.');
end
[nState] = size(M,1);

% Check Fj
if ~isa(Fj, 'PSM') || ~isscalar( Fj )
    error('Fj must be a scalar PSM object.');l
end
Fj.review( nState );

% Check the H values in the sites
if any(S.H > nState)
    badH = find( S.H > nState, 1 );
    error('The state vector index of site %.f (%.f) exceeds the number of state vector elements (%.f)', badH, sites.H(badH), nState );
end

% Save the values
obj.M = M;
obj.Fj = Fj;
obj.S = S;

end