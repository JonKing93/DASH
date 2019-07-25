function[v] = varCheck( ensMeta, name )
%% Checks for a variable name field and returns variable indices
%
% ensMeta: Ensemble metadata
%
% name: Variable name
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check for variables in the ensemble metadata
[ismem, v] = ismember( name, ensMeta.varName );

% Ensure that all variables presented are in the ensemble metadata
if any( ~ismem )
    badVar = find( ~ismem,1 );
    error('The %s variable is not in the ensemble metadata.', name(badVar) );
end

end
