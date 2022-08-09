function[obj] = removeMembers(obj, members)
%% ensembleMetadata.removeMembers  Remove ensemble members from an ensembleMetadata object
% ----------
%   obj = <strong>obj.removeMembers</strong>(members)
%   Removes the indicated ensemble members from an ensembleMetadata object.
%   All other ensemble members are retained in the metadata.
% ----------
%   Inputs:
%       members (vector, linear indices | logical vector): The indices of
%           ensemble members that should be removed from the metadata.
%           If a logical vector, must have one element per ensemble member
%           currently in the metadata.
%
%   Outputs:
%       obj (scalar ensembleMetadata object): The ensembleMetadata object
%           with updated ensemble members.
%   
% <a href="matlab:dash.doc('ensembleMetadata.removeMembers')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:removeMembers";
dash.assert.scalarObj(obj, header);

% Check members
logicalReq = 'have one element per ensemble member';
linearMax = 'the number of ensemble members';
members = dash.assert.indices(members, obj.nMembers, 'members', logicalReq, linearMax, header);
members = unique(members);

% Update size
nRemoved = numel(members);
obj.nMembers = obj.nMembers - nRemoved;

% If removing everything, reset coupling sets
if obj.nMembers==0
    obj.nSets = 0;
    obj.couplingSet = NaN(0,1);
    obj.ensembleDimensions = cell(0,1);
    obj.ensemble = cell(0,1);

% Otherwise, remove the selected members from each ensemble dimension
else
    for s = 1:obj.nSets
        dimensions = obj.ensembleDimensions{s};
        for d = 1:numel(dimensions)
            obj.ensemble{s}{d}(members,:) = [];
        end
    end
end

end

