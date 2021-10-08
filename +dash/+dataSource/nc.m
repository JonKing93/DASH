classdef nc < dash.dataSource.hdf
    %% dash.dataSource.nc  Objects that read data from NetCDF files
    %
    %   nc Methods:
    %              nc - Create a new dash.dataSource.nc object
    %     loadStrided - Load data from a NetCDF file at strided intervals
    %
    %   <a href="matlab:dash.doc('dash.dataSource.hdf')">Online Documentation</a>
    
    methods
        function[obj] = nc(file, var)
        %% dash.dataSource.nc.nc  Create a new dash.dataSource.nc object
        % ----------
        %   obj = dash.dataSource.nc(file, var)
        %   Creates a nc object to read data from a variable in a NetCDF file
        % ----------
        %   Inputs:
        %       file (string scalar): The name of a NetCDF file
        %       var (string scalar): The name of the variable in the file
        %
        %   Outputs:
        %       obj: A new dash.dataSource.nc object
        %
        %   Throws:
        %       DASH:dataSource:nc:invalidNetCDF  when file is not a valid NetCDF
        %
        %   <a href="matlab:dash.doc('dash.dataSource.nc.nc')">Online Documentation</a>
            
            % Error check
            header = "DASH:dataSource:nc";
            dash.assert.strflag(file, 'file', header);
            var = dash.assert.strflag(var, 'var', header);
            obj.source = dash.assert.fileExists(file, header, '.nc');
            
            % Check the file is a valid NetCDF
            try
                info = ncinfo(obj.source);
            catch problem
                ME = MException(sprintf('%s:invalidNetCDF',header), ...
                    'The file "%s" is not a valid NetCDF file', obj.source);
                ME = addCause(ME, problem);
                throw(ME);
            end
            
            % Check the variable is valid
            fileVars = string({info.Variables.Name});
            obj = obj.setVariable(var, fileVars);
            
            % Get data type and size
            [~,v] = ismember(obj.var, fileVars);
            obj.dataType = info.Variables(v).Datatype;
            obj.size = info.Variables(v).Size;
        end
        function[X] = loadStrided(obj, indices)
        %% dash.dataSource.nc.loadStrided  Load data from a NetCDF file at strided indices
        % ----------
        %   X = obj.loadStrided(stridedIndices)
        %   Load data from the variable in the NetCDF file at the specified strided indices
        % ----------
        %   Inputs:
        %       indices (vector, strided linear indices): The indices of the data
        %           elements to load from the NetCDF
        %
        %   Outputs:
        %       X (array): The loaded data
        %
        %   <a href="matlab:dash.doc('dash.dataSource.nc.loadStrided')">Online Documentation</a>
            
            % Preallocate
            nDims = numel(indices);
            start = NaN(1, nDims);
            count = NaN(1, nDims);
            stride = ones(1, nDims);
            
            % Get start, count, stride for each set of indices
            for d = 1:nDims
                start(d) = indices{d}(1);
                count(d) = numel(indices{d});
                if numel(indices{d})>1
                    stride(d) = indices{d}(2) - indices{d}(1);
                end
            end
            
            % Load the data
            X = ncread(obj.source, obj.var, start, count, stride);
        end
    end
    
end