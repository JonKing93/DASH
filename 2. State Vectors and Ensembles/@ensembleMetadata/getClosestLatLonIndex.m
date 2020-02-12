function[H] = getClosestLatLonIndex( obj, coords, varNames, varargin )
% This function redirects to closestLatLonIndices. It is meant as a patch
% to the rename to "closestLatLonIndices" of v3.4.0. It will be removed in
% a future release.
warning('ensembleMetadata.getClosestLatLonIndex was renamed and will be removed in a future release. You will eventually need to adjust your code to use ensembleMetadata.closestLatLonIndex instead.');
H = obj.closestLatLonIndices( coords, varNames, varargin{:} );
end