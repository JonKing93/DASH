classdef ncGrid < gridData
    % This describes the object used to store information about a netcdf
    % file used in a gridFile
    
    properties (SetAccess = private)
        filepath; % The filepath for the netcdf
        filename; % The name of the file. Used for error messages
        varName; % The name of the gridded data variable in the file
        ncDim;   % The dimensions of the variable in the NetCDF file
    end
    
    % Constructor
    methods
        function[obj] = ncGrid(  path, file, var, dims, order, msize, umsize, merge, unmerge  )
            obj.filepath = path;
            obj.filename = file;
            obj.varName = var;
            obj.ncDim = dims;
            obj.dimOrder = order;
            obj.size = msize;
            obj.unmergedSize = umsize;
            obj.merge = merge;
            obj.mergeSet = unmerge;
        end
    end
    
    % Utilities
    methods
        
        % Reads data from the netcdf file
        [X] = read( obj, scs )
        
        % Adjust scs for nc dimensions
        [scs] = trimSCS( obj, scs );
        
    end
    
    % Static initialization
    methods (Static)
        [path, file, var, dims, order, msize, umsize, merge, unmerge] = ...
                  initialize( source, varName, dimOrder );
    end
        
end