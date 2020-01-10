function[] = setValues( M, D, R, F )
% obj.reconstructVars( ens, vars );
%

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

% Error check, process as generic filter
[M, D, R, F, Rtype] = obj.checkValues( M, D, R, F, Rtype );

% Get some sizes
if isa(M, 'ensemble')
    meta = M.loadMetadata;
    nState = meta.ensSize(1);
    nEns = meta.ensSize(2);
else
    [nState, nEns] = size(M);
end
[nObs, nTime] = size(D);

% Check that localization still works
if ~isempty( obj.localize )
    if strcmpi(obj.type, 'serial')
        w = obj.localize;
    else
        w = obj.localize{1};
    end
    if ~isequal( size(w), [nState,nObs] )
        error('The previous w localization weights are (%.f x %.f), which would no longer be the correct size (%.f x %.f). You can reset them with the command:\n\t>> obj.settings(''localize'', [])', size(w,1), size(w,2), nState, nObs );
    end
    % Note that we don't need to reset yloc, because w already scales to nObs
end

% Check that reconstruction indices are still allowed
if ~isempty( obj.reconstruct )
    if length(obj.reconstruct)~=nState
        error('The size of the prior would change, so the previously specified reconstruction indices are no longer valid. You can reset them with the command:\n\t>> obj.settings(''reconstruct'', [])%s','');
    end
    
    % Check against PSM H indices if doing serial updates
    if strcmpi(type, 'serial')
        psmIndices = cell(nObs,1);
        for d = 1:nObs
            psmIndices{d} = F{d}.H;
        end
        psmIndices = cell2mat(psmIndices);
        if any( ~ismember(psmIndices, find(obj.reconstruct) ))
            error('The previously specified reconstruction indices would no longer include the PSM state indices (H). Consider switching to joint updates, or resetting the reconstruction indices with the command:\n\t>> obj.settings(''reconstruct'', [])%s','');
        end
    end
end

% Everything is good, set the values
obj.M = M;
obj.D = D;
obj.R = R;
obj.F = F;
obj.Rtype = Rtype;


end