function[obj] = edit(obj, varargin)
%% gridMetadata.edit  Edit the metadata for a gridded dataset
% ----------
%   obj = obj.edit(dimension1, metadata1, dimension2, metadata2, .., dimensionN, metadataN)
%   Replace the metadata for the named dimensions with the specified values
%
%   obj = obj.edit(..., 'attributes', attributes)
%   Replace the non-dimensional attributes with the specified values
% ----------
%   Inputs:
%       dimensionN (string scalar): The name of a dimension of a gridded dataset.
%           Must be a recognized grid dimension. 
%           (See gridMetadata.dimensions for a list of available dimensions)
%       metadataN (matrix, numeric | logical | char | string | cellstring | datetime): 
%           The metadata for the dimension. Cannot have NaN or NaT elements.
%           All rows must be unique.
%       attributes (scalar struct): Non-dimensional metadata attributes for
%           a gridded dataset. May contain any fields or contents useful
%           for the user.
%
%   Outputs:
%       obj (gridMetadata object): The updated gridMetadata object.
%
% <a href="matlab:dash.doc('gridMetadata.edit')">Documentation Page</a>

% Header for error IDs
header = "DASH:gridMetadata:edit";

% Get the set of recognized dimensions and attributes. Track user input dimensions
[dims, atts] = gridMetadata.dimensions;
recognized = [dims;atts];
nNames = numel(recognized);
isSet = false(nNames,1);

% Require an even number of inputs
nArgs = numel(varargin);
if mod(nArgs, 2)~=0        
    id = sprintf('%s:oddNumberOfInputs', header);
    error(id, 'There must be an even number of inputs. (Inputs should be Name, Value pair arguments)');
end

% Check that the first argument in each pair is a valid dimension name
for v = 1:2:nArgs-1
    inputName = sprintf('Input %.f', v);
    dim = dash.assert.strflag(varargin{v}, inputName, header);
    n = dash.assert.strsInList(dim, recognized, inputName, 'recognized dimension name', header);

    % Prevent duplicates
    if isSet(n)
        id = sprintf('%s:repeatedDimension', header);
        error(id, 'Dimension name "%s" is listed multiple times', dim); 
    end
    isSet(n) = true;
    
    % Require valid dimensional metadata. Warn about row vectors
    metadata = varargin{v+1};
    if n < numel(recognized)
        metadata = gridMetadata.assertField(metadata, dim, header);
        if isrow(metadata) && ~isscalar(metadata)
            id = sprintf('%s:metadataFieldIsRow', header);
            warning(id, ['The %s metadata is a row vector and will be used for ',...
                'a single element along the dimension'], dim);
        end

    % Require valid non-dimensional attributes.
    else
        dash.assert.scalarType(metadata, 'struct', 'attributes', header);
    end

    % Update object
    obj.(dim) = metadata;
end

end