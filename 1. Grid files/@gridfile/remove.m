function[] = remove(obj, file)
%% Removes a data source from a .grid file.
%
% obj.remove( file )
% Finds all data sources with the specified file name and removes them from
% the grid file.
%
% obj.remove( fullname )
% Finds all data sources with the full file name (including path) and
% removes them from the .grid file.
%
% obj.remove( file, var )
% Only removes data sources that have both the specified file and variable
% name.
%
% obj.remove( file, var, meta )
% Only removes data sources that have the specified file name, variable
% name, and dimensional metadata.