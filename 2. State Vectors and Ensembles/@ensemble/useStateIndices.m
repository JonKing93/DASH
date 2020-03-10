function[] = useStateIndices( obj, H )
% Specify which state indices to load from a .ens file.
%
% obj.useStateIndices( H )
% Specify which indices to load.
%
% obj.useStateIndices( 'all' )
% Load all state indices.
%
% ----- Inputs -----
%
% H: The state indices to load. A logical vector with one element per state
%    index.

% Values for the reset flag
nState = obj.ensSize(1);
if strcmpi( H, 'all' )
    H = true(nState,1);
end

% Error check
if ~isvector(H) || ~islogical(H) || numel(H)~=nState
    error('H must be a logical vector with %.f elements.', nState );
end

% Update load parameters
obj.loadH = H;

% Update metadata
obj.loadSize(2) = numel(members);
obj.updateMetadata;

end