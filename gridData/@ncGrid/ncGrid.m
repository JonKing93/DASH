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
            
            % Check that the file exists, get the full path
            if ~isstrflag( filename )
                error('filename must be a string scalar or character row vector.');
            elseif ~exist( filename, 'file' )
                error('The file %s does not exist. It may be misspelled or not on the active path.', filename );
            end
            obj.filepath = which( filename );
            obj.filename = filename;
            
            % Check that the file is actually a netcdf
            try
                info = ncinfo( obj.filepath );
            catch ME
                error('The file %s is not a valid NetCDF file.', filename );
            end
            
            % Check that the variable name is allowed and exists
            if ~isstrflag( varName )
                error('varName must be a string scalar or character row vector.');
            end
            ncNames = cell( numel(info.Variables), 1 );
            [ncNames{:}] = deal( info.Variables.Name );        
            ncNames = string( ncNames );
            [isvar, v] = ismember( varName, ncNames );
            if ~isvar
                error('The file %s does not contain a %s variable.', filename, varName );
            end
            obj.varName = varName;
            
            % Ensure the data field is numeric or logical
            if ~ismember( info.Variables(v).Datatype, [gridData.numericTypes;"logical"] )
                error('The %s variable is neither numeric nor logical.', varName );
            end
            
            % Get the data size. Remove any trailing singletons
            siz = info.Variables(v).Size;
            obj.size = gridData.squeezeSize( siz );
            
            % Check there is a dimension for all non-trailing singletons.
            % Add a singleton for any extra dimensions.
            if ~isstrlist( dimOrder )
                error('dimOrder must be a vector that is a string, cellstring, or character row');
            end
            dimOrder = string(dimOrder);
            nExtra = numel(dimOrder) - numel(siz);
            if nExtra < 0
                error('There are %.f named dimensions, but the netcdf variable has more (%.f) dimensions.', numel(dimOrder), numel(siz) );
            else
                obj.size = [obj.size, ones(1,nExtra)];
            end 
            obj.dimOrder = dimOrder;

            % Also record the dimensions within the NetCDF file
            ncDim = cell( numel(info.Variables(v).Dimensions), 1 );
            [ncDim{:}] = deal( info.Variables(v).Dimensions.Name );
            obj.ncDim = string( ncDim );
        end
    end
    
    % Utilities
    methods
        
        % Reads data from the netcdf file
        [X, passVal] = read( obj, scs, ~, ~ )
        
        % Adjust scs for nc dimensions
        [scs] = trimSCS( obj, scs );
        
    end
    
end