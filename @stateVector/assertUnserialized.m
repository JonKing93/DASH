function[] = assertUnserialized(obj, header)
%% stateVector.assertUnserialized  Throw error if state vector is serialized
% ----------

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:stateVector:assertUnserialized";
end

% Check if serialized
if obj.isserialized
    id = sprintf('%s:serializedObjectNotSupported', header);
    stack = dbstack;

    % Error from console or method
    if numel(stack)==1
        name = char(obj.name);
        name(1) = upper(name(1));
        ME = MException(id, '%s is serialized.', name);
    else
        link = '<a href="matlab:dash.doc(''stateVector.deserialize'')">deserialize</a>';
        method = stack(2).name;
        ME = MException(id, ['You cannot call the "%s" command on a serialized ',...
            'stateVector object. You will need to %s the object first.'],...
            method, link);
    end
    throwAsCaller(ME);
end

end