function[X, passVal] = read( obj, scs, ~, ~ )
% Reads data from a NetCDF file in a gridFile.

% Adjust the start count and stride for merged dimensions.
[fullscs, keep] = obj.unmergeSCS( scs );

% Adjust the size of start, count, stride for the number of netcdf dimensions
nNcdim = numel( obj.ncDim );
nGdim = size(fullscs,2);
if nNcdim < nGdim
    fullscs = fullscs(:,1:nNcdim);
elseif nNcdim > nGdim
    nExtra = nNcdim - nGdim;
    fullscs(:,end + (1:nExtra)) = 1;
end

% Read from the netcdf file
X = ncread( obj.filepath, obj.varName, fullscs(1,:), fullscs(2,:), fullscs(3,:) );
passVal = [];

% Merge dimensions. Apply keep indices to merged dims
X = obj.mergeDims( X, obj.merge );
X = X( keep{:} );

end