function[obj] = appendMembers(obj, ensMeta2)
%% ensembleMetadata.appendMembers  Add members to an ensembleMetadata object
% ----------
%   obj = <strong>obj.appendMembers</strong>(ensMeta2)
%   Add the ensemble members in a second ensembleMetadata object to the
%   current ensembleMetadata object. The second ensembleMetadata object
%   must have the same variables as the current object.
% ----------
%   Inputs:
%       ensMeta2 (scalar ensembleMetadata object): The second
%           ensembleMetadata object whose ensemble members should be added to
%           the current object.
%
%   Outputs:
%       obj (scalar ensembleMetadata object): The ensembleMetadata object
%           with updated ensemble members.
%
% <a href="matlab:dash.doc('ensembleMetadata.appendMembers')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:appendMembers";
dash.assert.scalarObj(obj, header);
dash.assert.scalarType(ensMeta2, 'ensembleMetadata', 'The first input', header);

% Require the same variables and state dimensions
if obj.nVariables ~= ensMeta2.nVariables
    nVariablesError(obj, ensMeta2, header);
elseif ~isequal(obj.variables_, ensMeta2.variables_)
    variableNamesError(obj, ensMeta2, header);
elseif ~isequal(obj.lengths, ensMeta2.lengths)
    lengthsError(obj, ensMeta2, header);
elseif ~isequal(obj.stateDimensions, ensMeta2.stateDimensions)
    stateDimensionsError(obj, ensMeta2, header);
elseif ~isequal(obj.stateSize, ensMeta2.stateSize)
    stateSizeError(obj, ensMeta2, header);
elseif ~isequal(obj.state, ensMeta2.state)
    stateMetadataError(obj, ensMeta2, header);

% Also require the same coupling sets
elseif ~isequal(obj.nSets, ensMeta2.nSets)
    setsError(obj, ensMeta2, header);
elseif ~isequal(obj.couplingSet, ensMeta2.couplingSet)
    couplingSetError(obj, ensMeta2, header);
elseif ~isequal(obj.ensembleDimensions, ensMeta2.ensembleDimensions)
    ensembleDimensionsError(obj, ensMeta2, header);
end

% Cycle through ensemble dimensions in each coupling set
for s = 1:obj.nSets
    dims = obj.ensembleDimensions{s};
    for d = 1:numel(dims)

        % Append the metadata for the new members
        currentMetadata = obj.ensemble{s}{d};
        newMetadata = ensMeta2.ensemble{s}{d};
        try
            obj.ensemble{s}{d} = cat(1, currentMetadata, newMetadata);
        catch
            couldNotAppendError;
        end
    end
end

% Update the size
obj.nMembers = obj.nMembers + ensMeta2.nMembers;

end

%% Error messages
function[] = nVariablesError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

id = sprintf('%s:differentNumberOfVariables', header);
ME = MException(id, ['The current ensembleMetadata object%s has %.f variables, ',...
    'but the second object%s has %.f variables.'], name1, obj.nVariables, ...
    name2, ensMeta2.nVariables);
throwAsCaller(ME);
end
function[] = variableNamesError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

bad = find(~strcmp(obj.variables_, ensMeta2.variables_), 1);

id = sprintf('%s:differentVariableNames', header);
ME = MException(id, ['The two ensembleMetadata objects have different variables. ',...
    'In the current object%s, variable %.f is named "%s", but in the second ',...
    'object%s, variable %.f is named "%s".'], name1, bad, obj.variables_(bad),...
    name2, bad, ensMeta2.variables_(bad));
throwAsCaller(ME);
end
function[] = lengthsError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

v = find(obj.lengths~=ensMeta2.lengths, 1);

id = sprintf('%s:differentLengths', header);
ME = MException(id, ['The variables in the two ensembleMetadata objects have different lengths. ',...
    'In the current object%s, the "%s" variable has a length of %.f, but in the second ',...
    'object%s, "%s" has a length of %.f.'], name1, obj.variables_(v), obj.lengths(v),...
    name2, ensMeta2.variables_(v), ensMeta2.lengths(v));
throwAsCaller(ME);
end
function[] = stateDimensionsError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

for v = 1:obj.nVariables
    if ~isequal(obj.stateDimensions{v}, ensMeta2.stateDimensions{v})
        break
    end
end

id = sprintf('%s:differentStateDimensions', header);
ME = MException(id, ['The variables in the two ensembleMetadata objects have different state dimensions.\n',...
    'In the current object%s, the "%s" variable has the following state dimensions: %s.\n',...
    'In the second object%s, "%s" has the following state dimensions: %s.'],...
    name1, obj.variables_(v), dash.string.list(obj.stateDimensions{v}),...
    name2, obj.variables_(v), dash.string.list(ensMeta2.stateDimensions{v}) );
throwAsCaller(ME);
end
function[] = stateSizeError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

for v = 1:obj.nVariables
    if ~isequal(obj.stateSize{v}, ensMeta2.stateSize{v})
        d = find(obj.stateSize{v} ~= ensMeta2.stateSize{v}, 1);
        break
    end
end

id = sprintf('%s:differentStateSizes', header);
ME = MException(id, ['The variables in the two ensembleMetadata objects have different state dimension lengths.\n',...
    'In the current object%s, the "%s" dimension of the "%s" variable has a length of %.f.\n',...
    'In the second object%s, the dimension has a length of %.f.'],...
    name1, dimension, obj.variables_(v), obj.stateSize{v}(d),...
    name2, ensMeta2.stateSize{v}(d) );
throwAsCaller(ME);
end
function[] = stateMetadataError(obj, ensMeta2, header)

for v = 1:obj.nVariables
    for d = 1:numel(obj.state{v})
        if ~isequal(obj.state{v}{d}, ensMeta2.state{v}{d})
            break
        end
    end
end

id = sprintf('%s:differentStateMetadata', header);
ME = MException(id, ['The "%s" variables in the two ensembleMetadata objects ',...
    'have different metadata along the "%s" dimension.'], obj.variables_(v), ...
    obj.stateDimensions{v}(d) );
throwAsCaller(ME);
end
function[] = setsError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

id = sprintf('%s:differentNumberOfSet', header);
ME = MException(id, ['The current object%s has %.f coupling sets, but the ',...
    'second object%s has %.f sets.'], name1, obj.nSets, name2, ensMeta2.nSets);
throwAsCaller(ME);
end
function[] = couplingSetError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

v = find(obj.couplingSet ~= ensMeta2.couplingSet, 1);
id = sprintf('%s:differentCouplingSets', header);
ME = MException(id, ['In the current object%s, the "%s" variable is a member ',...
    'of coupling set %.f, but in the second object%s, it is a member of set %.f.'],...
    name1, obj.couplingSet(v), name2, ensMeta2.couplingSet(v));
throwAsCaller(ME);

end
function[] = ensembleDimensionsError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

for v = 1:obj.nVariables
    s = obj.couplingSet(v);
    if ~isequal(obj.ensembleDimensions{s}, ensMeta2.ensembleDimensions{s})
        break
    end
end

id = sprintf('%s:differentEnsembleDimensions', header);
ME = MException(id, ['The variables in the two ensembleMetadata objects have ',...
    'different ensemble dimensions.\nIn the current object%s, the "%s" variable ',...
    'has the following ensemble dimensions: %s\nIn the second object%s, "%s" ',...
    'has the following state dimensions: %s'],...
    name1, obj.variables_(v), dash.string.list(obj.ensembleDimensions{s}),...
    name2, obj.varibales_(v), dash.string.list(ensMeta2.ensembleDimensions{s}) );
throwAsCaller(ME);

end
