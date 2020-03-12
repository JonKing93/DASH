function[H] = useH( obj )
%% Collects the full set of H indices (relative to the original saved ensemble)

% Fresh metadata. Preallocate H
ensMeta = ensembleMetadata( obj.design );
H = false( ensMeta.ensSize(1), 1 );

% For each variable in the original ensemble, get the indices
for k = 1:numel(ensMeta.varName)
    varIndex = ensMeta.varIndices( ensMeta.varName(k) );
    [ismem, v] = ismember( ensMeta.varName(k), obj.varName );
    
    % Exists and is partially gridded
    if ismem && obj.partialGrid(v)
        H(varIndex) = obj.partialH{v};
        
    % Exists in full
    elseif ismem
        H(varIndex) = true;
    end
    
    % Otherwise, defaults to false
end

end