function[M, ensMeta] = load( obj, members, nonan )
%% Loads an ensemble from a .ens file.
%
% [M, ensMeta] = obj.load
% Returns the entire ensemble and associated metadata.
%
% [M, ensMeta] = obj.load( members )
% Loads specific ensemble members. Leave empty to load all ensemble members
%
% [M, ensMeta] = obj.load( members, noNaN )
% Specify whether to prohibit loading ensemble members with NaN values.
% Default is false.
%
% ----- Inputs -----
%
% members: indices specifying which ensemble members to load. Either a vector
%          of linear indices, or a logical vector the length of the ensemble.
%
% noNaN: A scalar logical indicating whether to prohibit loading ensemble
%        members with NaN values. Default is to load all members (false)
%
% ----- Outputs -----
%
% M: The loaded ensemble
%
% ensMeta: Metadata for the loaded ensemble.

% Set defaults
if ~exist('members','var') || isempty(members)
    members = 1:obj.ensSize(2);
end
if ~exist('nonan','var') || isempty(nonan)
    nonan = false;
end

% Error check. use linear indices internally. Get the matfile
if ~isscalar(nonan) || ~islogical(nonan)
    error('nonan must be a scalar logical.');
elseif islogical(members) && (~isvector(members) || length(members)~=obj.ensSize(2))
    error('When using logical indices, members must be a vector the length of the ensemble (%.f).', obj.ensSize(2) );
elseif ~isnumeric(members) || ~isreal(members) || ~isvector(members) || any(members<=0) || any(members>obj.ensSize(2)) || any(mod(members,1)~=0)
    error('members must be a vector of positive integers on the closed interval [1, %.f].', obj.ensSize(2) );
end
if islogical(members)
    members = find(members);
end
ens = obj.checkEnsFile( obj.file );

% Remove NaN members if prohibiting NaN
if nonan
    members( ismember(members, find(any(obj.hasnan,1)) )) = [];
end

% If evenly spaced, only load desired values. Otherwise, load iteratively
[members, order] = sort(members);
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
if ~isempty( obj.vars )
    nVars = numel( obj.vars );
    indices = cell( nVars, 1 );
     
    for v = 1:numel(obj.vars)
        indices{v} = obj.metadata.varIndices( obj.vars(v) );
    end
    indices = cell2mat(indices);
    M = M( indices, : );
end

% Return ensemble metadata
ensMeta = obj.loadMetadata;

end
