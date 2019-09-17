classdef stateDesign
    % stateDesign
    % Stores design specifications and parameters for a state vector
    % containing multiple variables.
    %
    % stateDesign Methods:
    %    stateDesign - Creates a new stateDesign object.
    %    add - Adds a variable to the state vector
    %    edit - Edits the design specifications for a variable.
    %    copy - Copies design specifications from a template variable to
    %           other variables.
    %    info - Displays information about the state vector.
    %    remove - Removes a set of variables from the state vector.
    %    couple - Couples specified variables to one another.
    %    uncouple - Uncouples specified variables from all other variables.
    %    buildEnsemble - Build an ensemble from the design.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    %
    % ----- Additional Documentation -----
    %
    % stateDesign Properties:
    %   name - An identifying name for the state vector
    %   var - An array of variable designs. These contain the design
    %        specifications for how data should be read from .grid files
    %        into a state vector.
    %   varName - The names of the variables in the state design.
    %   isCoupled - Notes whether variables are coupled. Coupled variables
    %              are selected from the same ensemble indices for each
    %              ensemble member.
    %   autoCouple - Notes whether a variable should automatically be
    %               coupled to new variables. Default is true.
    %   overlap - Whether a variable permits overlapping, non-duplicate
    %             sequences in the ensemble.
    %   new - Records whether a stateDesign has previously selected ensemble
    %         draws.

    
    % User can see, but not touch.
    properties (SetAccess = private)
        name;       % An identifier for the state vector.
        var;        % The array of variable designs
        varName;    % The names of the variables in the design.
        isCoupled;  % Notes whether variables are coupled
        autoCouple; % Whether the variable should be automatically coupled to new variables.
        overlap;    % Whether the variable permits overlapping non-duplicate sequences
        new;        % Whether the design has previously selected ensemble draws.
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
            
            % No ensembles yet..
            obj.new = true;
        end
    end
    
    % User methods.
    methods
        
        % Adds a new variable to the state vector.
        obj = add( obj, varName, file, autoCouple );
        
        % Edits the design specifications of a variable in the state vector.
        obj = edit( obj, varName, dim, dimType, varargin );
        
        % Copies indices from one variable to other variables.
        obj = copy( obj, fromVar, toVars );
        
        % Displays information about the state vector
        obj = info( obj, varName, dim, longform );
        
        % Couples specified variables.
        obj = couple( obj, varNames, varargin );
        
        % Uncouples specified variables.
        obj = uncouple( obj, varNames, varargin );
        
        % Removes a set of variables from the state vector.
        obj = remove( obj, varNames );       
        
        % Create an ensemble from the design.
        ens = buildEnsemble( obj, nEns, ordered );
        
        % Adjusts a variable's overlap permissions
%         obj = overlap( obj, varName );
    end
    
    % Internal utility methods
    methods (Access = private)
        
        %% General
        
        % Find the index of a variable in the list of variables in the
        % state vector.
        v = findVarIndices( obj, varName );
        
        % Find the index of a dimension in the list of variables
        d = findDimIndices( obj, v, dim );
        
        
        %% Editing
        
        % Edit design for a state dimension
        obj = stateDimension( obj, varName, dim, varargin );
        
        % Edit design for an ensemble dimension
        obj = ensDimension( obj, varName, dim, varargin );
        
        % Process indices for internal use
        index = checkIndices( obj, index, v, d );
        
        % Implements nanflag behavior for complex edits.
        nanflag = getNaNflag( obj, v, d, nanflag, inArgs )
        
        
        %% Coupling
        
        % Flips a dimension and applies to all coupled variables.
        obj = changeDimType( obj, v, d );
        
        % Flips type, deletes mean and sequence data, notifies user.
        obj = resetChangedDim( obj, var, d );
        
        
        %% Notifications
        
        % Notify the user when sequence and mean data are deleted for
        % coupled dimensions that change type.
        notifyChangedType( obj, v, d, cv );
        
        % Notify the user when secondary variables are coupled
        notifySecondaryCoupling( obj, v, vall );
        
        
        %% Building Ensembles
        
        % Removes ensemble indices that don't allow a full sequence
        obj = trim( obj );
        
        % Returns the variable indices of each set of coupled variables.
        cv = coupledVariables( obj );
        
        % Restricts a set of coupled variables to ensemble indices with 
        % matching metadata
        obj = matchMetadata( obj, cv );
        
        % Initializes an array of draws for a design.
        [overlap, ensSize, undrawn, subDraws] = initializeDraws( obj, cv, nDraws );
        
        % Selects a set of N-D subscripted draws
        [subDraws, undrawn] = draw( obj, nDraws, subDraws, undrawn, random, ensSize );
        
        % Removes overlapping draws from an ensemble
        subDraws = removeOverlap( obj, subDraws, cv )
        
        % Saves finalized draws to variables
        obj = saveDraws( obj, cv, subDraws );
        
        %% Ensemble metadata
        
        % Returns the state vector index limits and dimensional size of
        % each variable.
        [varLimits, varSize] = varIndices( obj );
        
        % Get the metadata associated with each variable
        meta = varMetadata( obj );
        
        %% Writing ensemble
        
        % Determines which indices to read from for efficient loading.
        [start, count, stride, keep] = loadingIndices( obj );
        
    end
        
end