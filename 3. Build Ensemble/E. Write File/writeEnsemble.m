function[] = writeEnsemble( file, design, nEns, ensMeta )

% Get the variable indices within the ensemble
[varDex] = getVarIndices( design.var );

% Create a writable matfile object and initialize an empty ensemble
fEns = matfile( file, 'Writable', true );
fEns.M = [];

% Initialize a toggle to mark if the build was successful
fEns.complete = false;

% Preallocate the ensemble within the matfile
nState = max( varDex{end} );
fEns.M(1:nState, 1:nEns) = NaN;

% Build the ensemble for each variable
for v = 1:numel( design.var )
    buildVarEnsemble( fEns, design.var(v), varDex{v}, nEns );
end

% Remove any ensemble members with NaN elements
hasnan = any( isnan(fEns.M), 1 );
fEns.M(:,hasnan) = [];

% Notify if any ensemble members were removed. Throw an error if all the
% ensemble members were removed.
if all(hasnan)
    error('Every ensemble member contained NaN elements.\n');
elseif any(hasnan)
    fprintf('Removed %.f ensemble members that contained NaN elements.\n', sum(hasnan));
end

% Record the size of the ensemble
ensSize = [nState, nEns - sum(hasnan)];

% Save all the metadata
fEns.ensSize = ensSize;
fEns.ensMeta = ensMeta;
fEns.design = design;

% Set the "complete" toggle to true
fEns.complete = true;

end