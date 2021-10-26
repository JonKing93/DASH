function[meta] = assertField(meta, dim, idHeader)
%% dash.metadata.assertField  Throw error if input is not a valid metadata field
% ----------
%   meta = dash.metadata.assertField(meta, dim, idHeader)  
%   Checks if meta is a valid metadata field. If not, throws an error with
%   custom message and identifier. If so and the metadata is cellstring, 
%   returns the  metadata as a string matrix.
%
%   Valid metadata fields matrices, have no duplicate rows, and are one
%   of the following data type: numeric, logical, char, string, cellstring,
%   or datetime.
% ----------
%   Inputs:
%       meta: The metadata input being tested
%       dim (string scalar): The name of the dimension associated with the
%           metadata
%       idHeader (string scalar): Header for thrown error IDs
%
%   Outputs:
%       meta: The metadata field. If the input value was a cellstring data
%           type, converts it to a string data type.
%
%   Throws:
%       <idHeader>:unallowedMetadataType  if meta is not a numeric,
%           logical, char, string, cellstring, or datetime data type
%       <idHeader>:metadataNotMatrix  if meta is not a matrix
%       <idHeader>:metadataHasNaN  if meta contains NaN elements
%       <idHeader>:metadatahasNaT if meta contains NaT elements
%       <idHeader>:metadataHasDuplicateRows  if meta has duplicate rows
%
%   <a href="matlab:dash.doc('dash.metadata.assertField')">Documentation Page</a>

% Type
if ~isnumeric(meta) && ~islogical(meta) && ~ischar(meta) && ...
        ~isstring(meta) && ~iscellstr(meta) && ~isdatetime(meta)
    
    id = sprintf('%s:unallowedMetadataType', idHeader);
    allowed = ["numeric","logical","char","string","cellstring","datetime"];
    error(id, 'The "%s" metadata must be one of the following data types: %s',...
        dim, dash.string.list(allowed, "or"));
    
% Matrix
elseif ~ismatrix(meta)
    id = sprintf('%s:metadataNotMatrix', idHeader);
    error(id, 'The "%s" metadata is not a matrix', dim);
    
% Illegal elements
elseif isnumeric(meta) && any(isnan(meta(:)))
    id = sprintf('%s:metadataHasNaN', idHeader);
    error(id, 'The "%s" metadata contains NaN elements.', dim);
elseif isdatetime(meta) && any(isnat(meta(:)))
    id = sprintf('%s:metadataHasNaT', idHeader);
    error(id, 'The "%s" metadata contains NaT elements.', dim);
end

% Convert cellstring to string
if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end

% Duplicate rows
if dash.metadata.hasDuplicateRows(meta)
    id = sprintf('%s:metadataHasDuplicateRows', idHeader);
    error(id, 'The "%s" metadata contains duplicate rows', dim);
end

end