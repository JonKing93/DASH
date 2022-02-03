function[dataSources, failed, causes] = buildSources(obj, s, fatal, filepaths)
%% gridfile.buildSources  Build dataSources for gridfile operations
% ----------
%   [dataSources, failed, causes] = <strong>obj.buildSources</strong>(s)
%   Builds the dataSource objects for the specified sources. If a data
%   source fails to build, or does not match the values recorded in the
%   gridfile, exits immediately and reports the failed data source as well
%   as the cause of the failure.
%  
%   ... = <strong>obj.buildSources</strong>(s, fatal)
%   Specify whether the method should stop immediately when a data source
%   fails. Default is true. If false, the method will continue through the
%   full set of data sources, reporting all failed data sources and the
%   causes of their failures.
%
%   ... = <strong>obj.buildSources</strong>(s, fatal, filepaths)
%   Builds data sources using the values recorded in the gridfile, but with
%   custom filepaths.
% ----------
%   Inputs:
%       s (vector, linear indices [nSources]): The indices of the data
%           sources in the gridfile for which to build dataSource objects.
%       fatal (scalar logical): Set to true (default) if the method should
%           exit immediately when a data source fails. Set to false to
%           continue and attempt to build all sources
%       filepaths (string vector [nSources]): The absolute filepaths to use
%           when building the dataSources
%
%   Outputs:
%       dataSources (cell vector [nSources] {scalar dataSource object | []} | []):
%           dataSource objects for the specified sources. If fatal is true,
%           and a dataSource fails, dataSources is an empty array. If not
%           fatal, the elements for failed sources are empty arrays.
%       failed (false | scalar integer | logical vector [nSources]): Indicates whether any data
%           sources failed. If fatal, failed is false or the index of the failed source. If not
%           fatal, failed is a logical vector with one element per data
%           source. If not fatal and there are no requested data sources,
%           then failed will be false.
%       causes ([] | scalar MException | cell vector [nSources] {scalar MException}): 
%           If fatal and all sources succeeded, returns an empty array. If
%           fatal and failed, a scalar MException. If not fatal, has one
%           element per source. Elements of failed sources hold the
%           MException reporting the cause of the failure. Elements of
%           successful sources are empty arrays.
%
% <a href="matlab:dash.doc('gridfile.buildSources')">Documentation Page</a>

%% Note!!
% This should remain separate from "sourcesForLoad" so that stateVector can index to
% pre-built/failed sources without rebuilding sources on each level

% Default
if ~exist('fatal','var') || isempty(fatal)
    fatal = true;
end

% Preallocate
nSource = numel(s);
dataSources = cell(nSource, 1);
failed = false(max(1,nSource), 1);
causes = cell(nSource, 1);

% Attempt to build each source
for k = 1:nSource
    try
        if ~exist('filepaths','var') || isempty(filepaths)
            source = obj.sources_.build(s(k));
        else
            source = obj.sources_.build(s(k), filepaths(k));
        end
        dataSources{k} = source;
        
        % Require each dataSource to match the recorded values
        [ismatch, type, sourceValue, gridValue] = obj.sources_.ismatch(source, s(k));
        if ~ismatch
            dataSources{k} = [];
            sourceDoesNotMatchError(s(k), type, sourceValue, gridValue);
        end

    % Report fatal failures
    catch ME
        if fatal
            dataSources = [];
            failed = k;
            causes = ME;
            return;
        end

        % Record non-fatal failures
        failed(k) = true;
        causes{k} = ME;
    end
end

% Adjust output for successful fatal builds
if fatal
    failed = false;
    causes = [];
end

end

% Error message
function[] = sourceDoesNotMatchError(s, type, sourceValue, gridValue)
id = 'DASH:gridfile:buildSources:sourceDoesNotMatchRecord';
ME = MException(id, ...
    ['The %s of the data in data source %.f (%s) does not match the\n',...
    '%s of the data source recorded in the gridfile (%s).\nThe data source ',...
    'may have been edited after it was added to the gridfile.'],...
    type, s, sourceValue, type, gridValue);
throwAsCaller(ME);
end
