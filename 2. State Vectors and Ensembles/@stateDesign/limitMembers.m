function[obj] = limitMembers( obj, members )
% Reduces a state design to specified ensemble members.
%
% design = obj.limitMembers( members )
% 
% ----- Inputs -----
%
% members: A vector of linear indices of ensemble members.
%
% ----- Outputs -----
%
% design: The reduced state design

% Error check
if isempty( obj.var )
    error('The state design does not have any variables.');
elseif isempty( obj.var(1).drawDex )
    error('The state design does not have any ensemble members.');
elseif ~isvector(members) || ~isnumeric(members) || ~isreal(members) || any(members<1) || any( mod(members,1)~=0 ) || any(members>numel(obj.var(1).drawDex))
    error('members must be a vector of positive integers that do not exceed %.f.', numel(obj.var(1).drawDex) );
end

% Limit the ensemble members
for v = 1:numel( obj.var )
    obj.var(v).drawDex = obj.var(v).drawDex(members,:);
end

end