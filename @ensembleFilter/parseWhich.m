function[whichArg] = parseWhich(obj, whichArg, name, nIndex, indexName, resetTime)
%% Parses which* inputs for evolving settings
%
% whichArg = obj.parseWhich(whichArg, name, nIndex, indexName)
%
% ----- Inputs -----
%
% whichArg: The which* input
%
% name: The name of the which* input in the calling function
%
% nIndex: The indices that can be referenced by whichArg
%
% indexName: The name of the quantity being indexed
%
% resetTime: Scalar logical indicating that whichArg is the only input
%    controlling the number of time steps
%
% ----- Outputs -----
%
% whichArg: The which* input adjusted for any default settings

% Reset time
if resetTime
    obj.nTime = 0;
end

% If unset, nTime is the number of whichArg elements
empty = isempty(whichArg);
if obj.nTime==0 && ~empty
    obj.nTime = numel(whichArg);
elseif obj.nTime==0
    obj.nTime = nIndex;
end

% If empty, nIndex must be 1 or nTime. Leave empty if 1, but set to indices
% if nTime
if empty
    if nIndex==obj.nTime && nIndex~=1
        whichArg = (1:obj.nTime)';
    elseif nIndex~=1
        error(['The number of %ss (%.f) does not match the number of time steps ',...
        '(%.f), so you must use the "%s" input to specify which ',...
        '%s to use in each time step.'], indexName, nIndex, obj.nTime, name, indexName);
    end
    
% Otherwise, error check the indices
else
    dash.assertVectorTypeN(whichArg, 'numeric', obj.nTime, name);
    dash.checkIndices(whichArg, name, nIndex, strcat('the number of %ss', indexName));
end
whichArg = whichArg(:);
    
end