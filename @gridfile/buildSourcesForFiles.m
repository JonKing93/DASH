function[sources] = buildSourcesForFiles(obj, s, filenames)
%% Builds a set of dataSource objects using values stored in a .grid file, 
% and a specified set of file names
%
% sources = obj.buildSourcesForFiles(s, filenames)
%
% ----- Inputs -----
%
% s: Linear indices for the sources in the .grid file whose values are used
%    to build the new dataSource objects.
%
% filenames: The filenames to use when building the dataSource obejcts. A
%    string vector or celstring vector. Must have one element for each
%    element in s.
%
% ----- Outputs -----
%
% sources: A cell array of dataSource objects.

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
    
    % Build the data source.
    try
        sources{s} = dataSource.new( type(s), filenames(s), var(s), unmerge, ...
                                 fill{s}, range{s}, convert{s} );
                             
    % Provide extra error information if the data source file is missing
    catch ME
        if strcmp(ME.identifier, "DASH:missingFile")
            error('Cannot find data source "%s". It may have been moved, renamed, or deleted. If the file was moved or renamed, see "gridfile.renameSources" to update the data source file path.', filenames(s));
        end
        rethrow(ME);
    end
end

end