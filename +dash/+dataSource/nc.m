classdef nc < dash.dataSource.hdf
    %% dash.dataSource.nc  Objects that read data from NetCDF files
    % ----------
    % nc Methods:
    %
    % General:
    %   nc          - Create a new dash.dataSource.nc object
    %   loadStrided - Load data from a NetCDF file at strided indices
    %
    % Inherited:
    %   load        - Load data from a HDF5 file
    %   setVariable - Ensure the variable exists in the NetCDF file
    %
    % <a href="matlab:dash.doc('dash.dataSource.nc')">Documentation Page</a>

    properties (SetAccess = private)
        hasdims = true;  % Whether the variable has dimensions
    end
    
    methods
        function[obj] = nc(source, var)
        %% dash.dataSource.nc.nc  Create a new dash.dataSource.nc object
        % ----------
        %   obj = <strong>dash.dataSource.nc</strong>(file, var)
        %   Creates a nc object to read data from a variable in a NetCDF file
        %
        %   obj = <strong>dash.dataSource.nc</strong>(opendapURL, var)
        %   Creates an nc object to read data from a variable stored in a
        %   NetCDF file accessed via an OPENDAP url.
        % ----------
        %   Inputs:
        %       file (string scalar): The name of a NetCDF file
        %       url (string scalar): An OPENDAP url to a NetCDF file.
        %       var (string scalar): The name of the variable in the file
        %
        %   Outputs:
        %       obj (scalar dash.dataSource.nc object): The new nc object
        %
        %   Throws:
        %       DASH:dataSource:nc:invalidNetCDF  when file is not a valid NetCDF
        %
        % <a href="matlab:dash.doc('dash.dataSource.nc.nc')">Documentation Page</a>
            
            % Error check
            header = "DASH:dataSource:nc";
            source = dash.assert.strflag(source, 'file', header);
            var = dash.assert.strflag(var, 'var', header);
            
            % Check local files exist, but don't check OPENDAP URLs
            if dash.is.url(source)
                obj.source = source;
            else
                obj.source = dash.assert.fileExists(source, ".nc", header);
            end
            
            % Check the file is a valid NetCDF
            try
                info = ncinfo(obj.source);
            catch
                id = sprintf('%s:invalidNetCDF', header);
                error(id, ['The file:  %s\n',...
                           'is not a valid NetCDF file.'], obj.source);
            end
            
            % Check the variable is valid. Get its index
            fileVars = string({info.Variables.Name});
            obj = obj.setVariable(var, fileVars);
            [~,v] = ismember(obj.var, fileVars);

            % Note if the variable has no dimensions
            if isempty(info.Variables(v).Dimensions)
                obj.hasdims = false;
            end

            % Get the data type and size
            obj.dataType = info.Variables(v).Datatype;
            obj.size = info.Variables(v).Size;
        end
        function[X] = loadStrided(obj, indices)
        %% dash.dataSource.nc.loadStrided  Load data from a NetCDF file at strided indices
        % ----------
        %   X = <strong>obj.loadStrided</strong>(stridedIndices)
        %   Load data from the variable in the NetCDF file at the specified strided indices
        % ----------
        %   Inputs:
        %       stridedIndices (cell vector [nDims] {vector, strided linear indices}):
        %           The indices of data elements along each dimension to load from 
        %           the NetCDF file. Should have one element per dimension of the variable.
        %           Each element holds a vector of strided linear indices.
        %
        %   Outputs:
        %       X (array): The loaded data
        %
        % <a href="matlab:dash.doc('dash.dataSource.nc.loadStrided')">Documentation Page</a>

            % Load dimensionless scalars directly to avoid start/count/stride bugs in ncread 
            if ~obj.hasdims
                X = ncread(obj.source, obj.var);
                return
            end
            
            % Add any missing indices for trailing singletons
            nMissing = numel(obj.size) - numel(indices);
            if nMissing > 0
                indices = [indices, repmat({1}, 1, nMissing)];
            end
        
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