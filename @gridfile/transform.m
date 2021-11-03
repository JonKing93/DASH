function[] = transform(obj, type, params, sources)
%% gridfile.transform  Transform data loaded from a .grid file.
% ----------
%   obj.transform(type, params)
%   Applies a data transformation to data loaded from a .grid file. The
%   transformation is applied to all data sources in currently in the .grid
%   file, as well as any data sources added in the future. Only one
%   transformation is supported at a time, so calling this method will
%   override any previously specified transformations. See below for
%   details of different transformations
%
%   obj.transform(type, params, s)
%   obj.transform(type, params, sources)
%   Applies a transformation to data loaded from the specified data
%   Overrides any data transformations previously applied to the data
%   sources.
%
%   obj.transform('ln')
%   obj.transform('ln', [], ...)
%   Take the natural logarithm of loaded data.
%
%   obj.transform('log', base, ...)
%   Takes the logarithm of loaded data. Supports base-10 and
%   base-e (natural) logarithms.
%
%   obj.transform('exp')
%   obj.transform('exp', [], ...)
%   Takes the exponential of loaded data.
%
%   obj.transform('power', power, ...)
%   Raise loaded data to the specified power.
%
%   obj.transform('plus', plus, ...)
%   Add the indicated value to loaded data.
%
%   obj.transform('times', times, ...)
%   Multiply loaded data by the specified value.
%
%   obj.transform('linear', coeffs, ...)
%   Apply a linear transformation to loaded data.
%
%   obj.transform('none', ...)
%   obj.transform('none', [], ...)
%   Do not apply a transformation to loaded data.
% ----------
%   Inputs:
%       type ('ln' | 'log' | 'exp' | 'power' | 'plus' | 'times' | 'linear' | 'none'): 
%           The type of data transformation to apply to loaded data.
%       params: The parameters for the transformation. Use an empty array
%           when applying transformation with no parameters (ln, exp, none) to
%           specific data sources.
%       base (10 | 'e'): A logarithm base. 'e' selects the natural logarithm
%       power (numeric scalar): The exponent that should be applied to data
%       plus (numeric scalar): A value that should be added to data
%       times (numeric scalar): A value that data should be multiplied by
%       coeffs (numeric vector [2]): Coefficients for a linear
%           transformation. The first element is the multiplicative
%           constant, and the second element is the additive constant.
%           Linear transformations are applied via: 
%           Y = coeffs(1) * X + coeffs(2)
%
% <a href="matlab:dash.doc('gridfile.transform')">Documentation Page</a>

% Error check the transformation type
header = "DASH:gridfile:transform";
type = dash.assert.strflag(type, 'First input (transformation type)', header);
type = lower(type);
validTypes = ["ln","log","exp","power","plus","times","linear","none"];
dash.assert.strsInList(type, validTypes, 'The first input (transformation type)',...
    'recognized transformation type', header);

% Error check and parse parameters
id = sprintf('%s:invalidParameter', header);
if ismember(type, ["ln","exp","none"])
    assert( ~exist('params','var') || isempty(params), id,...
        ['The "%s" transformation should not have parameters. Use an empty ',...
        'array as the second input to apply "%s" to specific data sources.'], ...
        type, type);
    params = [NaN NaN];
elseif strcmp(type, 'log')
    assert( isscalar(params) && (strcmp(params, 'e') || isequal(params, 10)), ...
        id, 'The log base must either be 10 or ''e''.');
    params = [char(params)+0, NaN];
elseif ismember(type, ["power","plus","times"])
    dash.assert.scalarType(params, 'numeric', type, header);
    params = [params, NaN];
elseif strcmp(type, 'linear')
    dash.assert.vectorTypeN(params, 'numeric', 2, 'coeffs', header);
end

% Get data source indices, set transformation for .grid file
if exist('sources','var')
    s = dash.parse.listOrIndices(sources);
else
    obj.transform_ = type;
    obj.transform_params = params;
end
obj.source_transform(s) = type;
obj.source_transform_params(s,:) = repmat(params, numel(s), 1);

end