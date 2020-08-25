classdef stateVectorVariable
    % This class implements a custom structure to hold design parameters
    % for a variable in a state vector.
    
    properties (SetAccess = private)
        name;  % The identifying name of the variable
        
        file; % Name of the .grid file
        dims; % .grid file dimension order
        size; % .grid file size
        
        isState; % Whether a dimension is a state dimension
        stateIndices; % Data indices to use for state dimensions
        ensIndices; % Reference indices to use for ensemble dimensions
        
    end
    
    % Constructor
    methods
        function obj = stateVectorVariable(varName, file)
            % Creates a new stateVectorVariable object for data in a .grid
            % file.
            %
            % obj = stateVectorVariable(varName, file);
            %
            % ----- Inputs -----
            %
            % varName: The name of the variable. A string.
            %
            % file: The name of the .grid file that holds the variable
            %
            % ----- Outputs -----
            %
            % obj: The new stateVectorVariable object
            
            % Error check
            dash.assertStrFlag(varName, 'varName');
            dash.assertStrFlag(file, 'file');
            file = dash.checkFileExists(file);
            
            % Name. Use string internally
            obj.name = string(varName);
            
            % Get gridfile properties
            grid = gridfile(file);
            obj.file = grid.file;
            obj.dims = grid.dims;
            obj.size = grid.size;
            
            % Initialize dimension properties
            nDims = numel(obj.dims);
            obj.isState = true(1, nDims);
            obj.stateIndices = cell(1, nDims);
            obj.ensIndices = cell(1, nDims);
        end
    end
    
    % Object utilities
    methods
        d = dimensionIndex(obj, dims);
    end
    
    % Interface methods
    methods
        obj = design(obj, dim, type, indices);
    end
end
        