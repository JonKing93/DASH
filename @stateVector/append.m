function[obj] = append(obj, vector2, responseToRepeats)
%% stateVector.append  Appends a second state vector to the end of the current state vector
% ----------
%   obj = obj.append(vector2)
%   Appends the variables in a second stateVector object to the end of the
%   current stateVector object.
%
%   obj = obj.append(vector2, responseToRepeats)
%   Specify how to respond when variable names are repeated across the two
%   state vectors.
% ----------
%   Inputs:
%       vector2 (scalar stateVector object): The state vector to append to
%           the current state vector.
%       responseToRepeats (scalar integer): Indicates how to treat repeated
%           variable names across the two state vectors.
%           [0 (default)]: Throw an error if variable names are repeated
%           [1]: Keep the variable from the current state vector and
%                discard the variable in the second state vector.
%           [2]: Keep the variable in the second state vector and discard
%                the variable in the current state vector.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated to
%           include the appended variables.
%
% <a href="matlab:dash.doc('stateVector.append')">Documentation Page</a>

% Setup
header = "DASH:stateVector:append";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Error check second vector
dash.assert.scalarType(vector2, 'stateVector', 'vector2', header);

% Error check response to repeated variables
if ~exist('responseToRepeats','var') || isempty(responseToRepeats)
    responseToRepeats = 0;
else
    dash.assert.scalarType(responseToRepeats, 'numeric', 'responseToRepeats', header);
    if ~ismember(responseToRepeats, 0:2)
        id = sprintf('%s:invalidResponseToRepeats', header);
        error(id, 'responseToRepeats must be either 0, 1, or 2.');
    end
end

% Check for repeats
vars2 = vector2.variables;
repeats = ismember(vars2, obj.variables);

% Process repeats
if any(repeats)
    if responseToRepeats==0
        repeatedVariablesError(obj, vector2, repeats, header);
    elseif responseToRepeats==1
        vector2 = vector2.remove(vars2(repeats));
    elseif responseToRepeats==2
        obj = obj.remove(vars2(repeats));
    end
end

% Append the second vector
obj.variableNames = [obj.variableNames; vector2.variableNames];
obj.variables_ = [obj.variables_; vector2.variables_];
obj.allowOverlap = [obj.allowOverlap; vector2.allowOverlap];
obj.nVariables = numel(obj.variables_);

error('coupled variables');
end

function[] = repeatedVariablesError(obj, vector2, repeats, header)

name1 = 'the current state vector';
if ~strcmp(obj.label,"")
    name1 = obj.name;
end

name2 = 'the second state vector';
if ~strcmp(vector2.label, "")
    name2 = vector2.name;
end

repeats = vector2.variables(repeats);

id = sprintf('%s:repeatedVariableNames', header);
ME = MException(id, ['Cannot append %s to %s because both state vectors ',...
    'contain variables named %s.'], name2, name1, dash.string.list(repeats));
throwAsCaller(ME);

end