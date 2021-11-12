function[varargout] = inputs( inputs, flags, defaults, nPrev )
%% dash.parse.inputs  Parses inputs for flag-value input pairs. 
% ----------
%   values = dash.parse.inputs(inputs, flags, defaults)
%   Parses a set of inputs given a set of input string flags. If a flag is
%   not passed to a function, returns a default value. Throw error if
%   inputs are not recognized Name,Value pairs.
%
%   values = dash.parse.inputs(inputs, flags, defaults, 
% ----------
%   Inputs:
%       inputs (cell vector [nInputs]): A set of Name-Value input paris.
%           Usually the varargin vector from the calling function
%       flags (string vector [nFlags]): The strings used to flag options
%           for a function
%       defaults (cell vector [nFlags]): The default value for each flagged
%           option
%       nPrev (scalar positive integer): The number of inputs before
%           varargin in the calling function. Used for error messages
%
%   Outputs:
%       values (cell vector [nFlags]): The parsed value for each flag
%
%   Throws:
%       DASH:parse:inputs:duplicateFlags  if flags contains duplicate
%           elements
%       DASH:parse:inputs:wrongNumberOfDefaults  if the number of default
%           values does not match the number of flags
%       DASH:parse:inputs:oddNumberOfInputs  if the Name-Value inputs
%           contains an odd number of arguments
%       DASH:parse:inputs:flagAlreadySet  if the value for a flag is set
%           more than once
%
%   <a href="matlab:dash.doc('dash.parse.inputs')">Documentation Page</a>

% Error check developer flags and defaults
header = "DASH:parse:inputs";
flags = dash.assert.strlist(flags, "flags", header);
dash.assert.vectorTypeN(defaults, "cell", [], 'defaults', header);

nFlags = numel(flags);
if nFlags > numel(unique(flags))
    id = sprintf('%s:duplicateFlags', header);
    error(id, "flags contains duplicate values");
elseif numel(defaults) ~= nFlags
    id = sprintf('%s:wrongNumberOfDefaults', header);
    error(id, ['The number of elements in defaults (%.f) does not match ',...
        'the number of flags (%.f)'], numel(defaults), nFlags);
end

% Initialize output to default values. Only continue if inputs are provided
varargout = defaults;
if isempty(inputs)
    return
end

% Error check inputs
dash.assert.vectorTypeN(inputs, "cell", [], 'inputs', header);
if mod(numel(inputs),2)~=0
    id = sprintf('%s:oddNumberOfInputs', header);
    error(id, ['You must provide an even number of inputs after the first ',...
        '%.f inputs'], nPrev);
end

% Error check each flag
setValue = false(nFlags, 1);
for k = 1:2:numel(inputs)
    name = sprintf('Input %.f', k+nPrev);
    inputs{k} = dash.assert.strflag(inputs{k}, name, header);
    f = dash.assert.strsInList(inputs{k}, flags, name, 'recognized flag', header);
    
    % Prevent duplicate flags
    if setValue(f)
        id = sprintf('%s:flagAlreadySet', header);
        error(id, 'The "%s" flag is set multiple times', flags(f));
    end
    
    % Set values
    setValue(f) = true;
    varargout{f} = inputs{k+1};
end

end