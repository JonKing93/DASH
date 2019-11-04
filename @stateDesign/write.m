function[] = write2( obj, file, random, writenan, new )
% Writes the ensemble to file.

% Handle pre-existing or non-existing files.
if new && exist(fullfile(pwd,file),'file')
    delete(file);
elseif ~new && ~exist('file','file')
    error('The file "%s" in the ensemble object does not exist. It may have been deleted or removed from the active path.', file);
end

% Get the matfile and fill in values as appropriate
ens = matfile(file,'Writable', true);
ens.complete = false;
ensSize = obj.ensembleSize;
if new
    nNew = ensSize(2);
    nWritten = 0;
    ens.M( 1:ensSize(1), 1:nNew ) = NaN;
    ens.random = random;
    ens.writenan = writenan;
    ens.hasnan = [];
    hasnan = false(1, ensSize(2));
else
    nWritten = ens.ensSize(1,2);
    nNew = ensSize(2) - nWritten;
    ens.M( :, nWritten + (1:nNew) ) = NaN;
    hasnan = false(1, nNew);
end

% Determine the unique gridFiles
nVar = numel( obj.var );
gridFiles = cell(nVar, 1);
[gridFiles{:}] = deal( obj.var.file );
gridFiles = string( gridFiles );
uniqGrids = unique( gridFiles );
nGrid = numel( uniqGrids );

% Preallocate passed values for data sources in shared gridFiles
[~, passIndex] = ismember( gridFiles, uniqGrids );
passVals = cell( nGrid, 1 );
for g = 1:nGrid
    grid = load( uniqGrids(g), '-mat', 'source' );
    passVals{g} = cell( 1, numel(grid.source)+1 );
end

% Get the ensemble for each variable. Record NaN members and write to file
[varLimit, varSize, ~, nMean] = obj.varIndices;
for v = 1:numel( obj.var )
    [M,  passVals{passIndex(v)}] = ...
        obj.var(v).buildEnsemble( nWritten, varSize(v,:), nMean(v,:), passVals{passIndex(v)} );
    hasnan = hasnan | any( isnan(M), 1 );
    ens.M( varLimit(v,1):varLimit(v,2), nWritten+(1:nNew) ) = M; 
end

% Finish adding values to the .ens file
ens.hasnan = [ens.hasnan, hasnan];
ens.ensSize = ensSize;
obj.new = false;
ens.design = obj;
ens.complete = true;

end