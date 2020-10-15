classdef matSource < dataSource
    %% Implements a data source object that can read values from .mat files.
    
    properties
        m; % A matfile object
    end
    properties (Constant, Hidden)
        % Used to toggle the inefficient partial load warning.
        warnID = 'MATLAB:MatFile:OlderFormat';
    end
    
    methods
        function obj = matSource(file, var, dims, fill, range, convert)
            %% Creates a new matSource object.
            %
            % obj = matSource(file, var, dims, fill, range, convert)
            %
            % ----- Inputs -----
            %
            % See the documentation in dataSource.new
            %
            % ----- Outputs -----
            %
            % obj: A new matSource object.
            
            % First call the data source constructor for initial error
            % checking and to save the input args
            obj@dataSource(file, var, dims, fill, range, convert);
            
            % Matfile access is via chars
            obj.var = char(obj.var);
            
            % Check that the file is a matfile
            try
                obj.m = matfile(file);
            catch
                error('The file %s is not a valid .mat file.', file);
            end
            
            % Check the variable is in the file
            fileVariables = string(who(obj.m));
            obj.checkVariable( fileVariables );
            
            % Get the data type and size of the array
            info = whos(obj.m, obj.var);
            obj.dataType = info.class;
            obj.unmergedSize = info.size;
            
            % Warn the user if this is not v7.3
            warn = warning('query', obj.warnID);
            warning('error', obj.warnID); %#ok<CTPCT>
            firstIndex = repmat({1}, [1, numel(obj.unmergedSize)]);
            try
                obj.m.(obj.var)(firstIndex{:});
            catch
                warning('File %s is not a version 7.3 .mat file. Version 7.3 is STRONGLY recommended for use with dash. Consider saving .mat files with the ''-v7.3'' flag or use dash.convertToV7_3 to convert existing .mat files to a v7.3 format. For more details, see the Matlab documention on "save" and "MAT-File versions".', obj.file);
            end
            warning( warn.state, obj.warnID );  
            
        end        
        function[X] = load( obj, indices )
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
            
            % Disable the partial load warning and load
            warn = warning('query', obj.warnID);
            warning('off', obj.warnID);
            X = obj.m.(obj.var)(indices{:});
            
            % Restore the original warning state
            warning(warn.state, obj.warnID);
        end
    end
    
end