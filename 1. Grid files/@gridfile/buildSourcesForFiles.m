function[sources] = buildSourcesForFiles(obj, s, filenames)

% Get the primitive values needed to build dataSource objects
[type, var, dims, fill, range, convert] = ...
    obj.collectPrimitives(["type","var","unmergedDims","fill","range","convert"], s);

% Preallocate
nSource = numel(s);
sources = cell(nSource,1);

% Convert comma delimited dims to a string
for s = 1:nSource
    unmerge = textscan(char(dims(s)), '%s', 'Delimiter', ',');
    unmerge = string( unmerge{:}');    
    
    % Build the data source
    sources{s} = dataSource.new( type(s), filenames(s), var(s), unmerge, ...
                                 fill{s}, range{s}, convert{s} );
end

end