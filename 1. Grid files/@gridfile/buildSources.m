function[sources] = buildSources(obj, s)
%% Builds the specified sources in a .grid file.
%
% sources = obj.buildSources(s)
%
% ----- Inputs -----
%
% s: The linear index of the requested sources in the .grid file.
%
% ----- Outputs -----
%
% sources: A cell vector of dataSource objects.

% Get the primitive values needed to rebuild the dataSource objects
[type, file, var, dims, fill, range, convert] = ...
    obj.collectPrimitives(["type","file","var","unmergedDims","fill","range","convert"], s);

% Preallocate
nSource = numel(s);
sources = cell(nSource,1);

% Convert comma delimited dims to a string
for s = 1:nSource
    unmerge = textscan(char(dims(s)), '%s', 'Delimiter', ',');
    unmerge = string( unmerge{:}');    
    
    % Build the data source
    sources{s} = dataSource.new( type(s), file(s), var(s), unmerge, ...
                                 fill{s}, range{s}, convert{s} );
end

end


