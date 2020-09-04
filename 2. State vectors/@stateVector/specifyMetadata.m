function[obj] = specifyMetadata(obj, varNames, dim, metadata)
%% Specify metadata at the ensemble reference indices along a dimension of
% variables in a state vector.
%
% obj = obj.specifyMetadata(varNames, dim, metadata)
%
% ----- Inputs -----
%
% varNames: The names of the variables over which to specify metadata. A
%    string vector or cellstring vector.
%
% dim: The name of the dimension for which metadata is provided. A string
%
% metadata: Metadata at the reference indices for an ensemble dimension.
%    Metadata may be numeric, logical, char, string, cellstring, or
%    datetime matrix. Must have one row per reference index. Each row must
%    be unique and cannot contain NaN, Inf, or NaT elements. Cellstring
%    metadata will be converted into the "string" type.
%
% ----- Outputs -----
%
% obj: The updated stateVectorVariable object

% Error check, variable index
v = obj.checkVariables(varNames);

% Update the variables
for k = 1:numel(v)
    obj.variables(v(k)) = obj.variables(v(k)).specifyMetadata(dim, metadata);
end

end