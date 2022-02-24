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

    % Array, console scalar, method scalar
    if ~isscalar(obj)
        ME = MException(id, ['The stateVector array contains elements ',...
            'that have been serialized.']);
    elseif numel(stack)==1
        ME = MException(id, '%s has been serialized.', obj.name(true));
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