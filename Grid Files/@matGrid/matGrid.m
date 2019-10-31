classdef matGrid < gridData
    % Describes a data source that is a .mat file
    
    properties (SetAccess = private)
        filepath; % The filepath for the netcdf
        filename; % The name of the file. Used for error messages
        varName; % The name of the gridded data variable in the file
    end
    
    % Constructor
    methods
        function[obj] = matGrid( filename, varName, dimOrder )
            % Creates a new ncGrid object
            %
            % obj = ncGrid( filename, varName, dimOrder )
            %
            % ----- Inputs -----
            %
            % filename: The name of the .mat file
            %
            % varname: The name of the variable in the .mat file
            %
            % dimOrder: The order of the dimensions of the variable in the
            %           .mat file. Must use the names from getDimIDs.m
            %
            % ----- Outputs -----
            %
            % obj: The new matGrid object.
            
            % Check that the file exists, get the full path
            if ~isstrflag( filename )
                error('filename must be a string scalar or character row vector.');
            elseif ~exist( filename, 'file' )
                error('The file %s does not exist. It may be misspelled or not on the active path.', filename );
            end
            obj.filepath = which( filename );
            obj.filename = filename;
            
            % Check that the file is actually matfile V7.3
            try
                m = matfile( filename );
            catch ME
                error('The file %s is not a valid .mat file.', filename );
            end
            
            % Check that the variable name is allowed and exists
            if ~isstrflag( varName )
                error('varName must be a string scalar or character row vector.');
            end
            names = string( who(m) );
            [isvar] = ismember( varName, names );
            if ~isvar
                error('The file %s does not contain a %s variable.', filename, varName );
            end
            obj.varName = varName;
            
            % Check the data is numeric or logical
            if ~isnumeric( m.(varName) ) && ~islogical( m.(varName) )
                error('The variable %s is neither numeric nor logical.', varName );
            end
            
            % Get the data size. Remove any trailing singletons
            siz = size( m.(varName) );
            obj.size = gridData.squeezeSize( siz );
            
             % Check there is a dimension for all non-trailing singletons
            if ~isstrlist( dimOrder )
                error('dimOrder must be a vector that is a string, cellstring, or character row');
            end
            dimOrder = string(dimOrder);
            nExtra = numel(dimOrder) - numel(siz);
            if nExtra < 0
                error('There are %.f named dimensions, but the .mat variable has more (%.f) dimensions.', numel(dimOrder), numel(siz) );
            else
                obj.size = [obj.size, ones(1,nExtra)];
            end 
            obj.dimOrder = dimOrder;
        end
    end
    
    % Utilities
    methods
        X = read( obj, start, count, stride, ~ );
    end
    
end