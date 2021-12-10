function[] = scalarObj(obj, header)
%% dash.assert.scalarObj  Throw error if method object is not scalar
% ----------
%   dash.assert.scalarObj(obj)
%   Throws an error if the object is not scalar.
%
%   dash.assert.scalarObj(obj, header)
%   Customize thrown error IDs.
% ----------
%   Inputs:
%       obj (class instance): The object used to call a method.
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('dash.assert.scalarObj')">Documentation Page</a>

% Default
if ~exist('header','var') || isempty(header)
    header = 'DASH:assert:scalarObj';
end

% Throw error if not scalar
if ~isscalar(obj)
    id = sprintf('%s:objectArrayNotSupported', header);
    stack = dbstack('-completenames');
    type = class(obj);
    
    % Reference command name if called in stack
    if numel(stack)>1
        [~, command] = fileparts(stack(2).file);
        error(id, ['You cannot call the "%1$s" command on a %2$s array, ',...
            'because the %2$s class only supports operations on scalar ',...
            '%2$s objects. If you need to apply the "%1$s" command ',...
            'to multiple %2$s objects, use a loop.'], command, type);
        
    % Otherwise, reference object array by name
    else
        varName = inputname(1);
        error(id, ['Variable "%s" is not a scalar %s object. ',...
            'Instead "%s" is a gridMetadata array.'], varName, type, varName);
    end 
end

end