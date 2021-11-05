function[] = rename(obj, sources, newNames)
%%
% ----------
%   obj.rename
%   Checks every data source in the .grid file to make sure it still
%   exists. If a data source cannot be found, the method searches the
%   active path for files with the same name and extension. If a file with
%   the same name is found, checks that the new file contains a data matrix
%   with the same size and data type as the recorded data source. If so,
%   stores the new file location for the data source. If a data source
%   cannot be found and these criteria are not met, throws an error
%   reporting the missing data source.
%
%   Note: This method only checks the existence of data sources located on
%   a file system drive. Data sources accessed via an OPENDAP url are not
%   checked.
%
%   obj.rename(s)
%   obj.rename(sources)
%   Specify which data sources should be checked and renamed. Any specified
%   data sources accessed via an OPENDAP url are not checked.
%
%   obj.rename(..., newNames)
%   Specify the new names to use for the data sources. Use this syntax when
%   the file name or extension of a data source file has changed. This
%   syntax also allows data sources accessed via an OPENDAP url to be
%   relocated (either to a different OPENDAP url, or a local data file).
% ----------
%   Inputs:
%       s
%       sources
%       newNames
%
% <a href="matlab:dash.doc('gridfile.rename')">Documentation Page</a>

% Setup
header = "DASH:gridfile:rename";
obj.update;

% Get the data sources that should be checked and/or renamed
if exist('sources','var')
    s = obj.sources.indices(sources, obj.file, header);
else
    s = 1:obj.nSource;
end
nSources = numel(s);

% User provided names - start by error checking the names
if exist('newNames','var')
    newNames = dash.assert.strlist(newNames, 'newNames', header);
    dash.assert.vectorTypeN(newNames, [], nSources, 'newNames', header);
    
    % Build the data source for each new name, check it matches the grid
    for k = 1:nSources
        dataSource = obj.sources.build(s(k), newNames(k));
        obj.sources.assertMatch(s(k), dataSource);
        
        % Update the gridfile
        
        
        
    
    
    





%   file to make sure it holds a data matrix of the same size and data type
%   as the recorded 