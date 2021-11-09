function[dataSources] = review(obj)
% Checks that data sources are valid, returns a cell vector of pre-built
% sources

% Setup
obj.update;
header = "DASH:gridfile:review";

% Preallocate
dataSources = cell(obj.nSource, 1);

% Build each source. Provide informative error message if the build failed
for s = 1:obj.nSource
    try
        dataSources{s} = obj.sources_.build(s);
    catch cause
        invalidDataSourceError(obj, s, cause, header);
    end
    
    % Check the data in the source matches the size and data type recorded
    % in the gridfile
    [ismatch, type, sourceValue, gridValue] = obj.sources_.ismatch(dataSources{s}, s);
    if ~ismatch
        sourceDoesNotMatchError(s, type, sourceValue, gridValue, ...
            dataSources{s}.source, obj.file, header);
    end
end

end

function[] = invalidDataSourceError(obj, s, cause, header)
badPath = obj.sources_.absolutePaths(s);
id = sprintf('%s:invalidDataSource', header);
renameDoc = '<a href="matlab:dash.doc(''gridfile.rename'')">gridfile.rename</a>';
removeDoc = '<a href="matlab:dash.doc(''gridfile.remove'')">gridfile.remove</a>';
base = MException(id, ['Data source %.f in the gridfile is no longer valid. ',...
    'If the data source has moved locations, see the %s command. See the ',...
    '%s command if the data source was deleted or has become corrupted.\n\n',...
    'Data source: %s\n   gridfile: %s'], s, renameDoc, removeDoc, badPath, obj.file);
base = addCause(base, cause);
throw(base);
end
function[] = sourceDoesNotMatchError(s, type, sourceValue, gridValue, sourceFile, gridFile, header)
id = sprintf('%s:sourceDoesNotMatchRecord', header);
error(id, ['The %s of the data in data source %.f (%s) does not match the ',...
    '%s of the data source recorded in the gridfile (%s). The data source ',...
    'may have been edited after it was added to the gridfile.\n\n',...
    'Data source: %s\n',...
    '   gridfile: %s'],...
    type, s, sourceValue, type, gridValue, sourceFile, gridFile);
end