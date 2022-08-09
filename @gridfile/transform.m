function[transform, parameters] = transform(obj, type, params, sources)
%% gridfile.transform  Transform data loaded from a .grid file.
% ----------
%   [transform, parameters] = <strong>obj.transform</strong>
%   [transform, parameters] = <strong>obj.transform</strong>('default')
%   Return the default transformation for a gridfile.
%
%   [sourceTransform, sourceParameters] = <strong>obj.transform</strong>('sources')
%   [sourceTransform, sourceParameters] = <strong>obj.transform</strong>('sources', s)
%   [sourceTransform, sourceParameters] = <strong>obj.transform</strong>('sources', sourceNames)
%   Returns the transformations for the specified data sources. If no
%   soures are specified, returns the transformation for all data sources
%   in the gridfile.
%
%   <strong>obj.transform</strong>(type, params)
%   Applies a data transformation to data loaded from a .grid file. The
%   transformation is applied to all data sources in currently in the .grid
%   file, as well as any data sources added in the future. Only one
%   transformation is supported at a time, so calling this method will
%   override any previously specified transformations. See below for
%   details of different transformations
%
%   <strong>obj.transform</strong>(type, params, s)
%   <strong>obj.transform</strong>(type, params, sources)
%   Applies a transformation to data loaded from the specified data
%   Overrides any data transformations previously applied to the data
%   sources.
%
%   <strong>obj.transform</strong>('log')
%   <strong>obj.transform</strong>('ln')
%   <strong>obj.transform</strong>('ln', [], ...)
%   Take the natural logarithm of loaded data.
%
%   <strong>obj.transform</strong>('log10')
%   <strong>obj.transform</strong>('log10', [])
%   Takes the base-10 logarithm of loaded data
%
%   <strong>obj.transform</strong>('exp')
%   <strong>obj.transform</strong>('exp', [], ...)
%   Takes the exponential of loaded data.
%
%   <strong>obj.transform</strong>('power', power, ...)
%   Raise loaded data to the specified power.
%
%   <strong>obj.transform</strong>('plus', plus, ...)
%   <strong>obj.transform</strong>('add', plus, ...)
%   <strong>obj.transform</strong>('+', plus, ...)
%   Add the indicated value to loaded data.
%
%   <strong>obj.transform</strong>('times', times, ...)
%   <strong>obj.transform</strong>('multiply', times, ...)
%   <strong>obj.transform</strong>('*', times, ...)
%   Multiply loaded data by the specified value.
%
%   <strong>obj.transform</strong>('linear', coeffs, ...)
%   Apply a linear transformation to loaded data.
%
%   <strong>obj.transform</strong>('none', ...)
%   <strong>obj.transform</strong>('none', [], ...)
%   Do not apply a transformation to loaded data.
% ----------
%   Inputs:
%       type (string scalar): The type of transformation to apply to the data.
%           Options are as follows:
%           ['ln' | 'log']: Natural logarithm
%           ['log10']: Base-10 logarithm
%           ['exp']: Exponential e^x
%           ['power']: Raise data to power
%           ['plus' | 'add' | '+']: Add value to data
%           ['times' | 'multiply' | '*']: Multiply data by value
%           ['linear']: Linear transformation
%           ['none']: No data transformation
%       params (numeric scalar | numeric vector | []): The parameters for
%           the transformation. Use an empty array when applying transformation
%           with no parameters (e.g. ln, log, log10, exp, or none) to
%           specific data sources. See the entries on the "power", "plus",
%           "times", and "coeffs" inputs for more details.
%       power (numeric scalar): The exponent that should be applied to data
%       plus (numeric scalar): A value that should be added to data
%       times (numeric scalar): A value that data should be multiplied by
%       coeffs (numeric vector [2]): Coefficients for a linear
%           transformation. The first element is the multiplicative
%           constant, and the second element is the additive constant.
%           Linear transformations are applied via: 
%           Y = coeffs(1) + coeffs(2) * X
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be receive the transformation.
%       sourceName (string vector): The names of the data sources that
%           should receive the transformation. Names may either be just file
%           names, or the full file path / opendap url to the source.
%
%   Outputs:
%       transform (string scalar): The default transformation for the gridfile
%       parameters (numeric row vector [2]): Parameters for the default transformation
%       sourceTransform (string vector [nSource]): The transformations for the
%           specified data sources
%       sourceParameters (numeric matrix [nSource, 2]): Parameters for the
%           data source transformations
%
% <a href="matlab:dash.doc('gridfile.transform')">Documentation Page</a>

% Setup
header = "DASH:gridfile:transform";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

%% Return transformations

% Default
if ~exist('type','var') || strcmpi(type, 'default')
    if exist('params','var')
        dash.error.tooManyInputs;
    end
    transform = obj.transform_;
    parameters = obj.transform_params;
    return
    
% Source transformations
elseif strcmpi(type, 'sources')
    if exist('sources','var')
        dash.error.tooManyInputs;
    end
    if ~exist('params','var')
        s = 1:obj.nSource;
    else
        sources = params;
        s = obj.sources_.indices(sources, header);
    end
    transform = obj.sources_.transform(s);
    parameters = obj.sources_.transform_params(s,:);
    return
end

%% Set transformation

% No outputs allowed
if nargout~=0
    dash.error.tooManyOutputs;
end

% Error check the transformation type
type = dash.assert.strflag(type, 'First input (transformation type)', header);
type = lower(type);
validTypes = ["ln","log","log10","exp","power","plus","add","+",...
              "times","multiply","*","linear","none"];
dash.assert.strsInList(type, validTypes, 'The first input',...
    'recognized transformation type', header);

% Error check and parse parameters
id = sprintf('%s:invalidParameter', header);
if ismember(type, ["ln","log","log10","exp","none"])
    assert( ~exist('params','var') || isempty(params), id,...
        ['The "%s" transformation should not have parameters. Use an empty ',...
        'array as the second input to apply "%s" to specific data sources.'], ...
        type, type);
    params = [NaN NaN];
elseif ~exist('params','var')
    error(id, ['You must provide parameters for the "%s" transformation.\n\n',...
        'gridfile: %s'], type, obj.file);
elseif ismember(type, ["power","plus","add","+","times","multiply","*"])
    dash.assert.scalarType(params, 'numeric', type, header);
    params = [params, NaN];
elseif strcmp(type, 'linear')
    dash.assert.vectorTypeN(params, 'numeric', 2, 'coeffs', header);
end

% Set transformation for .grid file and data sources
if exist('sources','var')
    s = obj.sources_.indices(sources, header);
else
    obj.transform_ = type;
    obj.transform_params = params;
    s = 1:obj.nSource;
end
obj.sources_.transform(s) = type;
obj.sources_.transform_params(s,:) = repmat(params, numel(s), 1);

% Save
obj.save;

end