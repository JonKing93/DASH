function[sources] = review(obj)
%% Error checks a .grid file prior to repeated loads. (The motivation for 
% this method is to remove duplicate error checks during repeated load
% operations.) Returns a cell array of pre-built data sources for
% subsequent repeated load operations.
%
% sources = obj.review
%
% ----- Outputs -----
%
% sources: A vector of empty cells with one element for each data source in
%    the .grid file.

% Pre-build the dataSource objects. This will check that the sources still
% match the values in the .grid file.
nSource = size(obj.fieldLength,1);
sources = obj.buildSources(1:nSource);

% Check that the size of the data in the data source matches its recorded
% size in the .grid file
siz = obj.collectPrimitives( "mergedSize", 1:nSource );
for s = 1:nSource
    if ~isequal( sources{s}.mergedSize, siz{s} )
        errorString = [sprintf('The size of the data in %s (', sources{s}.file), ...
            sprintf('%.f x ', sources{s}.mergedSize), ...
            sprintf('\b\b\b) no longer matches the size recorded in .grid file %s (', obj.file), ...
            sprintf('%.f x ', siz{s}), sprintf('\b\b\b)')];
        error( errorString );        
    end
end

end