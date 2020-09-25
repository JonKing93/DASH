function[input] = parseLogicalString(input, nDims, logicalName, stringName, allowedStrings, lastTrue, name)
%% Parses inputs that can either be a logical or string. Returns the input
% as a logical. Throws custom error messages.
%
% input = dash.parseLogicalString( ...
%             input, nDims, logicalName, stringName, allowedStrings, lastTrue)
%
% ----- Inputs -----
%
% input: The input being parsed
%
% nDims: The number of input dimensions.
%
% logicalName: The name of a logical input
%
% stringName: The name of a string input
%
% allowedStrings: Options for the string input. Should be organized such
%    that all strings equivalent to a logical true are first.
%
% lastTrue: The index of the last string in allowedStrings equivalent to a
%    logical true.
%
% name: An name for the combined string/logical variables.
%
% ----- Outputs -----
%
% input: The input as a logical

% Default for empty calls
if nDims==0 && isempty(input)
    input = false(0,1);
end

% Logical
if islogical(input)
    if ~isscalar(input)
        dash.assertVectorTypeN(input, [], nDims, sprintf('Since %s is not a scalar, it', logicalName));
    end
    
% Strings
elseif ischar(input) || isstring(input) || iscellstr(input)
    input = string(input);
    if ~isscalar(input)
        dash.assertVectorTypeN(input, [], nDims, sprintf('Since %s is not a string scalar, it', stringName));
    end
    k = dash.checkStrsInList(input, allowedStrings, stringName, 'recognized flag');
    input = k<=lastTrue;
    
% Anything else
else
    error('%s must either be logicals or strings.', name);
end

end