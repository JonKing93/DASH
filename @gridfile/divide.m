function[] = divide(obj, grid2, filename, varargin)
%% gridfile.divide  Divide the data in the current gridfile by a second gridfile
% ----------
%   <strong>obj.divide</strong>(grid2, filename)
%   Divides the data in the current gridfile by a second gridfile, such that:
%       New data = Current gridfile ./ second gridfile
% 
%   Saves the result to a .mat file and catalogues it in a new .grid file. 
%   The names of the new files are specified by filename. Provide a single 
%   name to use the same name for both files. Provide two names to use
%   different names for each file.
%
%   By default, each data dimension must have either the same length in
%   both gridfiles, or a length of 1 in at least one file. If a dimension
%   is only defined in one gridfile, it is treated as a singleton dimension
%   in the second file. When a dimension is the same length in both files,
%   it must have the same metadata along each dimension. When a dimension
%   has a length of 1 in a gridfile, then the dimension is broadcast across
%   the data in the second gridfile. See the "type" flag for alternate
%   options regarding data size and metadata requirements.
%
%   The new gridfile will have the same dimensional metadata as the original
%   gridfiles. Metadata for broadcast dimensions will match that of the
%   non-broadcast file. If a dimension has a length of 1 in both gridfiles,
%   the metadata will match that of gridfile calling the divide method. By
%   default, the new file will have no metadata attributes (but see the 
%   "attributes" flag for alternate options).
%
%   <strong>obj.divide</strong>(..., 'overwrite', overwrite)
%   Specify whether to overwrite existing .mat and .grid files. If
%   overwrite is scalar, uses the same option for both files. Use two
%   elements to specify the option for each file individually. By default,
%   does not overwrite existing files.
%
%   <strong>obj.divide</strong>(..., 'attributes', attributes)
%   Options for including metadata attributes in the new .grid file. If
%   atts=1, copies the attributes from the current gridfile to the new
%   file. If atts=2, copies the attributes from the second gridfile to the
%   new file. If atts is a scalar struct, uses atts directly as the new
%   metadata attributes.
%
%   <strong>obj.divide</strong>(..., 'type', type)
%   Specify how to implement division for the gridfiles. If case=1 (Default),
%   requires the files to have compatible sizes for division, as well as
%   the same metadata along each non-singleton dimension. If case=2, the
%   files are not required to have compatible sizes. Instead, division only
%   proceeds on data elements with the same metadata. If case=3, division
%   proceeds directly on the file's data, without metadata requirements. 
%   The two gridfiles are again required to have compatible sizes. The
%   dimensional metadata of the new gridfile will match that of the current
%   gridfile except when broadcasting over grid2.
%
%   <strong>obj.divide</strong>(..., 'precision', precision)
%   Specify the numerical precision of the data used for addition. 
%   If 'single' or 'double', uses the specified type. If unset or empty, 
%   uses double unless all loaded data is single by default.
% ----------
%   Inputs:
%       grid2 (string scalar | gridfile object): The gridfile that the
%           current gridfile should be divided by
%       filename (string scalar | string vector[2]): The name to use for the
%           new .mat and .grid files. If a single file name, the name will be
%           used for both files. If two file names, the first name is used for
%           the .mat file, and the second name is used for the .grid file.
%       overwrite (scalar logical | logical vector[2]): Whether to overwrite
%           existing .mat and .grid files. True allows overwriting, false does
%           not. If scalar, uses the same option for both files. If two
%           elements, uses the first option for the .mat file, and the second
%           option for the .grid file. Default is false.
%       attributes (1 | 2 | scalar struct | empty array): Options for
%           setting metadata attributes in the new .grid file. If 1, copies
%           the attributes from the first gridfile to the new file. If 2,
%           copies the attributes from grid2 to the new file. If a scalar
%           struct, uses the struct directly as the attributes. If unset or
%           an empty array, the new file will have no metadata attributes.
%       type (1 | 2 | 3): Options for matching gridfile metadata and sizes.
%           [1 (default)]: requires data dimensions to have compatible sizes
%           AND have the same metadata along each non-singleton dimension.
%           Does arithmetic on all data elements.
%           [2]: Searches for data elements with matching metadata in
%           non-singleton dimensions. Only does arithmetic at these elements.
%           Does not require data dimensions to have compatible sizes.
%           [3]: Does not compare dimensional metadata. Loads all data elements
%           from both files and applies arithmetic directly. Requires data
%           dimensions to have compatible sizes.
%       precision ([] | 'single' | 'double'): The required numerical
%           precision of the data used for division. If 'single' or 'double', 
%           uses the specified type. If an empty array, uses double unless all
%           data used for addition is loaded as single by default.
%
%   Saves:
%       A .mat and .grid file with the specified names
%
%   Throws:
%       DASH:gridfile:divide:invalidGridfile  when grid2 is not a
%           valid gridfile
%       DASH:gridfile:divide:invalidAttributes  when attributes is not
%           a recognized option
%       DASH:gridfile:divide:invalidType  when type is not a
%           recognized option
%       DASH:gridfile:divide:dimensionLengthMismatch  when type is 1
%           or 3 and the data dimensions do not have compatible sizes
%       DASH:gridfile:divide:differentMetadata  when type is 1 and
%           there is different metadata along a non-singleton dimension
%       DASH:gridfile:divide:noMatchingMetadata  when type is 2 and
%           there is no matching metadata along a non-singleton dimension
%
% <a href="matlab:dash.doc('gridfile.divide')">Documentation Page</a>

% Parse optional inputs
[overwrite, atts, type, precision] = dash.parse.nameValue(varargin, ...
    ["overwrite","attributes","type","precision"], {[], [], [], []}, 2);

% Implement gridfile arithmetic
try
    obj.arithmetic('divide', grid2, filename, overwrite, atts, type, precision);
catch ME
    throw(ME);
end

end