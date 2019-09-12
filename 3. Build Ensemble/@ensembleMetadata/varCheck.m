function v = varCheck( obj, vars )
% Checks if a set of variables are in the ensemble metadata. If they are,
% returns the variable indices
%
% vars: A cellstring, character row vector, or string array

% Error check input. Convert to string for internal use.
if ~isstrlist(vars)
    error('vars must be a character row vector, cellstring, or string array.');
end
vars = string(vars);

% Check they exist. Return indices
[ismem, v] = ismember( vars, obj.varNames );
if any( ~ismem )
    error('"%s" is not a variable in the ensemble metadata.', vars(find(~ismem,1)) );
end

end