function[meta] = loadedMetadata(obj, varNames, members)
%% Returns the metadata for the data that will be loaded from a .ens file.
%
% meta = obj.loadedMetadata
% Returns the ensembleMetadata object for the data that will be loaded via
% the "load" method.
%
% meta = obj.loadedMetadata(varNames)
% meta = obj.loadedMetadata(v)
% Returns the ensembleMetadata object for data loaded with the specified
% variables and all ensemble members. Use an empty array to select all
% variables.
%
% meta = obj.loadedMetadata(..., members)
% Returns the ensembleMetadata object for data loaded with the specified
% variables and ensemble members.
% 
% ----- Inputs -----
%
% varNames: Names of variables in the state vector. A string vector or
%    cellstring vector.
%
% v: Variable indices. The index of variables in the list of variables
%    obtained via "obj.variableNames"
%
% members: A vector of indices indicating which ensemble members to use.
%    Either a vector of linear indices or a logical vector with one element
%    per ensemble member.
%
% ----- Outputs -----
%
% meta: The ensembleMetadata object for the specified set of loaded data.

% Defaults for variables
vars = obj.meta.variableNames;
if nargin==1
    [m, v] = obj.loadSettings;
elseif isempty(varNames)
    v = 1:numel(vars);
else
    list = 'variable in the state vector';
    length = 'the number of variables in the state vector';
    elt = 'variables in the state vector';
    v = dash.parseListIndices(varNames, 'varNames', 'v', vars, list, length, 1, elt);
end

% Defaults for members
[~, nEns] = obj.meta.sizes;
if nargin==2 || (nargin==3 && isempty(members))
    m = 1:nEns;
elseif nargin==3
    m = dash.checkIndices(members, 'members', nEns, 'the number of ensemble members');
end

% Build the ensembleMetadata object
meta = obj.meta.extract( vars(v) );
meta = meta.useMembers(m);

end