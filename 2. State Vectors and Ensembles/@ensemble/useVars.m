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

% Collect variable indices
nVars = numel(v);
indices = cell( nVars, 1 );
for k = 1:nVars
    indices{k} = allMeta.varIndices( allMeta.varName(v(k)) );
end
indices = cell2mat(indices);

% Combine with any previously specified load indices. Update load
% parameters
varH = false( obj.ensSize(1), 1 );
varH(indices) = true;
if ~isempty(obj.loadH)
    varH = varH | obj.loadH;
end
obj.loadH = varH;

% Update metadata
obj.loadSize(1) = sum(obj.loadH);
obj.updateMetadata;

end