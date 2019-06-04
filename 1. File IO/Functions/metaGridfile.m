function[meta, dimID, gridSize] = metaGridfile( file )
%% Returns a structure with metadata for a gridded .mat file.
% 
% [meta, dimID, gridSize] = metaGridfile( file )
%
% ----- Inputs -----
%
% file: The name of the gridded .mat file. A string.
%
% ----- Outputs -----
%
% meta: The metadata structure for the gridded .mat file. Contains a field
%       for each dimension and a field for variable attributes.
%
% dimID: The order of the dimensions in the saved gridded data.
%
% gridSize: The size of the gridded data.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file.
fileCheck( file );

% Initialize a structure
meta = struct();

% Get the dimensions and attributes
[dimID, specs] = getDimIDs;

% Get the metadata for each dimension
for d = 1:numel(dimID)
    meta.( dimID(d) ) = ncread( file, dimID(d) );
end

% Get a separate structure for data attributes
info = ncinfo(file);
att = info.Variables(end).Attributes;

% Get a structure for the attributes
s = struct();
for a = 1:numel(att)
    if isvarname( att(a).Name ) || iskeyword( att(a).Name )
        s.( att(a).Name ) = att(a).Value;
    end
end

% Add the attributes to the full metadata
meta.(specs) = s;

% Get the dimensional ordering of the dataset
nDim = numel( info.Variables(end).Dimensions );
dimID = cell( nDim, 1 );

for d = 1:nDim
    dimID{d} = info.Variables(end).Dimensions(d).Name;
end
dimID = string(dimID);

% Also get the size
gridSize = info.Variables(end).Size;

end