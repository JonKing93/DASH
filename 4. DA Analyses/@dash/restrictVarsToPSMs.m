function[] = restrictVarsToPSMs( vars, F, ens )
%% For specified variables, only load values required to run PSMs.
%
% dash.restrictVarsToPSMs( vars, F, ens )
% For the specified variables, only values required to run PSMs will be
% loaded from the ensemble. Updates the ensemble object and its metadata.
% Also updates the PSM array so that state indices (H) point to the correct
% locations in the reduced ensemble.
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
% ----- Outputs -----
%
% F: PSMs for which the state indices (H) have been adjusted to match the
%    smaller, restricted ensemble. (nSite x 1)
%
% ens: An ensemble object that will only load the reduced ensemble
%      (and corresponding reduced metadata).

% Error check
if ~isa(ens, 'ensemble') || ~isscalar(ens)
    error('ens must be a scalar ensemble object.');
elseif ~isstrlist(vars)
    error('vars must be a string vector, cellstring vector, or character row vector.');
elseif ~isvector(F) || ~iscell(F)
    error('F must be a cell vector.');
end
v = unique( ens.metadata.varCheck(vars) );
nVar = numel(v);
ensMeta = ens.metadata;

% Run through the PSMs, collect H indices
nPSM = numel(F);
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
    indices{var} = ensMeta.varIndices( ensMeta.varName(v(var)) );
end
Hvar = cell2mat(indices);
Hall = (1:ensMeta.ensSize(1))';

% Remove all indices not in PSMs
useH = ~ismember(Hall, Hvar) | ismember(Hall, Hpsm);
Hnew = Hall( useH );

% Update the H indices in the PSMs
for s = 1:nPSM
    [~, psmH] = ismember( F{s}.H, Hnew );
    F{s}.setStateIndices( psmH );
end

% Update the ensemble
ens.useStateIndices( useH );

end