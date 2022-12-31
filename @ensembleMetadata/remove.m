function[obj] = remove(obj, variables)
%% ensembleMetadata.remove  Remove variables from an ensembleMetadata object
% ----------
%   obj = <strong>obj.remove</strong>(variableNames)
%   obj = <strong>obj.remove</strong>(v)
%   Removes the indicated variables from an ensembleMetadata object. All
%   other variables are retained in the metadata.
% ----------
%   Inputs:
%       variableNames (string vector): The names of variables that should
%           be removed from an ensembleMetadata object.
%       v (logical vector | vector, linear indices | -1): The indices of
%           variables to remove from the object. If a logical vector, must
%           have one element per variable in the state vector. If -1,
%           removes all variables.
%
%   Outputs:
%       obj (scalar ensembleMetadata object): The ensembleMetadata object
%           with updated variables.
% <a href="matlab:dash.doc('ensembleMetadata.remove')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:remove";
dash.assert.scalarObj(obj, header);

% Get variable indices
v = obj.variableIndices(variables, true, header);

% Remove variables
obj.variables_(v,:) = [];
obj.lengths(v,:) = [];
obj.stateDimensions(v,:) = [];
obj.stateSize(v,:) = [];
obj.stateType(v,:) = [];
obj.state(v,:) = [];

% Remove the coupling set indices
sets = obj.couplingSet(v);
obj.couplingSet(v,:) = [];

% Cycle through the unique coupling sets of removed variables
sets = unique(sets);
for k = 1:numel(sets)
    s = sets(k);

    % Remove sets for which no variables remain
    if ~any(obj.couplingSet == s)
        obj.nSets = obj.nSets - 1;
        obj.ensembleDimensions(s,:) = [];
        obj.ensemble(s,:) = [];

        % Update set indices
        update = sets>s;
        sets(update) = sets(update) - 1;
        update = obj.couplingSet > s;
        obj.couplingSet(update) = obj.couplingSet(update) - 1;
    end
end

% Update sizes
obj.nVariables = numel(obj.variables_);
obj.nSets = numel(obj.ensemble);
if obj.nSets == 0
    obj.nMembers = 0;
end

end
    
