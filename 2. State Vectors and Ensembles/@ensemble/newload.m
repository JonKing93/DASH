function[M, ensMeta] = newload( obj )
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

% Error check. Get the matfile and metadata for the full ensemble
ens = obj.checkEnsFile( obj.file );
fullMeta = ensembleMetadata( obj.design );

% Determine if columns are evenly spaced. Get load/keep
[members, order] = sort( obj.loadMembers );
nMembers = numel( members );
[scsCol, keepCols] = loadKeep( members );
cols = scsIndices( scsCol );

% Cycle through each variable, get the rows needed. Get load/keep
nVars = numel( obj.metadata.varName );
varRows = cell( nVars, 1 );
for v = 1:nVars
    if obj.loadVar(v)
        if obj.psmVar(v)
            varRows{v} = (fullMeta.varLimit(v,1)-1) + obj.psmElements{v};
        else
            varRows{v} = fullMeta.varIndices( fullMeta.varName(v) );
        end
    end
end
[scsRow, keepRows] = loadKeep( cell2mat(dataRows) );
rows = scsIndices( scsRow );

% Attempt to load everything at once. Load iteratively if unsuccessful
try
    M = ens.M( rows, cols );
catch
    M = NaN( numel(rows), nMembers );
    progressbar(0);
    for m = 1:nMembers
        M(:,m) = ens.M( rows, members(m) );
        progressbar(m/nMembers);
    end
end

% Keep the desired elements / members. Reorder ensemble members
M = M(keepRows, keepCols);
M = M(:, sort(order));

% Return metadata
ensMeta = obj.metadata;

end