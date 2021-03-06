function[meta] = loadMetadata( obj )
% Returns the metadata for the variables and ensemble members to be loaded.
%
% meta = obj.loadMetadata
%
% ----- Outputs -----
% 
% meta: Metadata for the loaded variables and ensemble members

% Warn of future removal
warning('ensemble.loadMetadata is no longer necessary and will be removed in a future release. Please update your code to "ensemble.metadata"');
meta = obj.metadata;
end