function[] = renameSource( oldname, newname )
%% Changes the file name associated with a data source to a new file name. 
% Useful if data files are moved to a new location after being added to a
% .grid file.
%
% obj.renameSource( oldname, newname )
% Finds all data sources whose file name matches oldname and changes the
% file name to newname. 
%
% If oldname is a full file name (including path),
% only changes data sources matching the full file name. If oldname is just
% a file name, changes all matching data sources regardless of path.
%
% If newname is a full file name (including path), it is used directly as
% the new file name. If newname is just a file name, locates a file with
% the given name on the active path and uses its full name.
%
% ----- Inputs -----
%
% oldname: The file name currently associated with a data source. A string.
%
% newname: The new name of the file associated with a data source. A string.

% Update the grid object in case the file changed
obj.update;

% Error check
dash.assertStrFlag(oldname, "oldname");
dash.assertStrFlag(newname, "newname");
newname = dash.checkFileExists(newname);

% Find file sources that match the name
match = obj.findFileSources(oldname);
if ~any(match)
    error('None of the data sources in %s are named %s.', obj.file, oldname);
end

% For each renamed source, build a dataSource object to check that the new
% file is still compatible with the old settings
