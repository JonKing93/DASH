function[obj] = append(obj, meta2, responseToRepeats)
%% ensembleMetadata.append  Add variables to an ensembleMetadata object
% ----------
%   obj = obj.append(ensMeta2)
%   Adds the variables in a second ensembleMetadata object to the current
%   object. The second ensembleMetadata object must have the same number of
%   ensemble members as the current object. By default, throws an error if
%   the second object has any variables with the same name as a variable in
%   the current object.
%
%   obj = obj.append(ensMeta2, responseToRepeats)
%   obj = obj.append(ensMeta2, "error"|"e"|0)
%   obj = obj.append(ensMeta2, "first"|"f"|1)
%   obj = obj.append(ensMeta2, "second"|"s"|2)
%   Indicate how to treat variable names that are repeated in the current
%   and second ensembleMetadata objects. If "error"|"e"|0, throws an error
%   when duplicate variable names occur. If "first"|"f"|1, retains the
%   variable in the current ensembleMetadata object and discards the variable
%   in the second object. If "second"|"s"|2, discards the variable in the
%   current object, and retains the variable in the second object.
% ----------
%   Inputs:
%       ensMeta2 (scalar ensembleMetadata object): A second ensembleMetadata
%           object whose variables should be added to the current object.
%       responseToRepeats (string scalar | scalar integer): Indicates how
%           to treat variables with duplicate names across the current and
%           second ensembleMetadata objects.
%           [0|"e"|"error" (default)]: Throws an error when duplicate names occur
%           [1|"f"|"first"]: Uses the variables in the current object
%           [2|"s"|"second"]: Uses the variables in the second object
%
%   Outputs:
%       obj (scalar ensembleMetadata object): The ensembleMetadta object
%           with updated variables.
%
% <a href="matlab:dash.doc('ensembleMetadata.append')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:append";
dash.assert.scalarObj(obj, header);

% Check the second vector
dash.assert.scalarType(meta2, 'ensembleMetadata', 'The first input', header);
if ~isequal(obj.nMembers, meta2.nMembers)
    differentMembersError(obj, ensMeta2, header);
end

% Default and check response to repeated variables
if ~exist('responseToRepeats','var') || isempty(responseToRepeats)
    response = 0;
else
    response = dash.parse.switches(responseToRepeats, ...
        {["e","error"],["f","first"],["s","second"]}, 1, 'responseToRepeats', ...
        'allowed option', header);
end

% Check for repeats
vars2 = meta2.variables;
repeats = ismember(vars2, obj.variables);

% Process repeat variables
if any(repeats)
    repeats = vars2(repeats);
    if response==0
        repeatVariablesError;
    elseif response==1
        meta2 = meta2.remove(repeats);
    elseif response==2
        obj = obj.remove(repeats);
    end
end

% Append the variables from the second metadata object
obj.variables_ = [obj.variables; meta2.variables];
obj.lengths = [obj.lengths; meta2.lengths];
obj.stateDimensions = [obj.stateDimensions; meta2.stateDimensions];
obj.stateSize = [obj.stateSize; meta2.stateSize];
obj.state = [obj.state; meta2.state];

% Append the coupling sets
obj.couplingSet = [obj.couplingSet; obj.nSets+meta2.couplingSet];
obj.ensembleDimensions = [obj.ensembleDimensions; meta2.ensembleDimensions];
obj.ensemble = [obj.ensemble; meta2.ensemble];

% Update sizes
obj.nVariables = numel(obj.variables_);
obj.nSets = numel(obj.ensemble);

end

%% Error messages
function[] = differentMembersError(obj, ensMeta2, header)
name1 = '';
if ~strcmp(obj.label_, "")
    name1 = sprintf(' (%s)', obj.label_);
end
name2 = '';
if ~strcmp(ensMeta2.label_, "")
    name2 = sprintf(' (%s)', ensMeta2.label_);
end

id = sprintf('%s:differentNumberOfMembers', header);
ME = MException(id, ['The two ensembleMetadata object have different numbers of ensemble ',...
    'members. The current object%s has %.f ensemble members, but the second ',...
    'object has %.f members.'], name1, obj.nMembers, name2, ensMeta2.nMembers);
throwAsCaller(ME);
end