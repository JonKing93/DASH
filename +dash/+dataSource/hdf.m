classdef (Abstract) hdf < dash.dataSource.Base
    %% dash.dataSource.hdf  Superclass for objects that read data from HDF files
    %
    %   dash.dataSource.hdf is abstract. It's primary function is to 
    %   check that the variable being read from the HDF file actually
    %   exists in the file.
    %
    %   hdf Properties:
    %     var - The name of the variable in the HDF file
    %   
    %   hdf Methods:
    %     setVariable - Ensure a variable exists in an HDF file
    %
    %   <a href="matlab:dash.doc('dash.dataSource.hdf')">Online Documentation</a>
    
    properties (SetAccess = private)
        var;    % The name of the variable in the HDF file
    end
    
    methods
        function[obj] = setVariable(obj, var, fileVars)
        %% dash.dataSource.hdf.setVariable  Ensure variable exists in HDF file
        %
        %   obj = obj.setVariable(var, fileVars)
        %   Checks that a variable being loaded is in the list of variables
        %   in a HDF file. If not, throws an error. If so, saves the
        %   variable name.
        %
        %   <a href="matlab:dash.doc('dash.dataSource.hdf.setVariable')">Online Documentation</a>
        
            if ~ismember(var, fileVars)
                error('DASH:dataSource:hdf:variableNotInFile', ...
                    'The file "%s" does not have a "%s" variable', obj.source, var);
            end
            obj.var = var;
        end
    end
    methods (Sealed)
        function[X] = load(obj, indices)
        %% dash.dataSource.hdf.load  Load data from a HDF5 source
        %
        %   X = obj.load(indices)
        %   Loads data from a HDF source at the requested linear indices.
        %   Acquires data along strided intervals but only returns requested indices.
        %
        %   <a href="matlab:dash.doc('dash.dataSource.hdf.load')">Online Documentation</a>
            
            % Preallocate
            nDims = numel(indices);
            loadIndices = cell(nDims, 1);
            keep = cell(nDims, 1);
            
            % Get strided indices along each dimension
            for d = 1:nDims
                loadIndices{d} = dash.indices.strided(indices{d});
                keep{d} = dash.indices.keep(indices{d}, loadIndices{d});
            end
            
            % Load strided elements, but only keep requested indices
            X = obj.loadStrided(loadIndices);
            X = X(keep{:});
            
        end
    end
    methods (Abstract)
        
        % dash.dataSource.hdf.loadStrided  Loads data from a HDF source at strided indices
        %
        %   X = <strong>obj.load</strong>(stridedIndices)
        %   Loads data from a HDF source at specified strided linear indices
        %
        %   <a href="matlab:dash.doc('dash.dataSource.hdf.loadStrided')">Online Documentation</a>
        X = loadStrided(obj, indices)
        
    end
    
end