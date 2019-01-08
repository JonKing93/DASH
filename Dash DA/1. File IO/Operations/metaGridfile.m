function[meta, dimID] = metaGridfile( file )
%% Returns the metadata for a gridded .mat file.
% 
% [meta, dimID] = metaGridfile( file )
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% ----- Outputs -----
%
% meta: The metadata structure for the girdded .mat file.
%
% dimID: The order of the dimensions of the saved gridded data.
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file.
m = fileCheck( file, 'readOnly' );

% Get the metadata
dimID = m.dimID;
meta = m.meta;

end