function[X, meta, obj] = addMembers( obj, nAdd, showprogress )
%% Builds additional state vectors for an ensemble and returns them as an array.
%
% [X, meta, obj] = obj.addMembers(nAdd)
% Builds additional state vectors for an ensemble. Returns the additional
% state vector ensemble members, ensemble metadata for the full set of
% ensemble members, and a stateVector object associated with the full set
% of ensemble members.
%
% [...] = obj.addMembers(nAdd, showprogress)
% Specify whether to display a progress bar. Default is to show the
% progress bar.
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
% X: The additional ensemble members. A numeric matrix. (nState x nEns)
%
% meta: An ensembleMetadata object for the ensemble.
%
% obj: A stateVector object associated with the ensemble. Can be used to
%    generate additional ensemble members later.

% Defaults
if ~exist('showprogress','var') || isempty(showprogress)
    showprogress = true;
end

% Error check
if ~isscalar(nAdd)
    error('nAdd must be a scalar.');
end
dash.assertPositiveIntegers(nAdd, 'nAdd');
dash.assertScalarLogical(showprogress, 'showprogress');

% Pre-build the gridfiles and data sources. Check for validity.
[grids, sources, f] = obj.prebuildSources;

% Build the new portion of the ensemble
[X, meta, obj] = obj.buildEnsemble(nAdd, grids, sources, f, [], showprogress);

end