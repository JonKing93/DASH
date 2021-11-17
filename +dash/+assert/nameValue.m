function[names, values] = nameValue(inputs, nPrevious, extraInfo, header)
%% dash.assert.nameValue  Throw error if inputs are not Name,Value pairs
% ----------
%   [names, values] = dash.assert.nameValue(inputs)
%   Checks if the contents of a cell vector are Name,Value pairs. If not,
%   throws an error. If so, returns the names as a string vector, and the
%   values as a cell vector.
%
%   [names, values] = dash.assert.nameValue(inputs, nPrevious, extraInfo, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       inputs (cell vector): Typically varargin from a calling function
%       nPrevious (scalar positive integer): The number of inputs before
%           varargin. Should exclude object reference in class methods.
%       extraInfo (string scalar): Extra information about the Name,Value
%           input pairs.
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       names (string vector [nPairs]): The ordered list of names in the
%           Name,Value pairs
%       values (cell vector [nPairs]): The ordered list of values for the
%           Name,Value pairs
%
% <a href="matlab:dash.doc('dash.assert.nameValue')">Documentation Page</a>

% Defaults
if ~exist('nPrevious','var') || isempty(nPrevious)
    nPrevious = 0;
end
if ~exist('extraInfo','var') || isempty(extraInfo)
    extraInfo = '';
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:nameValue";
end

% Throw error if there are an odd number of inputs
if mod(numel(inputs),2)~=0
    id = sprintf('%s:oddNumberOfInputs', header);
    countInfo = '';
    if nPrevious>0
        countInfo = sprintf(' after the first %.f inputs', nPrevious);
    end
    if ~strlength(extraInfo)==0
        extraInfo = sprintf(' (%s)', extraInfo);
    end
    error(id, 'You must provide an even number of inputs%s.%s', countInfo, extraInfo);
end

% Get the names and values
names = dash.parse.vararginFlags(inputs, 2, nPrevious, header);
values = inputs(2:2:end);

end