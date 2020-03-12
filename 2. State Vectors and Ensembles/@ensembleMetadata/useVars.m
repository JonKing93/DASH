function[ensMeta] = useVars( obj, vars )
% Limits ensemble metadata to specific variables.
% 
% ensMeta = obj.useVars( vars )
% Reduces the ensemble metadata to the specified variables.
%
% ----- Inputs -----
% 
% vars: A list of variable names. A string vector, cellstring vector, or
%       character row vector.
%
% ----- Outputs -----
%
% ensMeta: The reduced ensemble metadata

% Error check
if ~isstrlist( vars )
    error('vars must be a string vector, cellstring vector, or character row vector.');
end
ensMeta = ensembleMetadata( obj.design );
v = ensMeta.varCheck( vars );
nVar = numel(v);

% Get the state indices used in the current ensemble
Hcurr = obj.useH;

% Get state indices of all specified variables
Hvar = false( ensMeta.ensSize(1), 1 );
for k = 1:nVar
    varIndex = ensMeta.varIndices( ensMeta.varName(v(k)) );
    Hvar(varIndex) = true;
end

% If there are any partial grids, this follows useStateIndices. Do the new
% variables in full, as well as all previous indices.
if any( obj.partialGrid )
    Hnew = Hcurr & Hvar;
    
% But if all grids are complete, remove any unspecified variables
else
    Hnew = Hvar;
end

% Update
ensMeta = obj.useStateIndices( Hnew );

end