function[nameDex] = varCheck( ensMeta, name )
%% Checks for a variable name field and returns variable indices
%
% ensMeta: Ensemble metadata
%
% name: Variable name
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check that the metadata has a variable name field
[~,~,var] = getDimIDs;
if ~isfield(ensMeta, var)
    error('Ensemble metadata does not contain the %s field.', var);
end

% Check that the name is a string
if ~isstrflag( name )
    error('Variable name must be a string.');
end

% Get the indices of the name
nameDex = find( ismember( ensMeta.var, name ) );

end
