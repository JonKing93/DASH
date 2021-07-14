function[source] = new(type, file, var, dims, fill, range, convert)
%% Creates a new dataSource object. dataSource is an abstract
% class, so this method routes to the constructor of the
% appropriate subclass.
%
% source = dataSource.new(type, file, var, dims, fill, range, convert)
%
% ----- Inputs -----
%
% type: The type of data source. A string. 
%    "nc": Use when the data source is a NetCDF file.
%    "mat": Use when the data source is a .mat file.
%    "opendap": Use when the data source is an OPeNDAP NetCDF
%
% file: The name of the data source file. A string. If only the file name is
%    specified, the file must be on the active path. Use the full file name
%    (including path) to add a file off the active path. All file names
%    must include the file extension.
%
% var: The name of the variable in the source file.
%
% dims: The order of the dimensions of the variable in the source file. A
%    string or cellstring vector.
%
% fill: A fill value. Must be a scalar. When data is loaded from the file, 
%    values matching fill are converted to NaN. 
%
% range: A valid range. A two element vector. The first element is the
%    lower bound of the valid range. The second elements is the upper bound
%    of the valid range. When data is loaded from the file, values outside
%    of the range are converted to NaN.
%
% convert: Applies a linear transformation of form: Y = aX + b
%    to loaded data. A two element vector. The first element specifies the
%    multiplicative constant (a). The second element specifieds the
%    additive constant (b).

% Error check type
type = dash.assert.strflag(type, 'type');

% Set defaults for optional values
if ~exist('fill','var') || isempty(fill)
    fill = NaN;
end
if ~exist('range','var') || isempty(range)
    range = [-Inf Inf];
end
if ~exist('convert','var') || isempty(convert)
    convert = [1 0];
end

% Create the concrete dataSource object. This will error check
% and get the size of the raw unmerged data in the source.
if strcmpi(type,'nc')
    source = dash.dataSource.nc(file, 'file', var, dims, fill, range, convert);
elseif strcmpi(type, 'mat')
    source = dash.dataSource.mat(file, var, dims, fill, range, convert);
elseif strcmpi(type, 'opendap')
    source = dash.dataSource.opendap(file, var, dims, fill, range, convert);
else
    error('type must be one of the strings "nc", "mat", or "opendap".');
end

% Check that the subclass constructor set all fields for which
% it is responsible
fields = source.subclassResponsibilities;
for f = 1:numel(fields)
    if isempty( source.(fields(f)) )
        error('The dataSource subclass constructor did not set the "%s" property.', fields(f));
    end
end

% Ensure all non-trailing singleton dimensions are named. Pad
% the unmerged size for any named trailing singletons.
nDims = numel(source.unmergedDims);
minimumDims = max( [1, find(source.unmergedSize~=1,1,'last')] );            
if nDims < minimumDims
    error('The first %.f dimensions of variable %s in file %s require names, but dims only contains %.f elements',minimumDims, var, file, numel(dims) );
elseif numel(source.unmergedSize) < nDims
    source.unmergedSize( end+1:nDims ) = 1;
end

% Get the merge map and merged data size
source.mergedDims = unique(source.unmergedDims, 'stable');
nUniqueDims = numel(source.mergedDims);
source.merge = NaN(1,nDims);
source.mergedSize = NaN(1,nUniqueDims);

for d = 1:nUniqueDims
    isdim = find( strcmp(source.mergedDims(d), source.unmergedDims) );
    source.merge(isdim) = d;
    source.mergedSize(d) = prod( source.unmergedSize(isdim) );
end

end