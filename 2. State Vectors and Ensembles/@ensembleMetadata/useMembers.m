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

% Get the number of ensemble members in the original ensemble
siz = obj.design.ensembleSize;
nEns = siz(2);

% Error check
if ~isvector(members) || ~isnumeric(members) || ~isreal(members) || any(members<1) || any( mod(members,1)~=0 ) || any(members>nEns)
    error('members must be a vector of positive integers on the interval [1 %.f].', nEns );
end

% Update the metadata
obj.ensSize(2) = numel(members);

design = obj.design.limitMembers( members );
newMeta = ensembleMetadata( design );
obj.ensMeta = newMeta.ensMeta;

end