function[meta, dimID, gridSize] = meta( file )
%% Returns a structure with metadata for a gridded .mat file.
% 
% [meta, dimID, gridSize] = gridFile.meta( file )
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% ----- Outputs -----
%
% meta: The metadata structure for the gridded dataset. Contains a field
%       for each dimension and a field for variable attributes.
%
% dimID: The order of the dimensions in the .grid file
%
% gridSize: The total size of the gridded data.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Initialize the gridFile object
grid = gridFile( file );

% Extract the output fields
meta = grid.metadata;
dimID = grid.dimOrder;
gridSize = grid.gridSize;

end