function[obj] = total(obj, variables, dimensions, indices, nanflag)
%% stateVector.total  Take the sum total over dimensions of variables in a state vector
% ----------
%   obj = <strong>obj.total</strong>(-1, ...)
%   obj = <strong>obj.total</strong>(v, ...)
%   obj = <strong>obj.total</strong>(variableNames, ...)
%   Updates the settings for totals for the listed variables. If the first
%   input is -1, applies the settings to all variables currently in the state
%   vector.
%
%   obj = <strong>obj.total</strong>(variables, stateDimension)
%   Takes the sum total over the indicated state dimension. The total is taken over
%   all elements of the dimension that are included in the state vector
%   (i.e. over all state indices for the dimension).
%
%   obj = <strong>obj.total</strong>(variables, ensembleDimension, indices)
%   Takes a sum total over the indicated ensemble dimension. The total is
%   implemented using the specified total indices. The total for the
%   dimension is calculated over elements located by applying the total
%   indices to particular elements along the dimension. If the dimension
%   does not have a sequence, the total indices are applied to the reference
%   element. If the dimension has a sequence, applies the total indices to
%   each individual sequence element.
%
%   obj = <strong>obj.total</strong>(variables, dimensions, indices)
%   Takes the sum total over multiple dimesions. If every listed dimension is a
%   state dimension, you do not need to provide the third input (the total indices).
%   Specify total indices if the dimensions list contains any ensemble dimensions.
%   Use an empty array for the indices of any state dimensions.
%
%   obj = <strong>obj.total</strong>(..., omitnan)
%   obj = <strong>obj.total</strong>(..., true|"omitnan")
%   obj = <strong>obj.total</strong>(..., false|"includenan")
%   Specify how to treat NaN elements along each dimension. Default is to
%   include NaN values.
%
%   obj = <strong>obj.total</strong>(variables, dimensions, "none")
%   Discards any previously-specified options for taking a total for the
%   listed dimensions. No total will be taken over the dimensions when
%   building state vector ensembles.
%
%   obj = <strong>obj.total</strong>(variables, dimensions, "unweighted")
%   Discards any previously-specified weights for use in a weighted total
%   for the listed dimensions. The state vector will still take a total over
%   the listed dimensions, but the total will be unweighted. This option is
%   only valid for dimensions that take either a total or a weighted total.
%   The dimensions list should not include dimensions that do not take a
%   total at all.
% ----------
%   Inputs:
%       v (logical vector | linear indices | -1): The indices of variables in
%           the state vector over which to take a sum total. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices. If linear indices, may not contain repeated
%           indices. If -1, selects every variable in the state vector.
%       variableNames (string vector): The names of variables in the state
%           vector over which to take a total. May not contain
%           repeated variable names.
%       dimensions (string vector [nDimensions]): The names of the dimensions
%           over which to take a total. Cannot have repeated dimension names.
%       indices (cell vector [nDimensions] {[] | total indices}): Total
%           indices for ensemble dimensions. A cell vector with one element
%           per listed dimension. Each element should hold either an empty array
%           (if the dimension is a state dimension), or a vector of total
%           indices (if the dimension is an ensemble dimension). Total
%           indices are 0-indexed from the reference elements of each
%           ensemble member.
%
%           The total indices show how to locate elements used in a sum total
%           over an ensemble dimension. If the dimension does not use a
%           sequence, the total indices are added to the reference element
%           of each ensemble member. The total is then taken over the
%           resulting data elements. If the dimension uses a sequence, a
%           total will be taken over each sequence element. First, sequence
%           indices are added to the reference element to give a set of
%           sequence elements. Then, the total indices are added to each
%           sequence element and a total is taken over *each set* of resulting
%           data elements.
%
%           If a single dimension is listed, and the dimension is a state
%           dimension, you do not need to provide total indices as an input.
%           If the single dimension is an ensemble dimension, you may
%           provide the total indices directly as a vector, rather than in a
%           scalar cell. However, the scalar cell syntax is also permitted.
%       omitnan (logical | string, scalar | vector [nDimensions]):
%           Indicates how to treat NaN elements when taking totals. If a
%           scalar, applies the same setting to all listed dimensions. Use
%           a vector with one element per listed dimension to specify
%           different settings for the different dimensions.
%           [true|"omitnan"]: Omit NaN values when taking totals
%           [false|"includenan" (default)]: Include NaN values in totals.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector updated with the
%           specified dimensional totals.
%
% <a href="matlab:dash.doc('stateVector.total')">Documentation Page</a>

% Setup
header = "DASH:stateVector:total";
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
method = 'total';
inputs = {indices, omitnan, header};
task = 'take a sum total over';
obj = obj.editVariables(v, d, method, inputs, task);
obj = obj.updateLengths(v);

end