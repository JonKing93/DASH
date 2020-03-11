function[F, varargout] = restrictVarsToPSMs( vars, F, ensMeta, M )
%% Limits the state indices of specified variables to only include values required to run PSMs.
%
% [F, ens] = restrictVarsToPSMs( vars, F, ens )
% Restricts what values will be loaded from the specified variables in an
% ensemble object and updates PSM H indices.
%
% [F, ensMeta] = restrictVarsToPSMs( vars, F, ensMeta )
% Updates an ensembleMetadata object and PSM H indices.
%
% [F, ensMeta, M] = restrictVarsToPSMs( vars, F, ensMeta, M )
% Also updates a loaded ensemble (M) for the specified variables.
%
% ----- Inputs -----
%
% vars: A list of variables for which state elements should be limited to
%       values required to run PSMs. A string vector, cellstring vector, or
%       character row vector.
%
% F: A cell array of PSMs. (nSite x 1)
%
% ens: An ensemble object.
%
% ensMeta: An ensembleMetadata object
%
% M: An ensemble matrix (nState x nEns)
%
% ----- Outputs -----
%
% F: PSMs for which the state indices (H) have been adjusted to match the
%    smaller, restricted ensemble. (nSite x 1)
%
% ens: An ensemble object that will only load the reduced ensemble
%      (and corresponding reduced metadata).
%
% ensMeta: Ensemble metadata for the reduced ensemble.
%
% M: The reduced ensemble.

% Parse inputs
if isa(ensMeta, 'ensemble')
    if ~isscalar(ensMeta)
        error('ens must be a scalar ensemble object.');
    else
        ens = ensMeta;
        ensMeta = ens.metadata;
    end
end

hasM = false;
if exist('M','var')
    hasM = true;
end

% Error check
if ~isscalar(ensMeta) || ~isa(ensMeta, 'ensembleMetadata')
    error('meta must be a scalar ensembleMetadata object.');
elseif ~isstrlist(vars)
    error('vars must be a string vector, cellstring vector, or character row vector.');
elseif ~isvector(F) || ~iscell(F)
    error('F must be a cell vector.');
elseif hasM && (~ismatrix(M) || ~isequal(size(M),ensMeta.ensSize))
    error('M must be a (%.f x %.f) matrix', ensMeta.ensSize(1), ensMeta.ensSize(2) );
end
v = unique( ensMeta.varCheck(vars) );
nVar = numel(v);

% Run through the PSMs, collect H indices
nPSM = numel(f);
indices = cell(nPSM, 1);
for s = 1:nPSM
    if ~isa(F{s}, 'PSM') || ~isscalar(F{s})
        error('Element %.f of F is not a scalar PSM object.', s );
    elseif isempty( F{s}.H )
        warning('PSM %.f does not have state vector indices (H)', s );
    end
    indices{s} = F{s}.H(:);
end
Hpsm = cell2mat(indices);

% Get the set of all indices and restrictable indices
indices = cell( nVar, 1 );
for var = 1:nVar
    indices{var} = obj.varIndices( obj.varName(v(var)) );
end
Hvar = cell2mat(indices);
Hall = (1:obj.ensSize(1))';

% Remove all indices not in PSMs
Hnew = allH( ~ismember(Hall, Hvar) | ismember(Hall, Hpsm) );

% Update the H indices in the PSMs
for s = 1:nPSM
    [~, psmH] = ismember( F{s}.H, newH );
    F{s}.setStateIndices( psmH );
end

% Update the ensemble / metadata / M
if exist('ens','var')
    ens.useStateIndices( Hnew );
    varargout = {ens};
else
    ensMeta = ensMeta.useStateIndices( Hnew );
    varargout = {ensMeta};
    if hasM
        M = M(Hnew,:);
        varargout = [varargout, {M}];
    end
end

end