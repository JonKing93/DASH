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
        
            if ~ismember(var, fileVars)
                error('DASH:dataSource:hdf:variableNotInFile', ...
                    'The file "%s" does not have a "%s" variable', obj.source, var);
            end
            obj.var = var;
        end
    end
end