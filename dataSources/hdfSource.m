classdef (Abstract) hdfSource
    %% Used to read data from HDF based sources like NetCDF and .mat. 
    % Checks that data sources have required variable names.
    
    % In a future release, this will probably implement equally spaced
    % indices, etc.
    
    properties
        source; % The source of the data. A file or opendap url
        var; % The name of the variable in the data source
    end
    
    methods
        function obj = hdfSource(source, var)
            %% Creates a new hdfSource object. Ensures that the source and
            % variable name are strings.
            %
            % obj = hdfSource(source, var)
            %
            % ----- Inputs -----
            %
            % source: The identifier for the dataSource. A filename or
            %    OPeNDAP url. A string.
            %
            % var: The name of a variable in the data source. A string.
            %
            % ----- Outputs -----
            %
            % obj: The new hdfSource

            obj.source = dash.assertStrFlag(source, "source");
            obj.var = dash.assertStrFlag(var, "var");
        end
        function[] = checkVariable(obj, sourceVariables)
            %% Checks that the variable is in a list of variables for the 
            % data source. Returns an error if not
            %
            % obj.checkVariable(sourceVariables)
            %
            % ----- Inputs -----
            %
            % sourceVariables: A list of variables in the data source. A
            %    string vector or cellstring vector.
            
            if ~ismember(obj.var, sourceVariables)
                error('The data at source "%s" does not contain a %s variable.', obj.source, obj.var);
            end    
        end
    end
    
    methods (Abstract)
        checkVariableInSource(obj); % Require hdfSources to check the variable is in the source
    end
    
end
            