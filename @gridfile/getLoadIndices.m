function[loadIndices] = getLoadIndices(obj, userDimOrder, userIndices)
%% gridfile.getLoadIndices  Organizes the dimension indices required to implement a load operation
% ----------
%   loadIndices = obj.getLoadIndices(userDimOrder, userIndices)
%   Takes a user-defined dimension order and accompanying dimension indices
%   and determines the full set of indices needed for a load operation. The
%   full set of indices includes indices for all gridfile dimensions in the
%   order they appear in the gridfile.
% ----------
%   Inputs:
%       userDimOrder (vector, linear indices [nUserDims]): The locations of the
%           user-requested output dimensions in the full set of gridfile dimensions.
%       userIndices (cell vector [nUserDims] {vector, linear indices | empty array}): The
%           user-specified indices to load along each dimension.
%
%   Outputs:
%       loadIndices (cell vector [nGridDims] {vector, linear indices}): The
%           elements along each gridfile dimension that are required to
%           implement the load operation. Includes all gridfile dimensions
%           in the gridfile's dimension order.
%
% <a href="matlab:dash.doc('gridfile.getLoadIndices')">Documentation Page</a>

% Preallocate
nDims = numel(obj.dims);
loadIndices = cell(1, nDims);

% Copy user indices into the set of loadIndices
loadIndices(userDimOrder) = userIndices;

% Use all indices for empty dimensions
for d = 1:nDims
    if isempty(loadIndices{d})
        loadIndices{d} = 1:obj.size(d);
    end
    
    % Always use column vectors
    if isrow(loadIndices{d})
        loadIndices{d} = loadIndices{d}';
    end
end

end