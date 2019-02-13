function[index, ix] = getMatchingMetaDex( var, dim, meta, isState )
%% This gets indices of a dimensions of a specific variables that match a
% metadata template.
%
% [index, ix] = getMatchingMetaDex( var, dim, meta, isState )
% Returns indices that match a metadata template.
%
% ----- Inputs -----
%
% var: A varDesign
%
% dim: Dimension name
%
% meta: Metadata template for the dimension.
%
% isState: Scalar logical. True if for state dimensions, false for ens.
%
% ----- Outputs -----
%
% index: The indices in the variable that match the metadata
% 
% ix: The indices in the template that the variable matches.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the metadata for the variable in the dimension
dimMeta = var.meta.(dim);

% Check for repeated metadata
if ( iscell(dimMeta) && numel(unique(dimMeta))~=size(dimMeta,1) ) || ...
        size(unique(dimMeta,'rows'),1)~=size(dimMeta,1)  
    error('The metadata template contains repeat values in the %s dimension.', dim);
end

% Singleton dimensions are allowed to use NaN metadata
if numel(dimMeta)==1 && isequaln(meta, dimMeta)
    index = 1;
    
% Otherwise, get intersecting value
else
    
    % Cell metadata cannot be sorted by rows but is necessarily a column
    if iscell(dimMeta)
        [~, ix, index] = intersect( meta, dimMeta, 'stable' );
    else
        [~, ix, index] = intersect( meta, dimMeta, 'stable', 'rows' );
    end
    
    % Throw error if there are no indices
    if isempty(index)
        error('The %s variable does not have metadata matching any of the template metadata in the %s dimension.', var.name, dim);
    end
    
    % If a state index, throw error if there are missing indices
    if isState && numel(index)~=size(meta,1)
        error('The %s variable does not have metadata matching all state indices of the template variable in the %s dimension.', var.name, dim );
    end
end

end