function[v] = findVarIndices( obj, varName )
% Get the dimension indices of named variables

% Ensure that varName is a set of names. Convert to "string" for internal use
if ~isstrlist(varName)
    error('varName must be a character row vector, cellstring, or string vector.');
end
varName = string(varName);

% Get the indices of the names in the state design
[ismem, v] = ismember( varName(:), obj.varName );

% Throw error if any variables are not in the state design.
if any( ~ismem )
    error('Variable %s is not in the state design', varName(find(~ismem,1)) );
end

end