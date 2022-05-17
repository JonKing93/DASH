function[obj] = appendMembers(obj, meta2)

% Setup
header = "DASH:ensembleMetadata:appendMembers";
dash.assert.scalarObj(obj, header);
dash.assert.scalarType(meta2, 'ensembleMetadata', 'The first input', header);

% Require the same variables and state dimensions
if ~isequal(obj.variables_, meta2.variables_)
    variablesError;
elseif ~isequal(obj.lengths, meta2.lengths)
    lengthsError;
elseif ~isequal(obj.stateDimensions, meta2.stateDimensions)
    stateDimensionsError;
elseif ~isequal(obj.stateSize, meta2.stateSize)
    stateSizeError;
elseif ~isequal(obj.state, meta2.state)
    stateMetadataError;

% Also require the same coupling sets
elseif ~isequal(obj.nSets, meta2.nSets)
    setsError;
elseif ~isequal(obj.couplingSet, meta2.couplingSet)
    couplingSetError;
elseif ~isequal(obj.ensembleDimensions, meta2.ensembleDimensions)
    ensembleDimensionsError;
end

% Cycle through ensemble dimensions in each coupling set
for s = 1:obj.nSets
    dims = obj.ensembleDimensions{s};
    for d = 1:numel(dims)

        % Append the metadata for the new members
        currentMetadata = obj.ensemble{s}{d};
        newMetadata = meta2.ensemble{s}{d};
        try
            obj.ensemble{s}{d} = cat(1, currentMetadata, newMetadata);
        catch
            couldNotAppendError;
        end
    end
end

% Update the size
obj.nMembers = obj.nMembers + meta2.nMembers;

end