function[] = assertValid(obj, header)
%% gridfile.assertValid  Throw error if a scalar gridfile object is not valid (is deleted)
% ----------
%   <strong>obj.assertValid</strong>
%   Throws an error if the object is not valid. Note that this method
%   should only be called on scalar gridfile objects.
%
%   <strong>obj.assertValid</strong>(header)
%   Customize header in error IDs.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%
%   <a href="matlab:dash.doc('gridfile.assertValid')">Documentation Page</a>

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:gridfile:assertValid";
end

% Check if valid
if ~isvalid(obj)
    id = sprintf('%s:deletedObjectNotSupported', header);
    stack = dbstack;

    % Error
    if numel(stack)==1
        ME = MException(id, 'The gridfile object has been deleted.');
    else
        method = stack(1).name;
        ME = MException(id, 'You cannot call the "%s" command on a deleted gridfile object.', method);
    end
    throwAsCaller(ME);
end

end
    