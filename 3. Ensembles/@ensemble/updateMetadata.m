function[] = updateMetadata( obj )
% Update ensemble metadata when load parameters are specified.

% Build from new to avoid double calls
newMeta = ensembleMetadata( obj.design );
newMeta = newMeta.useMembers( obj.loadMembers );
if ~isempty(obj.loadH)
    newMeta = newMeta.useStateIndices( obj.loadH );
end
obj.metadata = newMeta;

end