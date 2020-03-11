function[M, ensMeta] = load( obj )
%% Loads an ensemble from a .ens file.
%
% [M, ensMeta] = obj.load
% Load the ensemble and associated metadata.
%
% ----- Outputs -----
%
% M: The loaded ensemble
%
% ensMeta: Metadata for the loaded ensemble.

% Error check. Get the matfile
ens = obj.checkEnsFile( obj.file );

% Get load / keep for columns
[members, order] = sort( obj.loadMembers );
nMembers = numel(members);
[scsCol, keepCols] = loadKeep( members );
cols = scsIndices( scsCol );

% Get load / keep for rows
loadH = obj.loadH;
if isempty(loadH)
    loadH = 1:obj.ensSize(1);
end
[scsRow, keepRows] = loadKeep( loadH );
rows = scsIndices( scsRow );

% Attempt to load the entire panel
try
    M = ens.M(rows, cols);
    M = M(:, keepCols);
    
% If the panel is too big for memory, load ensemble members iteratively.
catch
    M = NaN( numel(rows), nMembers );
    progressbar(0);
    for k = 1:nMembers
        M(:,m) = ens.M( rows, members(m) );
        progressbar(m/nMembers);
    end
end

% Remove unncessary rows. Reorder ensemble members from scs with reverse sort
M = M(keepRows, sort(order));

% Return metadata
ensMeta = obj.metadata;

end