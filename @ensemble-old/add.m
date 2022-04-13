function[obj] = add(obj, nAdd, showprogress)
%% Add additional state vectors to an ensemble saved in a .ens file.
%
% obj = obj.add(nAdd)
% Adds a specified number of state vectors to the ensemble.
%
% obj = obj.add(nAdd, showprogress)
% Specify whether to display a progress bar. Default is to show progress.
%
% ----- Inputs -----
%
% nAdd: The number of state vectors to add to the ensemble. A positive
%    integer.
%
% showprogress: A scalar logical indicating whether to display a progress
%    bar (true -- default), or not (false).
%
% ----- Outputs -----
%
% obj: The updated ensemble object.

% Default
if ~exist('showprogress','var') || isempty(showprogress)
    showprogress = true;
end

% Error check
if ~isscalar(nAdd)
    error('nAdd must be a scalar.');
end
dash.assert.positiveIntegers(nAdd, 'nAdd');
dash.assert.scalarType(showprogress, 'showprogress','logical','logical');

% Build the matfile, update matfile properties. Pre-build gridfiles and
% data sources
ens = obj.buildMatfile(true);
obj = obj.update(ens);
grids = obj.stateVector.prebuildSources;

% Add to the ensemble
[~, nPrevious] = size(ens, 'X');
try
    obj.stateVector.buildEnsemble(nAdd, grids, ens, showprogress);
    
% Remove failed portions of the file if the write operation fails
catch ME
    [~, nCols] = size(ens, 'X');
    ens.X(:,nPrevious+1:nCols) = [];
    ens.metadata = obj.metadata.convertToPrimitives;
    ens.stateVector = obj.stateVector.convertToPrimitives;
    rethrow(ME);
end

% If everything was successful, update to include the new data
obj = obj.update(ens);
    
end