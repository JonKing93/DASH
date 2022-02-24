function[] = assertUnserialized(obj, header)
%% stateVector.assertUnserialized  Throw error if state vector is serialized
% ----------

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:assertUnserialized";
end

% Empty case cannot be serialized
if isempty(obj)
    return
end

% Setup if any elements are serialized
if any([obj.isserialized])
    stack = dbstack;
    id = sprintf('%s:stateVectorIsSerialized', header);

    % Console scalar
    if numel(stack)==1 && isscalar(obj)
        name = 'The stateVector object';
        if ~strcmp(obj.label_, "")
            name = sprintf('State vector "%s"', obj.label_);
        end
        ME = MException(id, '%s has been serialized.', name);

    % Console array
    elseif numel(stack)==1
        ME = MException(id, ['The stateVector array contains elements ',...
            'that have been serialized.']);

    % From a method
    else
        method = stack(2).name;
        link ='<a href="matlab:dash.doc(''stateVector.deserialize'')">deserialize</a>';
        ME = MException(id, ['You cannot call the "%s" command on a serialized ',...
            'stateVector object. You will need to %s the object first.'], ...
            method, link);
    end

    % Throw error
    throwAsCaller(ME);
end

end