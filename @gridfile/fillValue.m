function[fill] = fillValue(obj, fill, sources)
%% gridfile.fillValue  Specify a fill value for data catalogued in a .grid file
% ----------
%   fill = <strong>obj.fillValue</strong>
%   fill = <strong>obj.fillValue</strong>('default')
%   Return the default fill value for a grid file.
%
%   sourceFills = <strong>obj.fillValue</strong>('sources')
%   sourceFills = <strong>obj.fillValue</strong>('sources', s)
%   sourceFills = <strong>obj.fillValue</strong>('sources', sourceNames)
%   Return the fill values for the specified data sources. If no sources
%   are specified, returns the fill value for all data sources in the
%   gridfile.
%
%   <strong>obj.fillValue</strong>(fill)
%   Set the default fill value for data loaded from a .grid file. Numeric data
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
%   Outputs:
%       fill (numeric scalar): The default fill value for the gridfile
%       sourceFills (numeric vector): The fill values for the specified data sources
%
% <a href="matlab:dash.doc('gridfile.fillValue')">Documentation Page</a>

% Setup
obj.update;
header = "DASH:gridfile:fillValue";

%% Return fill values

% Default fill
if ~exist('fill','var') || strcmpi(fill, 'default')
    assert(~exist('sources','var'), 'MATLAB:TooManyInputs', 'Too many input arguments.');
    fill = obj.fill;
    return
    
% Source fill values
elseif strcmpi(fill, 'sources')
    if ~exist('sources','var')
        s = 1:obj.nSource;
    else
        s = obj.sources_.indices(sources, header);
    end
    fill = obj.sources_.fill(s);
    return
end

%% Set fill values
    
% No outputs allowed
assert(nargout==0, 'MATLAB:TooManyOutputs', 'Too many output arguments.');

% Error check the fill value
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