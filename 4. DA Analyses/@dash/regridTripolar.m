function[rA, dimID] = regridTripolar( A, var, ensMeta, gridSize, notnan, keepSingleton )
%% Regrids a tripolar variable from a particular time step for a DA analysis.
%
% [rA, dimID] = dash.regridTripolar( A, var, ensMeta, gridSize, notnan )
% Regrids a variable on a tripolar grid.
%
% [rA, dimID] = dash.regridTripolar( ..., keepSingleton )
% Specify whether to keep or remove singleton dimensions. Default is remove.
%
% ----- Inputs -----
%
% A: A state vector. Typically the updated ensemble mean or variance. (nState x 1)
%
% var: The name of a variable. Must be a string.
%
% ensMeta: Ensemble metadata
%
% gridSize: The size of the original tripolar spatial grid.
%
% notnan: A set of logicals indices that point to non-nan indices on a
%   tripolar grid. Typically, the indices of ocean grid nodes. (nTripole x 1)
%
% keepSingleton: A scalar logical indicating whether to keep or remove
%   singleton dimensions.
%
% ----- Outputs -----
%
% rA: A regridded analysis for one variable.
%
% dimID: The dimensional ordering of the regridded variable. Tri1 and tri2
%        are the first and second dimensions associated with the original
%        tripolar grid.

% Set defaults
if ~exist('keepSingleton','var') || isempty(keepSingleton)
    keepSingleton = false;
end

% Error check
if numel(gridSize)~=2 || any(gridSize<1) || any(mod(gridSize,1)~=0) 
    error('gridSize must be a 2-element vector with the size of the original tripolar spatial grid.');
elseif ~islogical(notnan) || ~isvector(notnan) || prod(gridSize)~=numel(notnan)
    error('notnan must be a logical vector with one element for each element in the original tripolar grid (%.f)', prod(gridSize));
end

% Intial regird
[A, ~, dimID] = dash.regrid( A, var, ensMeta, keepSingleton );

% Get the tripole dimension
[~,~,~,~,~,~,~,~,triDim] = getDimIDs;
tri = find( strcmp(dimID, triDim) );

% Preallocate the full tripolar grid
siz = size(A);
siz(tri) = prod( gridSize );
rA = NaN(siz);

% Fill in the non-NaN values on the full grid
dataIndices = repmat( {':'}, [numel(dimID),1] );
dataIndices{tri} = notnan;
rA( dataIndices{:} ) = A;

% Reshape to the original grid size
siz = siz([1:tri, tri:end]);
siz(tri) = gridSize(1);
siz(tri+1) = gridSize(2);

rA = reshape( rA, siz );

% Update the dimension IDs
dimID = dimID([1:tri, tri:end]);
dimID{tri} = 'tri1';
dimID{tri+1} = 'tri2';

% Optionally remove singleton dimensions
if ~keepSingleton
    singleton = size(rA)==1;
    dimID(singleton) = [];
    rA = squeeze(rA);
end

end