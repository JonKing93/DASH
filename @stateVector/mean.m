function[obj] = mean(obj, variables, dimensions, indices, nanflag)
%% stateVector.mean  Take a mean over dimensions of variables in a state vector
% ----------
%   obj = <strong>obj.mean</strong>(-1, ...)
%   obj = <strong>obj.mean</strong>(v, ...)
%   obj = <strong>obj.mean</strong>(variableNames, ...)
%   Updates the settings for means for the listed variables. If the first
%   input is -1, applies the settings to all variables currently in the state
%   vector.
%
%   obj = <strong>obj.mean</strong>(variables, stateDimension)
%   Takes a mean over the indicated state dimension. The mean is taken over
%   all elements of the dimension that are included in the state vector
%   (i.e. over all state indices for the dimension).
%
%   obj = <strong>obj.mean</strong>(variables, ensembleDimension, indices)
%   Takes a mean over the indicated ensemble dimension. The mean is
%   implemented using the specified mean indices. The mean for the
%   dimension is calculated over elements located by applying the mean
%   indices to particular elements along the dimension. If the dimension
%   does not have a sequence, the mean indices are applied to the reference
%   element. If the dimension has a sequence, applies the mean indices to
%   each individual sequence element.
%
%   obj = <strong>obj.mean</strong>(variables, dimensions, indices)
%   Takes a mean over multiple dimesions. If every listed dimension is a
%   state dimension, you do not need to provide the third input (the mean indices).
%   Specify mean indices if the dimensions list contains any ensemble dimensions.
%   Use an empty array for the indices of any state dimensions.
%
%   obj = <strong>obj.mean</strong>(..., omitnan)
%   obj = <strong>obj.mean</strong>(..., true|"omitnan")
%   obj = <strong>obj.mean</strong>(..., false|"includenan")
%   Specify how to treat NaN elements along each dimension. Default is to
%   include NaN values.
%
%   obj = <strong>obj.mean</strong>(variables, dimensions, "none")
%   Discards any previously-specified options for taking a mean for the
%   listed dimensions. No mean will be taken over the dimensions when
%   building state vector ensembles.
%
%   obj = <strong>obj.mean</strong>(variables, dimensions, "unweighted")
%   Discards any previously-specified weights for use in a weighted mean
%   for the listed dimensions. The state vector will still take a mean over
%   the listed dimensions, but the mean will be unweighted. This option is
%   only valid for dimensions that take either a mean or a weighted mean.
%   The dimensions list should not include dimensions that do not take a
%   mean at all.
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector over which to take a mean. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices. If -1, selects every variable in the state vector.
%       variableNames (string vector): The names of variables in the state
%           vector over which to take a mean. May not contain
%           repeated variable names.
%       dimensions (string vector [nDimensions]): The names of the dimensions
%           over which to take a mean. Cannot have repeated dimension names.
%       indices (cell vector [nDimensions] {[] | mean indices}): Mean
%           indices for ensemble dimensions. A cell vector with one element
%           per listed dimension. Each element should hold either an empty array
%           (if the dimension is a state dimension), or a vector of mean
%           indices (if the dimension is an ensemble dimension). Mean
%           indices are 0-indexed from the reference elements of each
%           ensemble member.
%
%           The mean indices show how to locate elements used in a mean
%           over an ensemble dimension. If the dimension does not use a
%           sequence, the mean indices are added to the reference element
%           of each ensemble member. The mean is then taken over the
%           resulting data elements. If the dimension uses a sequence, a
%           mean will be taken over each sequence element. First, sequence
%           indices are added to the reference element to give a set of
%           sequence elements. Then, the mean indices are added to each
%           sequence element and a mean is taken over *each set* of resulting
%           data elements.
%
%           If a single dimension is listed, and the dimension is a state
%           dimension, you do not need to provide mean indices as an input.
%           If the single dimension is an ensemble dimension, you may
%           provide the mean indices directly as a vector, rather than in a
%           scalar cell. However, the scalar cell syntax is also permitted.
%       omitnan (logical | string, scalar | vector [nDimensions]):
%           Indicates how to treat NaN elements when taking means. If a
%           scalar, applies the same setting to all listed dimensions. Use
%           a vector with one element per listed dimension to specify
%           different settings for the different dimensions.
%           [true|"omitnan"]: Omit NaN values when taking means
%           [false|"includenan" (default)]: Include NaN values in means.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           specified dimensional means.
%
% <a href="matlab:dash.doc('stateVector.mean')">Documentation Page</a>

% Setup
header = "DASH:stateVector:mean";
dash.assert.scalarObj(obj, header);
obj.assertEditable;
obj.assertUnserialized;

% Check variables and dimensions, get indices
v = obj.variableIndices(variables, false, header);
[d, dimensions] = obj.dimensionIndices(v, dimensions, header);
nDims = numel(dimensions);

% Prohibit NaNoptions for string inputs. Get placeholder omitnan
if exist('indices','var') && (isequal(indices,"none") || isequal(indices,"unweighted"))
    if exist('nanflag','var')
        dash.error.tooManyInputs;
    end
    omitnan = [];

% Otherwise, default and error check indices
else
    if ~exist('indices','var') || isempty(indices)
        indices = cell(1, nDims);
    else
        indices = dash.assert.additiveIndexCollection(indices, nDims, dimensions, header);
    end

    % Default and parse nanflag
    if ~exist('nanflag','var') || isempty(nanflag)
        omitnan = false(1, nDims);
    else
        omitnan = dash.parse.switches(nanflag, {"includenan","omitnan"}, nDims, ...
            'NaN option', 'recognized NaN option', header); %#ok<CLARRSTR> 
    end
    if isscalar(omitnan)
        omitnan = repmat(omitnan, [numel(v),1]);
    end
end

% Update the variables
method = 'mean';
inputs = {indices, omitnan, header};
task = 'take a mean over';
obj = obj.editVariables(v, d, method, inputs, task);
obj = obj.updateLengths(v);

end