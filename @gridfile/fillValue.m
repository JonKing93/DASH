function[] = fillValue(obj, fill, sources)
%% gridfile.fillValue  Specify a fill value for data catalogued in a .grid file
% ----------
%   <strong>obj.fillValue</strong>(fill)
%   Implement a fill value for data loaded from a .grid file. Numeric data
%   matching the fill value are converted to NaN when loading. This syntax
%   sets the fill value for all data sources currently in the .grid file
%   and applies the fill value by default to all data sources added in the
%   future.
%
%   <strong>obj.fillValue</strong>(fill, s)
%   <strong>obj.fillValue</strong>(fill, sourceNames)
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

% Setup
obj.update;
header = "DASH:gridfile:fillValue";

% Error check
dash.assert.scalarType(fill, 'numeric', 'fill', header);

% Set datasource fills. Optionally set fill for entire gridfile
if exist('sources','var')
    s = obj.sources_.indices(sources, obj.file, header);
else
    obj.fill = fill;
    s = 1:obj.nSource;
end
obj.sources_.fill(s) = fill;

% Save
obj.save;

end