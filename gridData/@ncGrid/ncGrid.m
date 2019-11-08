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
            
            % Check the dimension names, and that there are enough
            if ~isstrlist( dimOrder )
                error('dimOrder must be a vector that is a string, cellstring, or character row');
            end
            dimOrder = string(dimOrder);
            nNCdim = numel( info.Variables(v).Dimensions );
            if numel( dimOrder ) < nNCdim
                error('There are %.f named dimensions, but the netcdf variable has more (%.f) dimensions.', numel(dimOrder), nNCdim );
            end
            
            % Get the size of the dataset before dimensions are merged
            siz = info.Variables(v).Size;
            obj.unmergedSize = siz;
            
            % Note which dimensions are merged, get the merged size
            [uniqDim] = unique( dimOrder, 'stable' );
            merge = NaN( 1, numel(dimOrder) );
            for d = 1:numel(uniqDim)
                loc = find(strcmp( uniqDim(d), dimOrder ));
                merge(loc) = d;
                if numel(loc) > 1
                    siz( loc(1) ) = prod( siz(loc) );
                    siz( loc(2:end) ) = NaN;
                end
            end
            obj.dimOrder = uniqDim;
            obj.merge = merge;
            
            % Remove unassigned trailing singletons, pad with TS to match
            % number of input dimensions
            siz = siz( ~isnan(siz) );
            obj.size = gridData.squeezeSize( siz );
            obj.unmergedSize = gridData.squeezeSize( obj.unmergedSize );
            
            nExtraM = numel(uniqDim) - numel(obj.size);
            nExtraUM = numel(dimOrder) - numel(obj.unmergedSize);
            if nExtraM > 0
                obj.size = [obj.size, ones(1,nExtraM)];
            end
            if nExtraUM > 0
                obj.unmergedSize = [obj.unmergedSize, ones(1, nExtraUM)];
            end

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