classdef matSource < dataSource
    %% Reads data from a .mat file data source
    
    properties
        m; % A matfile object
    end
    properties (Constant, Hidden)
        % Used to toggle the inefficient partial load warning.
        warnID = 'MATLAB:MatFile:OlderFormat';
    end
    
    methods
        function obj = matSource(file, var, dims, fill, range, convert)
            %% Creates a new matSource object. Checks the matfile is valid
            % and contains the required variable
            %
            % obj = matSource(file, var, dims, fill, range, convert)
            %
            % ----- Inputs -----
            %
            % file: The name of the .mat file. A string.
            %
            % var: The name of the variable in the .mat file. A string.
            %
            % dims, fill, range, convert: See the documentation in dataSource
            %
            % ----- Outputs -----
            %
            % obj: The new matSource object
            
            % Constructor and error checks
            obj@dataSource(file, 'file', dims, fill, range, convert);
            obj = obj.checkFile;
            obj = obj.setVariable(var);
            
            % Use chars to access matfile variables
            obj.var = char(obj.var);
            
            % Check the file is a matfile
            try
                obj.m = matfile(obj.source);
            catch
                error('The file %s is not a valid .mat file.', obj.source);
            end
            
            % Check the variable is in the file
            fileVariables = string(who(obj.m));
            obj.checkVariableInSource(fileVariables);
            
            % Get the data type and size of the array
            info = whos(obj.m, obj.var);
            obj.dataType = info.class;
            obj.unmergedSize = info.size;
            
            % Warn the user if this is not v7.3
            warn = warning('query', obj.warnID);
            warning('error', obj.warnID);
            firstIndex = repmat({1}, [1, numel(obj.unmergedSize)]);
            try
                obj.m.(obj.var)(firstIndex{:});
            catch
                warning(['File %s is not a version 7.3 .mat file. Version 7.3 ',...
                    'is STRONGLY recommended for use with DASH. Consider saving .mat files ',...
                    'with the ''-v7.3'' flag or use dash.convertToV7_3 to convert existing .mat ',...
                    'files to a v7.3 format. For more details, see the Matlab documention on "save" ',...
                    'and "MAT-File versions".'], obj.source);
            end
            warning( warn.state, obj.warnID );
        end
        function[X, obj] = load( obj, indices )
            %% Loads data from a .mat data source.
            %
            % X = obj.load(indices)
            %
            % ----- Inputs -----
            %
            % indices: A cell array. Each element contains the linear 
            %    indices to load for a dimension. Indices must be equally
            %    spaced and monotonically increasing. Dimensions must be in
            %    the order of the unmerged dimensions.
            %
            % ----- Outputs -----
            %
            % X: The data located at the requested indices.
            
            % Disable the partial load warning
            warn = warning('query', obj.warnID);
            warning('off', obj.warnID);
            
            % Load the data
            X = obj.m.(obj.var)(indices{:});
            
            % Restore the original warning state
            warning(warn.state, obj.warnID);
        end
    end
    
end