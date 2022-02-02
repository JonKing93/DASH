function[limits] = indexLimits(obj, dims, subMembers)
%% dash.stateVectorVariable.indexLimits  Return the gridfile index limits required to load a set of ensemble members
% ----------
%   limits = obj.indexLimits(dims, subMembers)
%   Determines the gridfile indices needed to load all the indicated
%   ensemble members. Returns the limits of these indices along each
%   dimension.
% ----------
%   Inputs:
%       dims (vector, linear indices [nEnsDims]): The dimension indices that
%           correpsond to the columns of subMembers.
%       subMembers (matrix, linear indices [nInitial x nEnsDims]): A set of
%           dimensionally-subscripted ensemble members for the variable.
%
%   Outputs:
%       limits (matrix, linear indices [nDims x 2]): The limits of the
%           indices required to load the ensemble members along each
%           gridfile dimension.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.indexLimits')">Documentation Page</a>

% Preallocate
nDims = numel(obj.dims);
limits = NaN(nDims, 2);

% Cycle through dimensions. Get indices
for d = 1:nDims
    indices = obj.indices{d};
    if isempty(indices)
        indices = 1:obj.gridSize(d);
    end

    % For state dimensions, get direct index limits
    if obj.isState(d)
        minIndex = min(indices);
        maxIndex = max(indices);

    % For ensemble dimensions, get the indices for the ensemble members
    else
        k = d==dims;
        indices = indices(subMembers(:,k));

        % Then extract limits
        minIndex = min(indices);
        maxIndex = max(indices);

        % Get minimum and maximum add indices
        addIndices = obj.addIndices(d);
        maxSubtract = min(addIndices);
        maxAdd = max(addIndices);

        % Adjust index limits for add indices
        minIndex = minIndex + maxSubtract;
        maxIndex = maxIndex + maxAdd;
    end

    % Record the final limits
    limits(d,1) = minIndex;
    limits(d,2) = maxIndex;
end

end