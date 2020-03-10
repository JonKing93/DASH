function[obj] = useMembers( obj, members )
% Limits ensemble metadata to specific ensemble members.
%
% ensMeta = obj.useMembers( members )
% Reduces the ensemble metadata for a specific set of ensemble members.
%
% ----- Inputs -----
%
% members: A vector of linear indices of ensemble members.
%
% ----- Outputs -----
%
% ensMeta: The reduced ensemble metadata

% Error check
if ~isvector(members) || ~isnumeric(members) || ~isreal(members) || any(members<1) || any( mod(members,1)~=0 ) || any(members>obj.ensSize(2))
    error('members must be a vector of positive integers on the interval [1 %.f].', obj.ensSize(2) );
end

% Update the metadata
obj.ensSize(2) = numel(members);

design = obj.design.limitMembers( members );
newMeta = ensembleMetadata( design );
obj.ensMeta = newMeta.ensMeta;

end