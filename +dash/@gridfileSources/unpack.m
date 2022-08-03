function[dims, size, mergedDims, mergedSize, mergeMap] = unpack(obj, s)
%% dash.gridfileSources.unpack  Convert catalogued values to their original data types
% ----------
%   [dims, size, mergedDims, mergedSize, mergeMap] = <strong>obj.unpack</strong>(s)
%   Returns recorded values for a data source in the catalogue. Converts
%   recorded values from optimized save/load data types to original data
%   types.
% ----------
%   Inputs:
%       s (numeric scalar): The index of a data source in the catalogue.
%
%   Outputs:
%       dims (string vector [nNonTS]): The list of non-trailing-singleton dimensions
%           in the data source.
%       size (numeric vector [nNonTS]): The size of each nonTS dimension in
%           the data source.
%       mergedDims (string vector [nMerged]): The list of merged nonTS dimensions
%           for the data source.
%       mergedSize (string vector [nMerged]): The size of each merged
%           dimension for the data source.
%       mergeMap (numeric vector [nNonTS]): A vector mapping each original
%           dimension to the merged dimension that includes it. Has one
%           element per original dimension. Each element holds the index of
%           the merged dimension that includes the original dimension.
%
% <a href="matlab:dash.doc('dash.gridfileSources.unpack')">Documentation Page</a>

dims = strsplit(obj.dims(s), ',');
size = strsplit(obj.size(s), ',');
size = str2double(size);
mergedDims = strsplit(obj.mergedDims(s), ',');
mergedSize = strsplit(obj.mergedSize(s), ',');
mergedSize = str2double(mergedSize);
mergeMap = strsplit(obj.mergeMap(s), ',');
mergeMap = str2double(mergeMap);

end