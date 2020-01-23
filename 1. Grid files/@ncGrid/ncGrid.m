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
        function[obj] = ncGrid( filename, varName, dimOrder )
            % Creates a new ncGrid object
            %
            % obj = ncGrid( filename, varName, dimOrder )
            %
            % ----- Inputs -----
            %
            % filename: The name of the netcdf file
            %
            % varname: The name of the variable in the netcdf file
            %
            % dimOrder: The order of the dimensions of the variable in the
            %           netcdf file. Must use the names from getDimIDs.m
            %
            % ----- Outputs -----
            %
            % obj: The new ncGrid object.
            
            
        end
    end
    
    % Utilities
    methods
        
        % Reads data from the netcdf file
        [X, passVal] = read( obj, scs, ~, ~ )
        
        % Adjust scs for nc dimensions
        [scs] = trimSCS( obj, scs );
        
    end
    
    % Static initialization
    methods (Static)
        [path, file, var, dims, order, msize, umsize, merge, unmerge] = ...
                  initialize( source, varName, dimOrder );
    end
        
end