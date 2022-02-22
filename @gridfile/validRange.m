function[varargout] = validRange(obj, range, sources)
%% gridfile.validRange  Specify a valid range for data catalogued in a .grid file
% ----------
%   range = <strong>obj.validRange</strong>
%   range = <strong>obj.validRange</strong>('default')
%   Return the default valid range for a gridfile.
%
%   sourceRanges = <strong>obj.validRange</strong>('sources')
%   sourceRanges = <strong>obj.validRange</strong>('sources', s)
%   sourceRanges = <strong>obj.validRange</strong>('sources', sourceNames)
%   Return the valid ranges for the specified data sources. If no data
%   sources are specified, returns the valid range for all data sources in
%   the gridfile.
%
%   <strong>obj.validRange</strong>(range)
%   Specify a valid range for data catalogued in a .grid file. Data outside
%   of the valid range are converted to NaN when loaded. This syntax sets
%   the valid range for all data sources currently in the gridfile, and
%   applies the valid range any data sources added to the .grid file in the
%   future.
%
%   <strong>obj.validRange</strong>(range, s)
%   <strong>obj.validRange</strong>(range, sourceNames)
%   Implements a valid range for the specified data sources. Overrides any
%   valid range values previously applied to the data sources.
% ----------
%   Inputs:
%       range (numeric vector [2]): The valid range. The first element is
%           the lower bound, and the second element is the upper bound.
%           Data values outside this (open) interval are converted to NaN
%           when loaded.
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be assigned the valid range.
%       sourceName (string vector): The names of the data sources that
%           should be assigned a valid range.
%
%   Outputs:
%       range (numeric vector [2]): The default valid range for the gridfile
%       sourceRanges (numeric matrix [nSource, 2]): The valid ranges for
%           the specified data sources
%
% <a href="matlab:dash.doc('gridfile.validRange')">Documentation Page</a>

% Setup
header = "DASH:gridfile:validRange";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

%% Return valid ranges

% Default
if ~exist('range','var') || strcmpi(range, 'default')
    assert(~exist('sources','var'), 'MATLAB:TooManyInputs', 'Too many input arguments.');
    varargout = {obj.range};
    return
    
% Source ranges
elseif strcmpi(range, 'sources')
    if ~exist('sources', 'var')
        s = 1:obj.nSource;
    else
        s = obj.sources_.indices(sources, header);
    end
    varargout = {obj.sources_.range(s,:)};
    return
end

%% Set fill values

% No outputs allowed
assert(nargout==0, 'MATLAB:TooManyOutputs', 'Too many output arguments.');
varargout = {};

% Error check the valid range
dash.assert.vectorTypeN(range, 'numeric', 2, 'range', header);
if range(1) >= range(2)
    id = sprintf('%s:invalidRange', header);
    error(id, 'The first element of range must be smaller than the second element');
end

% Make range a row vector
if iscolumn(range)
    range = range';
end

% Set range for data sources and .grid file
if exist('sources','var')
    s = obj.sources_.indices(sources, header);
else
    obj.range = range;
    s = 1:obj.nSource;
end
obj.sources_.range(s,:) = repmat(range, numel(s), 1);

% Save
obj.save;

end