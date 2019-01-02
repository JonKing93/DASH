function[meta, dimID] = metaGridfile( file )

% Error check the file.
m = fileCheck( file );

% Get the metadata
m = matfile(file);
dimID = m.dimID;
meta = m.meta;

end