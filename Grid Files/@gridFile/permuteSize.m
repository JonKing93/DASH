function[gridSize] = permuteSize( gridSize, dimOrder, gridDims )
%% Permutes a size vector from a particular dimensional ordering to a 
% new dimensional ordering.
%
% gridSize = permuteGrid( gridSize, dimOrder, gridDims )

[~, loc] = ismember( gridDims, dimOrder );

gridSize(end+1) = 1;
loc( loc==0 ) = length(gridSize);

gridSize = gridSize( loc );

end
