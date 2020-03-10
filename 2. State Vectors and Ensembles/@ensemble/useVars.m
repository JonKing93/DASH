function[] = useVars( obj, vars )
% Specifies which variables to load from a .ens file.
%
% obj.useVars( vars )
% Specify which variables to load.
%
% obj.useVars( 'all' )
% Load all variables.
%
% ----- Inputs -----
%
% vars: The names of the variables to load. A string vector, cellstring 
%       vector, or character row vector.

% Values for reset flag
if isstrflag(vars) && strcmpi( vars, 'all' )
    vars = meta.varName;
end

% Error check.
if ~isstrlist(vars)
    error('vars must be a string vector, cellstring vector, or character row vector.');
end
allMeta = ensembleMetadata( obj.design );
v = allMeta.varCheck(vars);

% Update load parameters
nVar = numel(allMeta.varName);
obj.loadVar = ismember( 1:nVar, v );

% Update metadata
obj.updateMetadata( 'vars', obj.loadVar );

end