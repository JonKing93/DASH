function[] = checkValues( obj, M, D, ~, F, ~ )
% Check values against kalman filter settings

% Get some sizes
if isa(M, 'ensemble')
    meta = M.loadMetadata;
    nState = meta.ensSize(1);
else
    nState = size(M,1);
end
nObs = size(D,1);

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
        error('The size of the prior would change, so the previously specified reconstruction indices would not be valid. You can reset them with the command:\n\t>> obj.reconstructVars%s','');
    end
    
    % Check if PSM H indices are reconstructed. Throw error if serial.
    reconH = dash.checkReconH( obj.reconstruct, F );
    if ~reconH && strcmpi(type,'serial') && ~obj.append
        error('The previously specified reconstruction indices would no longer include the PSM state indices (H). Consider switching to joint updates, using the appended Ye method, or resetting the reconstruction indices with the command:\n\t>> obj.reconstructVars%s','');
    end
end

% Set internal values
if ~isempty( obj.reconstruct )
    obj.reconH = reconH;
end

end