classdef stateDesign
    % stateDesign
    % Stores design specifications and parameters for a state vector, and
    % builds ensembles.
    %
    % stateDesign Methods:
    %    stateDesign - Creates a new stateDesign object.
    %    add - Adds a new variable
    %    edit - Edits a the design specifications of a dimension of a variable.
    %    weightedMean - Specify weights for weighted means.
    %    copy - Copies design specifications from a template variable to other variables.
    %    info - Displays information about the state vector.
    %    buildEnsemble - Create an ensemble from the design.
    %
    % Advanced stateDesign Methods:
    %    overlap - Adjust overlap permissions of variables
    %    uncouple - Uncouples specified variables
    %    couple - Couples specified variables
    %    remove - Deletes specified variables from the design.
    %    getVariables - Gets the design associated with specific variables
    %    append - Appends a second stateDesign to the current object
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019
    
    % User can see, but not touch.
    properties (SetAccess = private)
        name;            % An identifier for the state vector.
        var;             % The array of variable designs
        varName;         % The names of the variables in the design.
        allowOverlap;    % Whether the variable permits overlapping non-duplicate sequences
        isCoupled;       % Notes whether variables are coupled
        autoCouple;      % Whether the variable should be automatically coupled to new variables.
        new;             % Whether this is an unwritten stateDesign
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
    
    % Basic user methods.
    methods
        
        % Adds a new variable to the state vector.
        obj = add( obj, varName, file, autoCouple );
        
        % Edits the design specifications of a variable in the state vector.
        obj = edit( obj, varName, dim, dimType, varargin );
        
        % Specify weights for a weighted mean
        obj = weightedMean( var, dims, weights, nanflag );
        
        % Copies indices from one variable to other variables.
        obj = copy( obj, fromVar, toVars );
        
        % Displays information about the state vector
        info( obj, varName, dims, showMeta );    
    
        % Create an ensemble from the design.
        ens = buildEnsemble( obj, nEns, file, random, writeNaN );

    end
    
    % Advanced user methods
    methods
        
        % Adjusts overlap permissions
        obj = overlap( obj, tf, varNames );
        
        % Couples specified variables.
        obj = couple( obj, varNames );
        
        % Uncouples specified variables.
        obj = uncouple( obj, varNames );
        
        % Removes a set of variables from the state vector.
        obj = remove( obj, varNames );   
        
        % Appends a separate state design
        design = append( obj, design );
        
        % Gets the part of a state design associated with specific variables
        design = getVariables( obj, varNames );
        
    end
    
    % Methods to modify the design
    methods
        
        %% Index search and name error checking
        
        % Find the index of a variable in the list of variables in the
        % state vector.
        v = findVarIndices( obj, varName );

        % Find the index of a dimension in the list of variables
        d = findDimIndices( obj, v, dim );
        
        %% Dimension indices
        
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
        
    end
    
    % Methods to notify user of automatic design changes
    methods
        
        % Notify the user when sequence and mean data are deleted for
        % coupled dimensions that change type.
        notifyChangedType( obj, v, d, cv );
        
        % Notify the user when secondary variables are coupled
        notifySecondaryCoupling( obj, v, vall );

        % Notify when coupled variables have overlap permissions altered
        notifySecondaryOverlap( obj, v, vall, tf );
        
    end
 
    % Methods for ensemble metadata objects
    methods
                
        % Get the metadata associated with each variable
        [stateMeta, ensMeta] = varMetadata( obj );

        % Get the size of the ensemble
        [siz] = ensembleSize( obj );
        
        % Returns the state vector index limits and dimensional size of
        % each variable.
        [varLimits, varSize, isState] = varIndices( obj, v );
        
    end
    
    % Methods for generating ensemble draws
    methods
        
        % Returns the variable indices of each set of coupled variables.
        cv = coupledVariables( obj );
        
        % Removes ensemble indices that don't allow a full sequence
        obj = trim( obj );

        % Restricts a set of coupled variables to ensemble indices with 
        % matching metadata
        obj = matchMetadata( obj, cv );
        
        % Select draws
        obj = makeDraws( obj, cv, nEns, random );
        
        % Initializes an array of draws for a design.
        [overlap, ensSize, undrawn, subDraws] = initializeDraws( obj, cv, nDraws );
        
        % Selects a set of N-D subscripted draws
        [subDraws, undrawn] = draw( obj, nDraws, subDraws, undrawn, random, ensSize );
        
        % Removes overlapping draws from an ensemble
        subDraws = removeOverlap( obj, subDraws, cv )
        
        % Saves finalized draws to variables
        obj = saveDraws( obj, cv, subDraws, undrawn );

    end
    
    % Methods for writing the ensemble to file
    methods
        
        % Writes the ensemble to file
        write( obj, file, random, writenan, overwrite );
        
        % Determines which indices to read from for efficient loading.
        [start, count, stride, keep] = loadingIndices( obj );
        
    end
        
end