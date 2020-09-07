%% Gridfile quickstart
% This provides an outline of gridfile use.


% Create a new .grid file
meta = gridfile.defineMetadata( "dim1", metadata1, "dim2", metadata2, "dimN", metadataN );
grid = gridfile.new('myfile.grid', meta);


% Add data sources to the .grid file
for s = 1:nSources
    sourceMeta = gridfile.defineMetadata( "sourceDim1", sourceMeta1(s), ...
                    "sourceDim2", sourceMeta2(s), "sourceDimN", sourceMetaN(s) );
    dimensionOrder = [dim1, dim2, dimN];
    grid.add( filename(s), variable(s), dimensionOrder, sourceMeta );
end


% Load data from the .grid file
meta = grid.metadata;
NH = meta.lat>0;
post1800 = meta.time>1800;
high = meta.lev==250;

[X, Xmeta] = grid.load( ["lat","lon","lev","time"], {NH, [], high, post1800} );