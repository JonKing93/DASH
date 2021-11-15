function[indices] = indices(indices, length, name, logicalLengthName, linearMaxName, header)
%% dash.assert.indices  Throw error if inputs are neither logical indices nor linear indices
% ----------
%   indices = dash.assert.indices(indices, length)
%   Checks if input is a valid vector of logical indices or linear indices
%   for an array dimension. To be valid, logical indices must match the
%   length of the array dimension, and linear indices must be positive
%   integers that do not exceed the length of the dimension. If these
%   criteria are not met, throws an error message. If so, returns the
%   input as linear indices.
%
%   indices = dash.assert.indices(indices, length, name, logicalLengthName, linearMaxName, header)
%   Customize the error message and error ID.
% ----------
%   Inputs:
%       indices: The input being tested.
%       length (scalar positive integer): The length of the array dimension
%           that the indices are for. Logical indices must be a vector of
%           this length, and linear indices cannot exceed this length.
%       name (string scalar): A name to use for the input in error messages
%           Default is "input".
%       logicalLengthName (string scalar): A name to use for the length of
%           logical index vectors in error messages. Default is 
%           "the length of the dimension"
%       linearMaxName (string scalar | []): A name to use for the
%           maximum linear index. If an empty array, uses the same value as
%           logicalLengthName. Default is an empty array.
%       header (string scalar): Header for error IDs. Default is
%           "DASH:assert:indices"
%
%   Outputs:
%       indices (vector, linear indices): The input as linear indices.
%
% <a href="matlab:dash.doc('dash.assert.indices')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('logicalLengthName','var') || isempty(logicalLengthName)
    logicalLengthName = "the length of the dimension";
end
if ~exist('linearMaxName','var') || isempty(linearMaxName)
    linearMaxName = logicalLengthName;
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:indices";
end

% Allow empty indexing
if isequal(indices, [])
    return;
end

% Vector
dash.assert.vectorTypeN(indices, [], [], name, header);

% Logical indices
if islogical(indices)
    if numel(indices)~=length
        id = sprintf('%s:logicalIndicesWrongLength', header);
        error(id, ['%s is a logical vector, so it must have %s (%.f), but it has ',...
            '%.f elements instead.'], name, logicalLengthName, length, numel(indices));
    end
    indices = find(indices);
        
% Numeric indices
elseif isnumeric(indices)
    if ~dash.is.positiveIntegers(indices)
        id = sprintf('%s:invalidLinearIndices', header);
        bad = find(indices<1 | mod(indices,1)~=0, 1);
        error(id, ['%s is a numeric vector, so it must consist of linear ',...
            'indices (positive integers). However, element %.f is not a ',...
            'positive integer.'], name, bad);
    end
    
    [maxIndex, loc] = max(indices);
    if maxIndex > length
        id = sprintf('%s:linearIndicesTooLarge', header);
        error(id, 'Element %.f of %s (%.f) is greater than %s (%.f).',...
            loc, name, maxIndex, linearMaxName, length);
    end
   
% Anything else
else
    id = sprintf('%s:inputNotIndices', header);
    error(id, ['%s must either be a vector of logical indices, or a vector ',...
        'of linear indices'], name);
end

end