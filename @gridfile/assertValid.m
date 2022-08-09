function[] = assertValid(obj, header)
%% gridfile.assertValid  Throw error if a gridfile array has deleted elements
% ----------
%   <strong>obj.assertValid</strong>
%   Throws an error if a gridfile array contains elements that are not
%   valid (i.e. have been deleted).
%
%   <strong>obj.assertValid</strong>(header)
%   Customize header in error IDs.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('gridfile.assertValid')">Documentation Page</a>

% Default header
if ~exist('header','var') || isempty(header)
    header = "DASH:gridfile:assertValid";
end

% Empty case cannot be deleted
if isempty(obj)
    return
end

% Setup if any elements are not valid
if ~all(isvalid(obj))
    stack = dbstack;
    id = sprintf('%s:gridfileNotValid', header);

    % Array, console scalar, method scalar
    if ~isscalar(obj)
        ME = MException(id, 'The gridfile array contains deleted elements.');
    elseif numel(stack)==1
        ME = MException(id, 'The gridfile object has been deleted.');
    else
        method = stack(2).name;
        ME = MException(id, 'You cannot call the "%s" command on a deleted gridfile object.', method);
    end

    % Error
    throwAsCaller(ME);
end

end 