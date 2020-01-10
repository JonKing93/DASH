function[] = useVars( obj, vars )
% Specifies which variables to load from a .ens file.
%
% obj.useVars( vars )
%
% ----- Inputs -----
%
% vars: The names of the variables to load. A string, cellstring, or
%       character row vector.

% Error check
if ~isstrlist(vars)
    error('vars must be a string vector, cellstring vector, or character row vector.');
end
obj.metadata.varCheck(vars);

obj.loadVars = string(vars);

end