function[obj] = remove(obj, varNames)
%% Removes variables from ensemble metadata
%
% obj = obj.remove(varNames);
%
% ----- Inputs -----
%
% varNames: A list of variable in a state vector ensemble. A string vector
%    or cellstring vector.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object

% Error check
if ~isempty(varNames)
    v = dash.checkStrsInList(varNames, obj.variableNames, 'varNames', 'variable in the state vector');

    % Remove from arrays
    obj.variableNames(v) = [];
    obj.varLimit(v,:) = [];
    obj.nEls(v) = [];
    obj.dims(v) = [];
    obj.stateSize(v) = [];
    obj.isState(v) = [];
    obj.meanSize(v) = [];
    obj.metadata = rmfield(obj.metadata, varNames);

    % Update variable limits
    last = cumsum(obj.nEls);
    obj.varLimit = [last-obj.nEls+1, last];
end

end

