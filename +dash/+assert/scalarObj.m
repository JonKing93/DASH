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

% If scalar, exit
if isscalar(obj)
    return
end

% Empty vs array
if isempty(obj)
    id = sprintf('%s:emptyObjectNotSupported', header);
    empty = 'empty ';
else
    id = sprintf('%s:objectArrayNotSupported', header);
    empty = '';
end

% Get stack and class info
try
    stack = dbstack('-completenames');
    type = class(obj);
    
    % When called from console, reference variable by name
    if numel(stack)==1
        varName = inputname(1);
        if strcmp(varName, "")
            var1 = 'Input';
            var2 = 'input';
        else
            var1 = sprintf('Variable "%s"', varName);
            var2 = sprintf('"%s"', varName);
        end
        error(id, ['%s is not a scalar %s object. ',...
            'Instead, %s is a %s%s array.'], var1, type, var2, empty, type);
    
    % Otherwise, report the command name.
    else
        name = stack(2).name;
        name = string(split(name, '.'));
        command = name(end);
    
        % Add suggestion if not empty
        suggestion = '';
        if ~isempty(obj)
            suggestion = sprintf([' If you need to apply the "%s" command to ',...
                'multiple %s objects, use a loop.'], command, type);
        end
    
        % Report error
        error(id, ['You cannot call the "%s" command on a %s%s array, because ',...
            'the %s class only supports this command for scalar %s objects.%s'],...
            command, empty, type, type, type, suggestion);
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end