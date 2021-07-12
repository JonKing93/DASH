function[indices] = equallySpaced(indices)
%% For a set of linear indices, returns a set of equally spaced indices
% that will include all input indices.
%
% indices = dash.equallySpacedIndices(indices)
%
% ----- Inputs -----
%
% indices: A set of linear indices
%
% ----- Outputs ------
%
% indices: A set of linear indices with equal spacing that include all
% input indices.

if numel(indices)>1
    indices = sort(indices);
    spacing = unique(diff(indices));
    
    if numel(spacing) > 1
        indices = indices(1):indices(end);
    end
end

end