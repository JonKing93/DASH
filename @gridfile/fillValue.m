function[] = fillValue(obj, fill, sources)
%% gridfile.fillValue  Specify a fill value for data catalogued in a .grid file
% ----------
%   obj.fillValue(fill)
%   Implement a fill value for data loaded from a .grid file. Numeric data
%   matching the fill value are converted to NaN when loading. This syntax
%   sets the fill value for all data sources currently in the .grid file
%   and applies the fill value by default to all data sources added in the
%   future.
%
%   obj.fillValue(fill, s)
%   obj.fillValue(fill, sourceNames)
%   Implements a fill value for the specified data sources. The fill value
%   overrides any fill values previously applied to the data sources.
% ----------
%   Inputs:
%       fill (numeric scalar): The fill value. Data matching the fill value
%           are converted to NaN when loaded from a data source.
%       s (logical vector [nSources] | vector, linear indices): The indices of the data
%           sources that should be assigned a fill value.
%       sourceName (string vector): The names of the data sources that
%           should be assigned a fill value. Names may either be just file
%           names, or the full file path / opendap url to the source.
%
% <a href="matlab:dash.doc('gridfile.fillValue')">Documentation Page</a>

% Error check the fill value
header = "DASH:gridfile:fillValue";
dash.assert.scalarType(fill, 'numeric', 'fill', header);

% Set datasource fills. Optionally set fill for entire gridfile
if exist('sources','var')
    s = obj.sourceIndices(sources);
else
    obj.fill = fill;
    s = 1:numel(obj.source);
end
obj.source_fill(s) = fill;

end