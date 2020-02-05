function[A, meta, dimID] = regrid( A, varName, ensMeta, keepSingleton )
%% Regrids a variable from a particular time step for a DA analysis.
%
% [rA, meta, dimID] = dash.regrid( A, var, ensMeta )
% Regrids a variable in an ensemble.
%
% [rA, meta, dimID] = dash.regrid( A, var, ensMeta, keepSingle )
% Specify whether to preserve or remove singleton dimensions. Default is to
% remove singletons.
%
% ----- Inputs -----
%
% A: An ensemble. (nState x nTime).
%
% var: The name of a variable. Must be a string.
%
% ensMeta: The ensembleMetadata object associated with A
%
% keepSingleton: A scalar logical.
%
% ----- Outputs -----
%
% rA: A regridded analysis for one variable.
%
% meta: Metadata associated with each element of the regridded data.
%
% dimID: The order of the dimensions for the regridded variable.

% Set defaults
if ~exist('keepSingleton','var') || isempty(keepSingleton)
    keepSingleton = false;
end

% Error check
if ~ismatrix(A)
    error('"A" must be a matrix.');
elseif ~isa( ensMeta, 'ensembleMetadata' ) || ~isscalar(ensMeta)
    error('ensMeta must be a scalar ensembleMetadata object.')
elseif size(A,1) ~= ensMeta.varLimit(end)
    error('The number of rows in A (%.f) must match the number of elements in the ensemble metadata (%.f).', size(A,1), ensMeta.varLimit(end) );
elseif ~isscalar(keepSingleton) || ~islogical(keepSingleton)
    error('keepSingleton must be a scalar logical.');
end
v = ensMeta.varCheck(varName);

% Get the metadata
meta = ensMeta.design.varMetadata;
meta = meta.(varName);

% Extract the variable from the ensemble. Regrid
H = ensMeta.varIndices( varName );
nTime = size(A,2);
A = reshape( A(H,:), [ensMeta.varSize(v,:), nTime] );

% Include metadata for DA time steps
dimID = [ensMeta.design.var(v).dimID, "DA_Time_Steps"];
meta.(dimID(end)) = (1:nTime)';

% Optionally remove singletons
if ~keepSingleton
    singleton = size(A)==1;
    meta = rmfield( meta, dimID(singleton) );
    dimID( singleton ) = [];
    A = squeeze(A);
end

end