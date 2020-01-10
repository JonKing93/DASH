function[ensMeta] = useVars( obj, vars )
% Returns ensemble metadata for a state vector limited to specified variables
% 
% ensMeta = obj.useVars( vars )
% Reduces the ensemble metadata to the specified variables.
%
% ----- Inputs -----
% 
% vars: A list of variable names. A string, cellstring, or character row
%       vector.
%
% ----- Outputs -----
%
% ensMeta: The reduced ensemble metadata

% Error check
if ~isstrlist( vars )
    error('vars must be a string vector, cellstring vector, or character row vector.');
end
vars = string( vars );

% Get the variables to keep and remove.
keep = obj.varCheck( vars );
remove = ~ismember( obj.varName, obj.varName(keep) );

% Reduce the metadata
newDesign = obj.design.remove( obj.varName(remove) );
ensMeta = ensembleMetadata( newDesign );

end
