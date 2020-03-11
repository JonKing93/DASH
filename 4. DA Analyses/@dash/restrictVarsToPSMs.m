function[F, varargout] = restrictVarsToPSMs( vars, F, meta, M )
%
% [F, ens] = restrictVarsToPSMs( vars, F, ens )
%
% [F, ensMeta] = restrictVarsToPSMs( vars, F, ensMeta )
%
% [F, ensMeta, M] = restrictVarsToPSMs( vars, F, ensMeta, M )

% Parse inputs
if isa(meta, 'ensemble')
    if ~isscalar(meta)
        error('ens must be a scalar ensemble object.');
    else
        ens = meta;
        meta = ens.metadata;
    end
end

hasM = false;
if exist('M','var')
    hasM = true;
end

% Error check
if ~isscalar(meta) || ~isa(meta, 'ensembleMetadata')
    error('meta must be a scalar ensembleMetadata object.');
elseif ~isstrlist(vars)
    error('vars must be a string vector, cellstring vector, or character row vector.');
elseif ~isvector(F) || ~iscell(F)
    error('F must be a cell vector.');
elseif hasM && (~ismatrix(M) || ~isequal(size(M),meta.ensSize))
    error('M must be a (%.f x %.f) matrix', meta.ensSize(1), meta.ensSize(2) );
end
v = unique( meta.varCheck(vars) );
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
    meta = meta.useStateIndices( Hnew );
    varargout = {meta};
    if hasM
        M = M(Hnew,:);
        varargout = [varargout, {M}];
    end
end

end