function[limits] = indexLimits(obj, dims, subMembers, includeState)
%% dash.stateVectorVariable.indexLimits  Return the gridfile index limits required to load a set of ensemble members
% ----------
%   limits = obj.indexLimits(dims, subMembers, includeState)
%   Returns index limits along dimensions of a variable. Size of the output
%   and dimension order of limits will depend on whether state dimension
%   limits are required or not.
%
%   allLimits = obj.indexLimits(dims, subMembers, true)
%   Determines the gridfile indices needed to load all the indicated
%   ensemble members. Includes limits for all dimensions in the variable.
%   The order of limits is the order of dimensions in the variable.
%
%   ensLimits = obj.indexLimits(dims, subMembers, false)
%   Determines the index limits along ensemble dimensions required to load
%   the indicated ensemble members. Only includes limits for ensemble
%   dimensions. The order of limits is the order of columns of subMembers
%   (the ensemble dimension order for the coupling set).
% ----------
%   Inputs:
%       dims (vector, linear indices [nEnsDims]): The dimension indices that
%           correpsond to the columns of subMembers.
%       subMembers (matrix, linear indices [nMembers x nEnsDims]): A set of
%           dimensionally-subscripted ensemble members for the variable.
%       includeState (scalar logical): Set to true if the method should
%           determine the limits of state dimensions. Set to false to only
%           determine limits of ensemble dimensions.
%
%   Outputs:
%       allLimits (matrix, linear indices [nDims x 2]): The limits of the
%           indices required to load the ensemble members along each
%           ensemble dimension. The rows of limits are in the same
%           dimension order as the dimensions of the variable
%       ensLimits (matrix, linear indices [nEnsDims x 2]): The limits along
%           the ensemble dimensions of the coupling set. Limits are in the
%           same order as the columns of subMembers.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.indexLimits')">Documentation Page</a>

% Preallocate
nDims = numel(obj.dims);
limits = NaN(nDims, 2);

% Cycle through dimensions. Optionally ignore state dimensions
for d = 1:nDims
    if obj.isState(d) && ~includeState
        continue
    end

    % For state dimensions, get index limits directly
    if obj.isState(d)
        limits(d,1) = min(obj.indices{d});
        limits(d,2) = max(obj.indices{d});

    % For ensemble dimensions, get min/max reference indices
    else
        k = d == dims;
        indices = obj.indices{d}(subMembers(:,k));
        minIndex = min(indices);
        maxIndex = max(indices);
    
        % Get minimum and maximum add indices
        addIndices = obj.addIndices(d);
        maxSubtract = min(addIndices);
        maxAdd = max(addIndices);
    
        % Adjust index limits for add indices
        limits(d,1) = minIndex + maxSubtract;
        limits(d,2) = maxIndex + maxAdd;
    end
end

% Reorder if ensemble only
if ~includeState
    limits = limits(dims,:);
end

end