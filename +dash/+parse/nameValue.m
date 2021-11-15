function[varargout] = nameValue(inputs, flags, defaults, nPrevious, header)
%% dash.parse.nameValue  Parse flagged options from Name,Value pairs
% ----------
%   values = dash.parse.nameValue(inputs, flags, defaults)
%   Parses a set of flagged options given Name,Value input pairs. If a flag
%   is not provided, returns a specified default argument for the flag.
%   Throws an error if any inputs are not Flag,Value pairs, or if any flags
%   are repeated.
%
%   values = dash.parse.nameValue(inputs, flags, defaults, nPrevious, header)
%   Customize error messages an IDs.
% ----------
%   Inputs:
%       inputs (cell vector): A collection of name-value pairs. Usually
%           varargin from a calling function
%       flags (string vector [nFlags]): The list of recognized option flags
%       defaults (cell vector [nFlags]): The default value for each flag
%       nPrevious (scalar positive integer): The number of inputs before
%           varargin in the calling function
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       values (cell vector [nFlags]): The parsed value for each flag
%
% <a href="matlab:dash.doc('dash.parse.nameValue')">Documentation Page</a>

% Defaults
if ~exist('nPrevious','var') || isempty(nPrevious)
    nPrevious = 0;
end
if ~exist('header','var') || isempty(header)
    header = 'DASH:parse:nameValue';
end

%% Developer error checking
% It's easy to lose track of flags/defaults when there are many options for
% a function. It's also hard to debug functions when inputs are not
% passed correctly to this parser.
%
% So, even though this is a low-level function, error check the inputs to
% make sure the developer passed everything correctly.

% Inputs: cell vector (varargin)
dash.assert.vectorTypeN(inputs, 'cell', [], 'inputs', header);

% Flags: Non-duplicate (case-insensitive) string list
flags = dash.assert.strlist(flags, "flags", header);
lower(flags);
dash.assert.uniqueSet(flags, 'Flag', header);

% Defaults: cell vector with one element per flag
nFlags = numel(flags);
dash.assert.vectorTypeN(defaults, "cell", nFlags, 'defaults', header);


%% Implement the parser

% Initialize the output. Only continue if there are inputs
varargout = defaults;
if numel(inputs)==0
    return
end

% Parse the names and values
extraInfo = 'Inputs must be Name,Value pairs';
[names, values] = dash.assert.nameValue(inputs, nPrevious, extraInfo, header);

% Require names to be recognized options (case-insensitive) with no duplicates
names = lower(names);     % Note that flags were lower cased in developer error check
k = dash.assert.strsInList(names, flags, 'Option name', 'recognized option', header);
dash.assert.uniqueSet(names, 'Option name', header);

% Record the values associated with the flags
varargout(k) = values;

end