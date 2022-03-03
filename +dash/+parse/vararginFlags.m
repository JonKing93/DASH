function[flags] = vararginFlags(inputs, spacing, nPrevious, header)
%% dash.parse.vararginFlags  Parse flags from varargin
% ----------
%   flags = dash.parse.vararginFlags(inputs)
%   Parses a cell vector of flags into a string vector. Throws error if any
%   elements are not flags.
%
%   flags = dash.parse.vararginFlags(inputs, spacing)
%   Parses a cell vector of values with flags beginning on the first
%   element, and spaced with a given spacing.
%
%   flags = dash.parse.vararginFlags(inputs, spacing, nPrevious, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       inputs (cell vector): The varargin being parsed
%       spacing (scalar positive integer): The spacing of flags along varargin
%       nPrevious (scalar positive integer): The number of inputs before
%           varargin in the calling function. (Ignoring object reference in
%           class methods.
%       header (string scalar): Header for thrown error IDs.
%
%   Outputs:
%       flags (string vector): The ordered list of flags.
%
% <a href="matlab:dash.doc('dash.parse.vararginFlags')">Documentation Page</a>

% Defaults
if ~exist('header','var') || isempty(header)
    header = 'DASH:parse:vararginFlags';
end
if ~exist('spacing','var') || isempty(spacing)
    spacing = 1;
end
if ~exist('nPrevious','var') || isempty(nPrevious)
    nPrevious = 0;
end

% Isolate the flags
inputs = inputs(1:spacing:end);

% Preallocate
nFlags = numel(inputs);
flags = strings(nFlags, 1);

% Get the index of each flag in the total set of inputs and parse
try
    for f = 1:nFlags
        inputIndex = nPrevious + (f-1)*spacing + 1;
        inputName = sprintf('Input %.f', inputIndex);
        flags(f) = dash.assert.strflag(inputs{f}, inputName, header);
    end

% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

end