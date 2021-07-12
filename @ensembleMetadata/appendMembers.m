function[obj] = appendMembers(obj, meta2)
%% Appends a the metadata for the ensemble members of a second state vector
% ensemble to the current ensemble metadata. (across the ensemble)
%
% obj = obj.appendMembers(meta2)
%
% ----- Inputs -----
%
% meta2: A second ensembleMetadata object. Must have exactly the same
%    variables and state vector metadata as the current object.
%
% ----- Outputs -----
%
% obj: The updated ensembleMetadata object

% Error check
dash.assert.scalarType(meta2, 'meta2', 'ensembleMetadata', 'ensembleMetadata object');

% Check that properties exactly match the current ensemble metadata
props = ["variableNames","varLimit","nEls","dims","stateSize","isState","meanSize"];
for f = 1:numel(props)
    if ~isequaln(obj.(props(f)), meta2.(props(f)))
        notMatchingError;
    end
end

% Also check that state vector metadata matches
vars = obj.variableNames;
for v = 1:numel(vars)
    if ~isequaln(obj.metadata.(vars(v)).state, meta2.metadata.(vars(v)).state)
        notMatchingError;
    end
    
    % Append the values for each ensemble dimension
    meta = obj.metadata.(vars(v)).ensemble;
    dims = string(fields(meta));
    for d = 1:numel(dims)
        if ~isempty(meta.(dims(d)))
            try
                obj.metadata.(vars(v)).ensemble.(dims(d)) = ...
                    cat(1, meta.(dims(d)), meta2.metadata.(vars(v)).ensemble.(dims(d)));
            catch
                cannotAppendError(vars(v), dims(d));
            end
        end
    end
end

% Update the number of ensemble members
obj.nEns = obj.nEns + meta2.nEns;

end

% Long error messages
function[] = notMatchingError
error(['The second ensembleMetadata object has different variables and/or ',...
    'state vector metadata than the current ensembleMetadata object.']);
end
function[] = cannotAppendError(var, dim)
error(['Cannot append the ensemble metadata for the "%s" dimension of the ',...
    '"%s" variable. The second ensembleMetadata object likely uses a second', ...
    'metadata format.'], dim, var);
end