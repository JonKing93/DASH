function[gridInfo, sourceInfo] = info(obj, sources)
%% Returns information about a .grid file and its contents.
%
% obj.info
% Prints information about the .grid file to console
%
% obj.info(s)
% Prints information about specified data sources in the .grid file.
%
% obj.info('all')
% Prints information about all data sources in the .grid file.
%
% obj.info(filenames)
% Prints information about data sources in the .grid file that are
% associated with the specified file names.
%
% [gridInfo, sourceInfo] = obj.info( ... )
% Returns .grid file information as a structure, and specified data source
% information as a structure array. Does not print to console.
%
% ----- Inputs -----
%
% s: A vector of linear indices. Cannot exceed the number of data sources
%    managed by the .grid file.
%
% filenames: A list of data source filenames. A string vector or cellstring
%    vector. Must include the file extension. Ignores the file path.
% 
% ----- Outputs -----
%
% gridInfo: A structure containing information about the .grid file.
%
% sourceInfo: A structure array containing information on the queried data
%    sources in the .grid file.

% Default for unset sources
if ~exist('sources','var') || isempty(sources)
    sources = [];
end

% Error check sources and get linear indices
nSource = size(obj.fieldLength,1);
if isequal(sources, 'all')
    index = 1:nSource;
        
% If filenames, check that all files are recognized
elseif dash.isstrlist(sources)
    files = string(sources);
    nFile = numel(files);
    index = [];
    for f = 1:nFile
        match = obj.findFileSources(files(f));
        if ~any(match)
            error('There are no data source files named %s in .grid file %s.', files(f), obj.file);
        end
        index = unique([index, find(match)]);
    end
        
% If numeric, check for postive integers no higher than nSource
elseif isnumeric(sources)
    dash.assertPositiveIntegers(sources, "s");
    if any(sources>nSource)
        error('The largest element in s (%.f) is greater than the number of data sources in the .grid file (%.f)', max(sources), nSource);
    end
    index = sources;
        
% Anything else throw error
else
    error('The first input may be ''all'', a list of file names, or a set of linear indices.');
end

% Update the object in case the file changed
obj.update;
        
% .grid file information
nDim = sum(obj.isdefined);
dims = obj.dims(obj.isdefined);
siz = obj.size(obj.isdefined);
meta = rmfield(obj.meta, obj.dims(~obj.isdefined));

% Grid output structure
if nargout~=0
    gridInfo = struct('filename', obj.file, 'nDims', nDim, 'dimensions', dims, 'size', siz, 'metadata', meta,'nSource', nSource);

% Grid print to console
else
    fprintf('\nThe file %s is a .grid file.\n', obj.file);
    fprintf('The file manages %.f data sources.\n', nSource);    
    fprintf('It has %.f dimensions with defined metadata.\n', nDim);
    displayDims(dims, siz, obj.meta);
    fprintf('\n');
end

% Preallocate source structure
nSource = numel(index);
sourceFields = {"file","variable","dimensions","size","metadata","fillValue","validRange","linearTransformation"};
pre = repmat( {[]}, [1, numel(sourceFields)*2]);
pre(1:2:end) = sourceFields;
sourceInfo = repmat(struct(pre{:}), [nSource, 1]);

% Source information
sources = obj.buildSources(index);
for s = 1:numel(sources)
    singleton = ~ismember(dims, sources{s}.mergedDims);
    sourceDims = [sources{s}.mergedDims, dims(singleton)];
    sourceSize = [sources{s}.mergedSize, ones(1,(numel(singleton)))];
    for d = 1:nDim
        k = find(strcmp(dims(d), obj.dims));
        limit = obj.dimLimit(k,1,index(s)) : obj.dimLimit(k,2,index(s));
        sourceMeta.(dims(d)) = obj.meta.(dims(d))(limit,:);
    end
    
    % Source output structure
    if nargout~=0
        input = pre;
        input(2:2:end) = {sources{s}.file, sources{s}.var, sourceDims, sourceSize, ...
            sourceMeta, sources{s}.fill, sources{s}.range, sources{s}.convert};
        sourceInfo(s) = struct(input{:});
        
    % Print source to console
    else
        [~, name, ext] = fileparts(sources{s}.file);
        fprintf('The variable %s in file %s is a data source.\n', sources{s}.var, strcat(name, ext));
        if ~isnan(sources{s}.fill)
            fprintf('The fill value is %s.\n', num2str(sources{s}.fill));
        end
        if ~isequal(sources{s}.range, [-Inf, Inf])
            fprintf('The valid range is %s to %s.\n', num2str(sources{s}.range(1)), num2str(sources{s}.range(2)));
        end
        if ~isequal(sources{s}.convert, [1 0])
            fprintf('The data will be linearly transformed via: Y = %s * X + %s\n', num2str(sources{s}.convert(1)), num2str(sources{s}.convert(2)) );
        end
        dimStr = sprintf('%s x ', sourceDims);
        fprintf('%s is (%s\b\b\b).\n', sources{s}.var, dimStr);
        displayDims(sourceDims, sourceSize, sourceMeta);
        fprintf('\n');
    end
end

end

function[] = displayDims(dims, siz, metadata)
nDim = numel(dims);

for d = 1:nDim
    meta = metadata.(dims(d));
    metaStr = sprintf('.\n');
    if size(meta,2)==1
        if isnumeric(meta) || islogical(meta)
            strfun = @num2str;
        elseif ischar(meta) || isstring(meta) || iscellstr(meta)
            strfun = @string;
        elseif isdatetime(meta)
            strfun = @datestr;
        end
        if siz(d)==1
            metaStr = sprintf(', and its metadata is: %s.\n', strfun(meta));
        else
            metaStr = sprintf(', and its metadata spans: %s to %s.\n', strfun(meta(1)), strfun(meta(end)) );
        end
    end
    fprintf('     The %s dimension has a length of %.f%s', dims(d), siz(d), metaStr);
end

end