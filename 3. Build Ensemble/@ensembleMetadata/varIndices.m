function[H] = varIndices( obj, varName )
% Returns the state element indices associated with a particular variable.
%
% H = obj.varIndices( varName )
%
% ----- Inputs -----
%
% varName: The name of a variable.
%
% ----=- Outputs -----
%
% H: The state indices associated with the variable

% Check this is a single variable in the metadata. Get its index
if ~isstrflag(varName)
    error('varName must be a character row or string scalar.');
end
v = obj.varCheck( varName );

% Get the indices
H = (obj.varLim(v,1) : obj.varLim(v,2))';

end