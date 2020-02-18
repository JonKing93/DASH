function[H] = getClosestLatLonIndex( obj, coords, varNames, varargin )
% This function redirects to closestLatLonIndices. It is meant as a patch
% to the rename to "closestLatLonIndices" of v3.4.0. It will be removed in
% a future release.
warning(['ensembleMetadata.getClosestLatLonIndex has been renamed to ensembleMetadata.closestLatLonIndex and ',...
        'will be removed in a future release. Please consider updating your code.']);

if ~exist('coords','var')
    coords = [];
end
if ~exist('varNames', 'var')
    varNames = [];
end
if ~exist( 'varargin', 'var')
    varargin = {};
end
H = obj.closestLatLonIndices( coords, varNames, varargin{:} );
end