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

% If evenly spaced, only load desired values. Otherwise, load iteratively
[members, order] = sort(obj.loadMembers);
spacing = unique( diff( members ) );
nMembers = numel(members);

if nMembers==1 || numel(spacing) == 1
    M = ens.M( :, members );
    
else
    M = NaN( obj.ensSize(1), nMembers );
    for m = 1:nMembers
        M(:,m) = ens.M( :, members(m) );
    end
end

% Reorder the members from scs with a reverse sort
M = M(:, sort(order) );

% Restrict to desired variables
nVars = numel( obj.loadVars );
indices = cell( nVars, 1 );
for v = 1:nVars
    indices{v} = obj.metadata.varIndices( obj.loadVars(v) );
end
indices = cell2mat(indices);
M = M( indices, : );

% Return ensemble metadata
ensMeta = obj.loadMetadata;

end