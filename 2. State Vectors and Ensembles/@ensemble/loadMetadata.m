function[meta] = loadMetadata( obj )
% Returns the metadata for the variables and ensemble members to be loaded.
%
% meta = obj.loadMetadata
%
% ----- Outputs -----
% 
% meta: Metadata for the loaded variables and ensemble members

meta = obj.metadata;
if ~isempty( obj.loadVars )
    meta = meta.useVars( obj.loadVars );
end
if ~isempty( obj.loadMembers )
    meta = meta.useMembers( obj.loadMembers );
end

end