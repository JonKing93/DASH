function[] = failedDataSourceError(obj, grid, var, m, s, sFailed, causes, header)

[sBad, whichFailure] = ismember(s, sFailed);
cause = causes(whichFailure);

sBad = s(find(sBad,1));
sourcePath = grid.sources(sBad);
[~,name,ext] = fileparts(sourcePath);
sourceName = strcat(name, ext);

id = sprintf('%s:dataSourceFailed', header);
ME = MException(id, ['Cannot build the new ensemble members for %s because a data source file',...
    'failed. New ensemble member %.f for the "%s" variable requires data ',...
    'from gridfile "%s" saved in data source file "%s". However, the data ',...
    'could not be loaded from the source file.\n\n',...
    'Data source file: %s\n',...
    '        gridfile: %s\n'],...
    obj.name, m, var, grid.name, sourceName, sourcePath, grid.file);
ME = addCause(ME, cause);
throwAsCaller(ME);

end