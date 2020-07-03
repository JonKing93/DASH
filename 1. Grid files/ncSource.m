classdef ncSource < dataSource
    %% Implements a NetCDF data source
    
    methods
        % Constructor
        function obj = ncSource(file, var, dims)
            
            % First call the data source constructor for initial error
            % checking and to save the input args
            obj@dataSource(file, var, dims);
            
            % Check the file is actually a NetCDF
            try
                info = ncinfo( obj.file );
            catch
                error('The file %s is not a valid NetCDF file.', obj.file );
            end
            
            % Check that the variable is in the file
            nVars = numel(info.Variables);
            fileVariables = cell(nVars,1);
            [fileVariables{:}] = deal( info.Variables.Name );
            obj.checkVariable( fileVariables );
            
            % Get the data type and size of the array
            [~,v] = ismember(obj.var, fileVariables);
            obj.dataType = info.Variables(v).Datatype;
            obj.unmergedSize = info.Variables(v).Size;
        end
        
        % Read from NetCDF
        function[X] = readSource(obj, start, count, stride)
            %% Reads data from a netCDF data source.
            %
            % X = obj.readSource(start, count, stride)

            % Adjust start, count, and stride to match the number of 
            % dimensions defined in the netCDF file.
            nDims = size(start,2);
            scs = [start;count;stride];

            if nDims > obj.nDims
                scs = scs(:,1:obj.nDims);
            elseif nDims < obj.nDims
                scs(:, (end+1):obj.nDims) = 1;
            end

            % Read from the netcdf file
            X = ncread( obj.file, obj.var, scs(1,:), scs(2,:), scs(3,:) );
        end
    end
    
end