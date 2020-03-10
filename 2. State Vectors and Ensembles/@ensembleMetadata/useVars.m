function[ensMeta] = useVars( obj, vars )
% Limits ensemble metadata to specific variables.
% 
% ensMeta = obj.useVars( vars )
% Reduces the ensemble metadata to the specified variables.
%
% ----- Inputs -----
% 
% vars: A logical vector indicating which variables are used.
%
% ----- Outputs -----
%
% ensMeta: The reduced ensemble metadata

% Get the number of variables
nVar = numel( obj.design.var );

% Error check
if ~isvector(vars) || ~islogical(vars) || numel(vars)~=nVar
    error('vars must be a logical vector with %.f elements', nVar);
end

% Determine which variables to remove, and which to copy current metadata
ensMeta = ensembleMetadata( obj.design );
useVars = ensMeta.varName(vars);
removeVars = ensMeta.varName( ~vars );

remove = find( ~ismember(ensMeta.varName, useVars) );
[copy, loc] = ismember(useVars, obj.varName);
copy = find(copy);
copyVars = useVars(copy);

% Update the metadata
ensMeta.varName(remove) = [];
ensMeta.varSize(remove,:) = [];
ensMeta.stateMeta = rmfield( ensMeta.stateMeta, removeVars );
ensMeta.ensMeta = rmfield( ensMeta.ensMeta, removeVars );

ensMeta.varSize(copy,:) = obj.varSize(loc,:);
for v = 1:numel(copyVars)
    ensMeta.stateMeta.(copyVars(v)) = obj.stateMeta.(copyVars(v));
    ensMeta.ensMeta.(copyVars(v)) = obj.ensMeta.(copyVars(v));
end

% Recalculate limits and ensemble size
ensMeta.varLimit(remove,:) = [];
ensMeta.varLimit(copy,:) = obj.varLimit(loc,:);
lastIndex = cumsum( ensMeta.varLimit(:,2) - ensMeta.varLimit(:,1) + 1 );
firstIndex = [1; lastIndex(1:end-1)-1];
ensMeta.varLimit = [firstIndex, lastIndex];
ensMeta.ensSize(1) = lastIndex(end);

end