classdef (Abstract) hdf < dash.dataSource.Interface
    %% dash.dataSource.hdf  Superclass for objects that read data from HDF5 files
    % ----------
    %   dash.dataSource.hdf is abstract. It's primary function is to 
    %   check that the variable being read from the HDF file actually
    %   exists in the file. It also enables strided loading.
    % ----------
    % hdf Methods:
    %   setVariable - Ensure a variable exists in an HDF file
    %   load        - Load data from a HDF5 source
    %
    % Abstract:
    %   loadStrided - Load data from a HDF source at strided indices
    %
    % <a href="matlab:dash.doc('dash.dataSource.hdf')">Documentation Page</a>
    
    properties (SetAccess = private)
        var;    % The name of the variable in the HDF file
    end
    
    methods
        function[obj] = setVariable(obj, var, fileVars)
        %% dash.dataSource.hdf.setVariable  Ensure variable exists in HDF file
        % ----------
        %   obj = <strong>obj.setVariable</strong>(var, fileVars)
        %   Checks that a variable being loaded is in the list of variables
        %   in a HDF file. If not, throws an error. If so, saves the
        %   variable name.
        % ----------
        %   Inputs:
        %       var (string scalar): Name of the variable to load from the file
        %       fileVars (string vector): List of variables in the file
        %
        %   Outputs:
        %       obj: Updated with the saved variable name
        %
        %   Throws:
        %       DASH:dataSource:hdf:variableNotInFile -  when the named variable is
        %           not in the file
        %
        %   <a href="matlab:dash.doc('dash.dataSource.hdf.setVariable')">Documentation Page</a>
        
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
        % ----------
        %   X = <strong>obj.load</strong>(indices)
        %   Loads data from a HDF source at the requested linear indices.
        %   Acquires data along strided intervals but only returns requested indices.
        % ----------
        %   Inputs:
        %       indices (cell vector [nDims] {vector, linear indices}):
        %           The indices of data elements along each dimension to load from 
        %           the HDF5 file. Should have one element per dimension of the variable.
        %           Each element holds a vector of linear indices.
        %
        %   Outputs:
        %       X (array): The loaded data
        %
        %   <a href="matlab:dash.doc('dash.dataSource.hdf.load')">Documentation Page</a>
            
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
        
        %% dash.dataSource.hdf.loadStrided  Load data from a HDF source at strided indices
        % ----------
        %   X = <strong>obj.loadStrided</strong>(stridedIndices)
        %   Loads data from a HDF source at specified strided linear indices
        % ----------
        %   Inputs:
        %       stridedIndices (cell vector [nDims] {vector, strided linear indices}):
        %           The indices of data elements along each dimension to load from 
        %           the HDF5 file. Should have one element per dimension of the variable.
        %           Each element holds a vector of strided linear indices.
        %
        %   Outputs:
        %       X (array): The loaded data
        %
        %   <a href="matlab:dash.doc('dash.dataSource.hdf.loadStrided')">Documentation Page</a>
        X = loadStrided(obj, indices)
        
    end
    
end