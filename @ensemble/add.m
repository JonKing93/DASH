function[] = add(obj, nAdd, showprogress)
%% Add additional state vectors to an ensemble saved in a .ens file.
%
% obj.add(nAdd)
% Adds a specified number of state vectors to the ensemble.
%
% obj.add(nAdd, showprogress)
% Specify whether to display a progress bar. Default is to show progress.
%
% ----- Inputs -----
%
% nAdd: The number of state vectors to add to the ensemble. A positive
%    integer.
%
% showprogress: A scalar logical indicating whether to display a progress
%    bar (true -- default), or not (false).

% Default
if ~exist('showprogress','var') || isempty(showprogress)
    showprogress = true;
end

% Error check
if ~isscalar(nAdd)
    error('nAdd must be a scalar.');
end
dash.assertPositiveIntegers(nAdd, 'nAdd');
dash.assertScalarLogical(showprogress, 'showprogress');

% Get the matfile, check it is valid
warning('Need error checking for file.');
ens = matfile(obj.file,'Writable',true);
nPrevious = size(ens, 'X', 2);

% Record previous settings in case the operation fails
sv = ens.stateVector;
meta = ens.meta;

% Pre-build the gridfiles and data sources. Check for validity
[grids, sources, f] = sv.prebuildSources;

% Add to the ensemble
try
    sv.buildEnsemble(nAdd, grids, sources, f, ens, showprogress);
    
% Remove failed portions of the file if the write operation fails
catch ME
    nCols = size(ens, 'X', 2); %#ok<GTARG>
    ens.X(:,nPrevious+1:nCols) = [];
    ens.hasnan(:,nPrevious+1:nCols) = [];
    ens.meta = meta;
    ens.stateVector = sv;
    rethrow(ME);
end
    
end