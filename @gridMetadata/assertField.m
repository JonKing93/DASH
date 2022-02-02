function[meta] = assertField(meta, dim, idHeader)
%% gridMetadata.assertField  Throw error if input is not a valid metadata field
% ----------
%   meta = gridMetadata.assertField(meta, dim, idHeader)  
%   Checks if meta is a valid metadata field. If not, throws an error with
%   custom message and identifier. If so and the metadata is cellstring, 
%   returns the metadata as a string matrix.
%
%   Valid metadata fields are matrices of one of the following data type:
%   numeric, logical, char, string, cellstring, or datetime. If numeric,
%   the metadata cannot have NaN values. If datetime, the metadata cannot
%   have NaT values.
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
%   <a href="matlab:dash.doc('dash.metadata.assertField')">Documentation Page</a>

% Defaults
if ~exist('idHeader','var') || isempty(idHeader)
    idHeader = "DASH:gridMetadata:assertField";
end
if ~exist('dim','var') || isempty(dim)
    name = 'The metadata';
else
    name = sprintf('The "%s" metadata', dim);
end

% Type
if ~isnumeric(meta) && ~islogical(meta) && ~ischar(meta) && ...
        ~isstring(meta) && ~iscellstr(meta) && ~isdatetime(meta)
    
    id = sprintf('%s:unallowedMetadataType', idHeader);
    allowed = ["numeric","logical","char","string","cellstring","datetime"];
    error(id, '%s must be one of the following data types: %s',...
        name, dash.string.list(allowed));
    
% Matrix
elseif ~ismatrix(meta)
    id = sprintf('%s:metadataNotMatrix', idHeader);
    error(id, '%s is not a matrix', name);
    
% Illegal elements
elseif isnumeric(meta) && any(isnan(meta),'all')
    bad = find(isnan(meta),1);
    id = sprintf('%s:metadataHasNaN', idHeader);
    error(id, '%s contains NaN elements. (Element %.f is NaN).', name, bad);
elseif isdatetime(meta) && any(isnat(meta),'all')
    bad = find(isnat(meta),1);
    id = sprintf('%s:metadataHasNaT', idHeader);
    error(id, '%s contains NaT elements. (Element %.f is NaT).', name, bad);
end

% Convert cellstring to string
if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end

end