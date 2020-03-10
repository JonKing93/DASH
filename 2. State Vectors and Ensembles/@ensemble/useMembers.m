function[] = useMembers( obj, members )
% Specify which ensemble members to load.
%
% obj.useMembers( members )
% Specify which ensemble members to load. Ensemble members will be loaded
% in the order specified by members.
%
% obj.useMembers( 'all' )
% Load all ensemble members
%
% ----- Inputs -----
%
% members: A set of indices. Either a vector of linear indices, or a
%          logical vector with nEns elements.

% Values for reset flag
nEns = obj.ensSize(2);
if strcmpi( members, 'all' )
    members = 1:nEns;
end

% Error check
if ~isvector(members)
    error('members must be a vector.');
elseif islogical(members) && length(members)~=nEns
    error('When members is a logical vector, it must have one element for each ensemble member (%.f)', nEns );
elseif ~isnumeric(members) || ~isreal(members) || any(members<1) || any(mod(members,1)~=0) || any(members>nEns)
    error('members must be a set of positive integers on the interval [1, %.f]', nEns);
end

% Update load parameters
obj.loadMembers = members(:)';

% Update metadata
obj.metadata.useMembers( obj.loadMembers );

end