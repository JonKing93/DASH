function[sources] = review(obj)
%% Reviews the data sources in a gridfile prior to a repeated load 
% operation. Checks that each data source can be built and returns them in
% a cell vector.
%
% sources = obj.review;
%
% ----- Outputs -----
%
% sources: A cell vector of pre-built dataSource objects for the gridfile

% Preallocate the sources
nSource = size(obj.fieldLength, 1);
sources = cell(nSource, 1);

% Attempt to build each dataSource.
for s = 1:nSource
    try
        sources(s) = obj.buildSources(s);
        
    % Return informative error message if the dataSource could not be built
    catch ME
        badfile = obj.collectFullPaths(s);
        str = 'The data source file may have been deleted or moved';
        if ~obj.absolutePath(s)
            [~, badfile, badext] = fileparts(badfile);
            badfile = strcat(badfile, badext);
            str = strcat(str, ' relative to the .grid file. ');
        end
        
        % Add message to error stack and throw
        message = sprintf(['dataSource number %.f in .grid file "%s" is no ', ...
            'longer valid. This data source was associated with file "%s". ', ...
            '%s. To update file paths, see "gridfile.renameSources".'], s, obj.file, badfile, str);
        cause = MException('DASH:gridfile:invalidDataSource', message);
        ME = addCause(ME, cause);
        rethrow(ME);
    end    
end

% Check that the data sources still match the values saved in the gridfile
obj.checkSourcesMatchGrid(sources, 1:nSource);

end