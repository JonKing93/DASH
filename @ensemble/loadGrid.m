function[X, metadata, members, labels] = loadGrid(obj, variable, ensembles)
%% ensemble.loadGrid  Load a gridded variable from a saved state vector ensemble
% ----------
%   [X, metadata] = obj.loadGrid(variableName)
%   [X, metadata] = obj.loadGrid(v)
%   Loads a variable from a saved ensemble into memory. Regrids the state
%   vector for the variable into a gridded dataset. The regridded variable will
%   be an N-dimensional array. The leading dimensions of the array will be
%   the state dimensions of the variable. The next dimension holds the
%   different ensemble members. Finally, the last dimension holds the values
%   for different ensembles in an evolving set. If the ensemble object
%   implements a static ensemble, then this final dimension will be a singleton.
%
%   The returned metadata is a gridMetadata object that describes the
%   regridded state dimensions of the variable. This method does not remove
%   singleton state dimensions, so the metadata will hold information for
%   all state dimension. If the variable implements a mean over a state
%   dimension, the metadata for that dimension will have one row per
%   element used in the mean. The metadata does not hold information on the
%   different ensemble members or different ensembles in an evolving set.
%
%   The specified variable must be a variable used by the ensemble object,
%   and the method will only load used ensemble members. By default,
%   ensemble objects use all variables and ensemble members saved in the
%   .ens file. See the "useVariables", "useMembers", and "evolving"
%   commands to use different subsets of variables and ensemble members.
%
%   The "ensembleMetadata.regrid" command also regrids state vector
%   variables and provides additional options for regridding variables. For
%   example, customizing the order of regridded dimensions and removing
%   singleton dimensions from the regridded dataset. For a memory efficient
%   way to apply the "regrid" command to a saved ensemble: 
%   1. Use "ensemble.useVariable" to select only the variable of interest, 
%   2. Use "ensemble.load" to load the variable and an associated ensembleMetadata object, then 
%   3. Use the ensembleMetadata object and its "regrid" command to regrid the variable.
%
%   [X, metadata, members, evolvingLabels] = obj.loadGrid(variable)
%   Also returns the ensemble members and labels of any evolving ensembles
%   in the regridded dataset.
%
%   ... = obj.loadGrid(variable, labels)
%   ... = obj.loadGrid(variable, e)
%   ... = obj.loadGrid(variable, -1)
%   Loads specific ensembles in the evolving set. If the second input is -1,
%   selects all ensembles in the evolving set. The dimension of the
%   regridded dataset that corresponds to evolving ensembles is the
%   dimension following the ensemble members. The length of this evolving
%   ensemble dimension will match the number of requested ensembles, and
%   the elements of this dimension will follow the order in which the
%   ensembles were requested.
% ----------
%   Inputs:
%       variableName (string scalar): The name of a variable being used by
%           the ensemble object.
%       v (logical vector | scalar linear index): The index of a variable
%           being used by the ensemble object. If a logical vector, must
%           have a single true element.
%       e (-1 | vector, linear indices | logical vector): Indicates the
%           ensembles to load. If -1, loads all ensembles in the evolving
%           set. If a logical vector, must have one element per ensemble in
%           the evolving set. Otherwise, use the linear indices of
%           ensembles in the evolving set.
%       labels (string vector): The labels of specific ensembles in the
%           evolving set. You can only use labels to reference ensembles
%           that have unique labels. Use linear indices to reference 
%           ensembles that share the same label.
%
%   Outputs:
%       X (numeric array [? x nMembers x nEvolving]): The regridded loaded
%           variable. Has one dimension for each state dimension, followed
%           by ensemble members, and then evolving ensembles.
%       metadata (scalar gridMetadata object): A gridMetadata object for
%           the regridded variable. Has information for each state
%           dimension of the regridded variable. Metadata fields are in the
%           same order as the leading dimensions of the output X. If the
%           state vector implements a mean along a state dimension, the
%           metadata for the dimension has a row for each element used in
%           the mean.
%       members (array, positive integers, [nMembers x nEvolving]):
%           The ensemble members for the loaded ensembles. Each element 
%           of "members" lists the index of an ensemble member saved in the
%           .ens file. The columns of "members" list the ensemble members
%           for different loaded evolving ensembles.
%       labels (string vector [nEvolving]): The labels of the loaded
%           ensembles in the evolving set.
%
% <a href="matlab:dash.doc('ensemble.loadGrid')">Documentation Page</a>

% Setup
header = "DASH:ensemble:loadGrid";
dash.assert.scalarObj(obj, header);

% Default and error check evolving indices
if ~exist('ensembles','var')
    e = 1:obj.nEvolving;
else
    e = obj.evolvingIndices(ensembles, true, header);
end

% Get the variable indices
v = obj.variableIndices(variable, "used", header);
if numel(v)>1
    tooManyVariablesError(v, header);
end

% Isolate the variable and load
obj = obj.useVariables(v);
try
    [X(:,:,:), ensMeta] = obj.load(e);
catch ME
    throw(ME);
end

% Regrid the variable, retain singleton dimensions
[X, metadata] = ensMeta(1).regrid(1, X, 'dim',1, 'singletons','keep');

% Optionally get members and evolving labels
if nargout>2
    members = obj.members_(:,e);
    labels = obj.evolvingLabels_(e);
end

end

% Error message
function[] = tooManyVariablesError(v, header)
variables = obj.variables_(v);
variables = dash.string.list(variables);
id = sprintf('%s:tooManyVariables', header);
ME = MException(id, ['You can only list a single variable, but you have specified ',...
    '%.f variables (%s).'], numel(v), variables);
throwAsCaller(ME);
end