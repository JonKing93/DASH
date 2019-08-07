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
    %   overlap - Whether a variable permits overlapping, non-duplicate
    %             sequences in the ensemble.
    %   
    % stateDesign Methods:
    %    stateDesign - Creates a new stateDesign object.
    %    add - Adds a variable to the state vector
    %    edit - Edits the design specifications for a variable.
    %    copy - Copies design specifications from a template variable to
    %           other variables.
    %    disp - Displays information about the state vector.
    %    couple - Couples specified variables to one another.
    %    uncouple - Uncouples specified variables from all other variables.
    %    remove - Removes a variable from the state vector.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    % User can see, but not touch.
    properties (SetAccess = private)
        name;       % An identifier for the state vector.
        var;        % The array of variable designs
        varName;    % The names of the variables in the design.
        isCoupled;  % Notes whether variables are coupled
        autoCouple;  % Whether the variable should be automatically coupled to new variables.
        overlap;    % Whether the variable permits overlapping non-duplicate sequences
    end
    
    % Constructor block.
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
            
            % Initialize logical arrays
            obj.isCoupled = logical([]);
            obj.autoCouple = logical([]);
        end
    end
    
    % User methods.
    methods
        
        % Adds a new variable to the state vector.
        obj = add( obj, varName, file, autoCouple );
        
        % Edits the design specifications of a variable in the state vector.
%         obj = edit( obj, varName, dim, dimType, varargin );
        
        % Copies indices from one variable to other variables.
        obj = copy( obj, fromVar, toVars );
        
        % Displays information about the state vector
%         obj = disp( obj, varName, dim, longform );
        
        % Couples specified variables.
        obj = couple( obj, varNames, varargin );
        
        % Uncouples specified variables.
        obj = uncouple( obj, varNames, varargin );
        
        % Removes a variable from the state vector.
        obj = remove( obj, varName );        
    end
    
    % Internal utility methods
    methods (Access = private)
        
        % Edit design for a state dimension
        obj = stateDimension( obj, varName, dim, varargin );
        
        % Edit design for an ensemble dimension
        obj = ensDimension( obj, varName, dim, varargin );
        
        % Find the index of a variable in the list of variables in the
        % state vector.
        v = findVarIndices( obj, varName );
        
        % Find the index of a dimension in the list of variables
        d = findDimIndices( obj, v, dim );
        
        % Process indices for internal use
        index = checkIndices( obj, index );
        
        % Notify the user when sequence and mean data are deleted for
        % coupled dimensions that change type.
        notifyChangedType( obj, v, d );
        
        % Notify the user when secondary variables are coupled
        notifySecondaryCoupling( obj, v, vall );
    end
        
end