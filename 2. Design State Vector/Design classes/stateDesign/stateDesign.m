classdef stateDesign
    % stateDesign
    % Stores design specifications and parameters for a state vector
    % containing multiple variables.
    %
    % stateDesign Properties:
    %   name - An identifying name for the state vector
    %
    %   var - An array of variable designs. These contain the design
    %        specifications for how data should be read from .grid files
    %        into a state vector.
    %
    %   varName - The names of the variables in the state design.
    %
    %   isCoupled - Notes whether variables are coupled. Coupled variables
    %              are selected from the same ensemble indices for each
    %              ensemble member.
    %
    %   autoCouple - Notes whether a variable should automatically be
    %               coupled to new variables. Default is true.
    %   
    % stateDesign Methods:
    %    stateDesign - Creates a new stateDesign object.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    properties (Access = private)
        name;       % An identifier for the state vector.
        var;        % The array of variable designs
        varName;    % The names of the variables in the design.
        isCoupled;  % Notes whether variables are coupled
        autoCouple;  % Whether the variable should be automatically coupled to new variables.
    end
    
    
    methods
        function obj = stateDesign( name )
            % Constructor for a stateDesign object.
            %
            % obj = stateDesign( name )
            % Creates an empty stateDesign object and assigns an
            % identifying name.
            %
            % ----- Inputs -----
            %
            % name: An identifying name for the stateDesign. Either a
            %       string scalar or character row vector.
            %
            % ----- Outputs -----
            % 
            % obj: The new, empty stateDesign object.
            
            % Check that the name is allowed
            if ~isstrflag(name)
                error('The stateDesign name must be a string.');
            end
            
            % Set the name
            obj.name = name;
            
            % Initialize logical arrays as logical
            obj.isCoupled = logical([]);
            obj.autoCouple = logical([]);
        end
    end
end