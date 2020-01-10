function[ensMeta] = useMembers( obj, members )
% Returns ensemble metadata limited to specific ensemble members.
%
% ensMeta = obj.useMembers( members )
% Reduces the ensemble metadata to specified ensemble members
%
% ----- Inputs ----
%
% members: A vector of linear indices of ensemble members.
%
% ----- Outputs ----
%
% ensMeta: The reduced ensemble metadata

% Error check
if ~isvector(members) || ~isnumeric(members) || ~isreal(members) || any(members<1) || any( mod(members,1)~=0 ) || any(members>obj.ensSize(2))
    error('members must be a vector of positive integers that do not exceed %.f.', obj.ensSize(2) );
end

% Adjust the state design. Create new metadata
for v = 1:numel( obj.design.var )
    obj.design.var(v).drawDex = obj.design.var(v).drawDex(members);
end
ensMeta = ensembleMetadata( obj.design );

end