function[s] = loadGrids(obj)
%% Loads data from a .ens file and returns it as gridded climate variables
% along with state vector and ensemble member metadata.
%
% s = obj.loadGrids
%
% ----- Outputs -----
%
% s: A structure containing the gridded climate variables and metadata. The
%    fields of s are the variable names. Each contains a structure with
%    three fields:
%
%    data: This field contains the gridded climate data for the variable.
%          Ensemble members are along the last dimension.
%    gridMetadata: This contains the metadata along the regridded dimensions
%              of the variable. Each row of the dimensional metadata is for
%              one element along the corresponding dimension.
%    members: This contains the metadata for the ensemble members for each
%             dimension of the variable. Each row of the dimensional
%             metadata is for one element along the last dimension of the
%             gridded data.

% Start by loading the state vector ensemble and metadata
[X, meta] = obj.load;

% Initialize an output structure
s = struct();

% Regrid each variable
for v = 1:numel(meta.nEls)
    var = meta.variableNames(v);
    [Xv, gridMeta] = meta.regrid(X, var);
    members = obj.meta.metadata.(var).ensemble;
    s.(var) = struct('data', Xv, 'gridMetadata', gridMeta, 'members', members);
end
    
end