function[ensMeta] = useStateIndices( obj, H )
% Limits ensemble metadata to specific state indices.
%
% ensMeta = obj.useStateIndices( H )
% Reduces the ensemble metadata to specified state indices.
%
% ----- Inputs -----
%
% H: A logical vector indicating which state indices to use. All indices
%    are relative to the original (saved) ensemble.
%
% ----- Outputs -----
%
% ensMeta: The reduced ensemble metadata

% Number of state elements in original ensemble.
siz = obj.design.ensembleSize;
nState = siz(1);

% Error check
if ~isvector(H) || ~islogical(H) || numel(H)~=nState
    error('H must be a logical vector with %.f elements.', nState );
end

% Get the metadata for the complete ensemble.
ensMeta = ensembleMetadata( obj.design );
nVar = numel(ensMeta.varName);

% Update the metadata for each variable
H = find(H);
for v = nVar:-1:1
    varIndices = H>=ensMeta.varLim(v,1) & H<=ensMeta.varLim(v,2);
    
    % The variable is in not in the state indices
    if ~any( varIndices )
        ensMeta.varName(v) = [];
        ensMeta.varSize(v,:) = [];
        ensMeta.stateMeta = rmfield( ensMeta.stateMeta, ensMeta.varName(v) );
        ensMeta.ensMeta = rmfield( ensMeta.ensMeta, ensMeta.varName(v) );
        ensMeta.varLimit(v,:) = [];
        
    % The variable is in the indices. Check for a partial grid
    else
        nEls = sum(varIndices);
        if nEls < prod(ensMeta.varSize(v,:))
            ensMeta.partialGrid(v) = true;
            ensMeta.nEls(v) = nEls;
        end
    end
end 
   
% Recalculate limits and ensemble size
lastIndex = cumsum( ensMeta.varLimit(:,2) - ensMeta.varLimit(:,1) + 1 );
firstIndex = [1; lastIndex(1:end-1)-1];
ensMeta.varLimit = [firstIndex, lastIndex];
ensMeta.ensSize(1) = lastIndex(end);

end