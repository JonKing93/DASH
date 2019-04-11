function[subDex] = subdim( siz, linDex )
%% Subscripts linear indices to an N-dimensional array
%
% ----- Inputs -----
% 
% siz: The size of the N-dimensional array
%
% linDex: Linear indices.
%
% ----- Outputs -----
%
% subDex: The subscripted indices.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Ensure linDex is column
if ~iscolumn(linDex)
    error('linDex must be a column vector');
end

% Get the number of dimensions
nDim = numel(siz);

% Preallocate output cell
subDex = cell(1,nDim);

% Fill subscript indices
[subDex{:}] = ind2sub( siz, linDex );

% Convert output cell to array
subDex = cell2mat(subDex);
end