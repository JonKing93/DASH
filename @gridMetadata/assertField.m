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

% Convert cellstring to string
if iscellstr(meta) %#ok<ISCLSTR>
    meta = string(meta);
end

% Require a matrix of allowed type
types = ["numeric","logical","char","string","datetime"];
dash.assert.matrixTypeSize(meta, types, [], name, idHeader);

% Do not allow NaN, NaT, or <missing> elements
if (isnumeric(meta) || isdatetime(meta) || isstring(meta)) && any(ismissing(meta),'all')
    bad = find(ismissing(meta), 1);
    if isnumeric(meta)
        type = "NaN";
    elseif isdatetime(meta)
        type = "NaT";
    elseif isstring(meta)
        type = "<missing>";
    end
    id = sprintf('%s:missingMetadata', idHeader);
    error(id, '%s contains %s elements. (Element %.f is %s)', name, type, bad, type);
end

end