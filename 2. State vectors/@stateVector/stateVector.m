classdef stateVector
    % A class that designs and builds a state vector from data stored in
    % .grid files.
    %
    % stateVector Methods:
    %    stateVector - Initializes a new state vector design.
    
    properties
        title; % An optional identifier for the state vector
        variables; % The array of variable designs
        allowOverlap; % Whether the variable allows the same data to be used in multiple ensemble members
        coupled; % Notes which variables are coupled
    end
    
    % Constructor
    methods
        function obj = stateVector( title )
            % Creates a new state vector design.
            %
            % obj = stateVector;
            % Initializes a new stateVector object.
            %
            % obj = stateVector(title)
            % Includes an identifying title.
            %
            % ----- Inputs -----
            %
            % name: An optional title for the state vector. A string scalar
            %    or character row vector.
            %
            % ----- Outputs -----
            %
            % obj: A new, empty stateVector object.
            
            % Default for title
            if ~exist('title','var') || isempty(title)
                title = "";
            end
            
            % Error check and save
            dash.assertStrFlag(title, 'title');
            obj.title = string(title);
            
        end
    end
    
    % Object utilities
    methods
        varNames = variableNames(obj);
        v = checkVariables(obj, varNames, multiple);
        str = errorTitle(obj);
    end
    
    % User methods
    methods
        obj = add(obj, varName, file);
        obj = design(obj, varName, dim, type, indices);
        obj = sequence(obj, varName, dim, indices, metadata);
    end
     
end