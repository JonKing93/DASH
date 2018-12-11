function[gmeta] = build_GHCN_metadata( metaFile, outFile )
%% Converts the GHCN metadata file to .mat
%
% build_GHCN_metadata( metaFile, outFile )
% Saves the .mat file to the current directory.
%
% gmeta = build_GHCN_metadata( metaFile )
% Returns the metadata as a table.
%
% ----- Inputs -----
%
% metaFile: Filename of the metadata file. In the GHCN archives, this is
%      something along the lines of 'ghcnm.tavg.v3.3.0.20181210.qca.inv'
%
% outFile: Filename of the output file. (E.g. 'ghcnMeta.mat')
%
% ----- Outputs -----
%
% gmeta: A structure array of the metadata.

% Read the data
gmeta = fileread( metaFile );

% Get the number of elements per line by finding the index of the first
% newline character.
nElts = find( gmeta == newline, 1 );

% Reshape into an nStation x nElts matrix
nStation = numel(gmeta) / nElts;
gmeta = reshape( gmeta, [nElts, nStation]);
gmeta = gmeta';

% Preallocate
ID = cell(nStation,1);
lat = NaN(nStation,1);
lon = lat;
elevation = lat;
name = ID;

% Start reading off values
for k = 1:nStation
    ID{k} = gmeta(k,1:11);
    lat(k) = str2double( gmeta(k,13:20) );
    lon(k) = str2double( gmeta(k,22:30) );
    elevation(k) = str2double( gmeta(k, 32:37) );
    name{k} = gmeta(39:68);
end

% Form into table
ghcnMeta = table( ID, lat, lon, elevation, name );

% Save or output
if nargout == 0
    save( outFile, 'ghcnMeta' );
    gmeta = [];
else
    gmeta = ghcnMeta;
end

end