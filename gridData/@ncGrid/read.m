function[X, passVal] = read( obj, scs, ~, ~ )
% Reads data from a NetCDF file in a gridFile.

% Adjust the size of start, count, stride for the number of netcdf dimensions
nNcdim = numel( obj.ncDim );
nGdim = size(scs,2);
if nNcdim < nGdim
    scs = scs(:,1:nNcdim);
elseif nNcdim > nGdim
    nExtra = nNcdim - nGdim;
    scs(:,end + (1:nExtra)) = 1;
end

% Read from the netcdf file
X = ncread( obj.filepath, obj.varName, scs(1,:), scs(2,:), scs(3,:) );
passVal = [];

% Merge dimensions
X = obj.mergeDims( X, obj.merge );

end