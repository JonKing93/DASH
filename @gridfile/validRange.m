function[] = validRange(obj, range, sources)
%% gridfile.validRange  Specify a valid range for data catalogued in a .grid file
% ----------
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
% <a href="matlab:dash.doc('gridfile.validRange')">Documentation Page</a>

% Setup
header = "DASH:gridfile:validRange";
obj.update;

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
    s = obj.sources_.indices(sources, obj.file, header);
else
    obj.range = range;
    s = 1:obj.nSource;
end
obj.sources_.range(s,:) = repmat(range, numel(s), 1);

% Save
obj.save;

end