function[] = useMembers( obj, members )
% Only load specified ensemble members.
%
% obj.useMembers( members )
%
% ----- Inputs ----
%
% members: A vector of linear indices of ensemble members.

% Error check
if ~isvector(members) || ~isnumeric(members) || ~isreal(members) || any(members<1) || any( mod(members,1)~=0 ) || any(members>obj.ensSize(2))
    error('members must be a vector of positive integers that do not exceed %.f.', obj.ensSize(2) );
end
obj.loadMembers = members;

end