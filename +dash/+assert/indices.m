function[indices] = indices(indices, length, name, logicalRequirement, linearMaxName, header)
%% dash.assert.indices  Throw error if inputs are neither logical indices nor linear indices
% ----------
%   indices = dash.assert.indices(indices)
%   Checks if input is a vector of logical or linear indices. If not throws
%   an error message. If so, returns the input as linear indices.
%
%   indices = dash.assert.indices(indices, length)
%   Also requires indices to be compatible with a specified dimension
%   length. To be valid, a vector logical indices must match the length of
%   the array. For linear indices, the values of individual elements cannot
%   exceed the length of the dimension.
%
%   indices = dash.assert.indices(indices, length, name, logicalRequirement, linearMaxName, header)
%   Customize the error message and error ID.
% ----------
%   Inputs:
%       indices: The input being tested.
%       length (scalar positive integer | []): The length of the array dimension
%           that the indices are for. Logical indices must be a vector of
%           this length, and linear indices cannot exceed this length. If
%           an empty array, does not check indices against a dimension length
%       name (string scalar): A name to use for the input in error messages
%           Default is "input".
%       logicalRequirement (string scalar): A name to use for the length 
%           requirement of logical index vectors in error messages. Default
%           is "be the length of the dimension".
%       linearMaxName (string scalar): A name to use for the
%           maximum allowed linear index. Default is "the length of the
%           dimension".
%       header (string scalar): Header for error IDs. Default is
%           "DASH:assert:indices"
%
%   Outputs:
%       indices (vector, linear indices): The input as linear indices.
%
% <a href="matlab:dash.doc('dash.assert.indices')">Documentation Page</a>

% Defaults
if ~exist('length','var') || isempty(length)
    length = [];
end
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('logicalRequirement','var') || isempty(logicalRequirement)
    logicalRequirement = "be the length of the dimension";
end
if ~exist('linearMaxName','var') || isempty(linearMaxName)
    linearMaxName = "the length of the dimension";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:indices";
end

% Allow empty indexing
if isequal(indices, [])
    return;
end

% Linear or numeric vector
dash.assert.vectorTypeN(indices, ["logical","numeric"], [], name, header);

% Logical indices
if islogical(indices)
    if numel(indices)~=length
        id = sprintf('%s:logicalIndicesWrongLength', header);
        ME = MException(id, ['%s is a logical vector, so it must %s (%.f), but it has ',...
            '%.f elements instead.'], name, logicalRequirement, length, numel(indices));
        throwAsCaller(ME);
    end

    % Convert to linear if providing output
    if nargout>0
        indices = find(indices);
    end
        
% Numeric indices
else
    [isvalid, bad] = dash.is.positiveIntegers(indices);
    if ~isvalid
        id = sprintf('%s:invalidLinearIndices', header);
        ME = MException(id, ['%s is a numeric vector, so it must consist of linear ',...
            'indices (positive integers). However, element %.f (%f) is not a ',...
            'positive integer.'], name, bad, indices(bad));
        throwAsCaller(ME);
    end
    
    [maxIndex, loc] = max(indices);
    if maxIndex > length
        id = sprintf('%s:linearIndicesTooLarge', header);
        ME = MException(id, 'Element %.f of %s (%.f) is greater than %s (%.f).',...
            loc, name, maxIndex, linearMaxName, length);
        throwAsCaller(ME);
    end
end

end