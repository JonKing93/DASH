function[] = assertScalar(obj, header)
%% gridMetadata.assertScalar  Throw error if gridMetadata object is not scalar
% ----------
%   <strong>obj.assertScalar</strong>
%   Throws an error if the calling gridMetadata object is not scalar.
%
%   <strong>obj.assertScalar</strong>(header)
%   Customize thrown error IDs.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
%
% <a href="matlab:dash.doc('gridMetadata.assertScalar')">Documentation Page</a>

% Default
if ~exist('header','var') || isempty(header)
    header = 'DASH:gridMetadata:assertScalar';
end

% Throw error if not scalar
if ~isscalar(obj)
    id = sprintf('%s:objectArrayNotSupported', header);
    stack = dbstack('-completenames');
    
    % Reference command if called in stack
    if numel(stack)>1
        [~, command] = fileparts(stack(2).file);
        error(id, ['You cannot call the "%s" command on a gridMetadata array, ',...
            'because the gridMetadata class only supports operations on scalar ',...
            'gridMetadata objects. If you would like to apply the "%s" command ',...
            'to multiple gridMetadata objects, use a loop.'], command, command);
        
    % Otherwise, reference object array variable name
    else
        varName = inputname(1);
        error(id, ['Variable "%s" is not a scalar gridMetadata object. ',...
            'Instead "%s" is a gridMetadata array.'], varName, varName);
    end
end

end