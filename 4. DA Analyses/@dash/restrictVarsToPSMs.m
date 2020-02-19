function[F, M, ensMeta] = restrictVarsToPSMs( vars, F, M, ensMeta )
%% Restricts specified variables to only the elements needed to run PSMs.
%
% [F, M, ensMeta] = dash.restrictVarsToPSMs( vars, F, M, ensMeta )
% Restricts specified variables to elements essential to PSMs. Returns the
% reduced ensemble, associated (unstable) metadata, and PSMs with updated
% state indices.
%
% ----- Inputs -----
%
% vars: A list of variable names. Cellstring, string, or character row
% vector.
%
% F: A cell array of PSMs
%
% M: An ensemble. (nState x nEns)
%
% ensMeta: Metadata associated with the ensemble.
%
% ----- Outputs -----
%
% F: PSMs with updated state vector indices.
%
% M: The reduced ensemble.
%
% ensMeta: An unstable metadata object for the reduced ensemble. Can be
%          used to regrid variables that were not restricted to PSM
%          indices.
%
%          *** Warning: this ensemble metadata object should not be used
%          for anything else. It is highly unstable...

% Error checking
if ~isvector(F) || ~iscell(F)
    error('F must be a cell vector of PSM objects.');
elseif ~isnumeric(M) || ~ismatrix(M)
    error('M must be a numeric matrix');
elseif ~isscalar(ensMeta) || ~isa(ensMeta, 'ensembleMetadata')
    error('ensMeta must be a scalar ensembleMetadata object.');
elseif ~isequal( size(M,1), ensMeta.ensSize(1) )
    error('The number of rows in M does not match the size in the ensemble metadata.');
end
nState = size(M,1);

% Check the variables exist. Get indices
v = ensMeta.varCheck( vars );

% Collect all the H indices. Error check individual PSMs
nSite = numel(F);
psmH = [];
for s = 1:nSite
    if ~isscalar(F{s}) || ~isa(F{s},'PSM')
        error('Element %.f of F is not a scalar PSM object.',s);
    elseif any(F{s}.H<1) || any(F{s}.H>nState) || any(mod(F{s}.H,1)~=0)
        error('The state indices (H) for PSM %.f are not integers on the interval [1 %.f]', s, nState );
    end
    psmH = [psmH; F{s}.H]; %#ok<AGROW>
end

% Get the set of all H indices, and all indices associated with the
% variables. Mark the variables as unregriddable.
allH = (1:nState)';
varH = [];
for k = 1:numel(vars)
    varH = [varH; ensMeta.varIndices( vars(k) )]; %#ok<AGROW>
end

% Remove all indices for specified variables not in PSMs
newH = allH( ~ismember(allH, varH) | ismember(allH, psmH) );

% Update the ensemble and metadata
M = M(newH, :);
last = 0;
for k = 1:numel(ensMeta.varName)
    nIndex = sum( ismember(ensMeta.varIndices(ensMeta.varName(k)), newH) );
    ensMeta.varLimit(k,:) = [last+1, last+nIndex];
    if ismember(k,v)
        ensMeta.noRegrid(k) = true;
    end
    last = last+nIndex;
end

% Update the H indices in each PSM
for s = 1:nSite
    [~, newPsmH] = ismember( F{s}.H, newH );
    F{s}.setStateIndices( newPsmH );
end

end
    

