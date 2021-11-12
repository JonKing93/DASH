function[dataSources, failed, causes] = buildSources(obj, s)

%% Note!!
% This should remain separate from "sourcesForLoad" so that can index to
% pre-built/failed sources without rebuilding sources on each level

% Preallocate
nSource = numel(s);
dataSources = cell(nSource, 1);
failed = false(nSource, 1);
causes = cell(nSource, 1);

% Attempt to build each source. Record failed builds
for k = 1:nSource
    try
        source = obj.source_.build(s(k));
        dataSources{k} = source;
    catch ME
        failed(k) = true;
        causes{k} = ME;
    end
    
    % Require each dataSource to match the values recorded in the grid
    [ismatch, type, sourceValue, gridValue] = obj.sources_.ismatch(source, s(k));
    if ~ismatch
        failed(k) = true;
        causes{k} = sourceDoesNotMatchError(...
            s(k), type, sourceValue, gridValue, source.file, obj.file, header);
    end
end

end

% Error message
function[ME] = sourceDoesNotMatchError(s, type, sourceValue, gridValue, sourceFile, gridFile, header)
id = sprintf('%s:sourceDoesNotMatchRecord', header);
ME = MException(id, ...
    ['The %s of the data in data source %.f (%s) does not match the ',...
    '%s of the data source recorded in the gridfile (%s). The data source ',...
    'may have been edited after it was added to the gridfile.\n\n',...
    'Data source: %s\n',...
    '   gridfile: %s'],...
    type, s, sourceValue, type, gridValue, sourceFile, gridFile);
end