function[dataSources, failed, causes] = buildSources(obj, s)
%% gridfile.buildSources  Build dataSources for a gridfile load
% ----------
%   [dataSources, failed, causes] = <strong>obj.buildSources</strong>(s)
%   Builds the dataSource objects for the specified sources. Does not throw
%   errors if a data source fails to build or does not match the gridfile's
%   values for the source. Instead, reports which sources failed and
%   returns the error stack for failed sources.
% ----------
%   Inputs:
%       s (vector, linear indices): The indices of the data sources in the
%           gridfile for which to build a dataSource object.
%
%   Outputs:
%       dataSources (cell vector [nSources] {scalar dataSource object}):
%           dataSource objects for the specified sources. If a data source
%           fails to build, the corresponding element will be empty.
%       failed (logical vector [nSources]): Indicates whether each data
%           source failed to build/match gridfile values (true), or built
%           successfully and matches recorded values (false)
%       causes (cell vector [nSources] {scalar MException}): The error
%           stack indicating the cause of the failed data source build. If
%           a data source builds successfully, the corresponding element
%           will be empty.
%
% <a href="matlab:dash.doc('gridfile.buildSources')">Documentation Page</a>

%% Note!!
% This should remain separate from "sourcesForLoad" so that stateVector can index to
% pre-built/failed sources without rebuilding sources on each level

% Preallocate
nSource = numel(s);
dataSources = cell(nSource, 1);
failed = false(nSource, 1);
causes = cell(nSource, 1);

% Attempt to build each source.
for k = 1:nSource
    try
        source = obj.sources_.build(s(k));
        dataSources{k} = source;
        
        % Require each dataSource to match the recorded values
        [ismatch, type, sourceValue, gridValue] = obj.sources_.ismatch(source, s(k));
        if ~ismatch
            sourceDoesNotMatchError(s(k), type, sourceValue, gridValue, ...
                source.file, obj.file, header);
        end
        
    % Catch, note, and record failed builds
    catch ME
        failed(k) = true;
        causes{k} = ME;
    end
end

end

% Error message
function[] = sourceDoesNotMatchError(s, type, sourceValue, gridValue, sourceFile, gridFile, header)
id = sprintf('%s:sourceDoesNotMatchRecord', header);
error(id, ...
    ['The %s of the data in data source %.f (%s) does not match the ',...
    '%s of the data source recorded in the gridfile (%s). The data source ',...
    'may have been edited after it was added to the gridfile.\n\n',...
    'Data source: %s\n',...
    '   gridfile: %s'],...
    type, s, sourceValue, type, gridValue, sourceFile, gridFile);
end