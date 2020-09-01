classdef stateVector
    % A class that designs and builds a state vector from data stored in
    % .grid files.
    %
    % stateVector Methods:
    %    stateVector - Initializes a new state vector.
    %    add - Adds a variable to the state vector.
    %    design - Designs a variable in the state vector.
    %    buildEnsemble - Builds an state vector ensemble
    %
    %    mean - Takes a mean over specified dimensions of a variable.
    %    sequence - Uses a sequence of data along an ensemble dimension of a variable.
    %    copy - Copies design parameters from one variable to others
    %    info - Returns information about a state vector and its variables
    % 
    % *** Advanced ***
    % stateVector Methods:
    %    append - Appends two state vectors
    %    convertMetadata - Converts metadata along a dimension of a variable to a different format
    %    remove - Removes a variable from a state vector
    %    couple - Couples variables in a state vector
    %    uncouple - Uncouples variables
    %    ***overlap***
    %    
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        name; % An optional identifier for the state vector
        verbose; % Whether to print a messages to the console
        
        variables; % The array of variable designs
        overlap; % Whether variable ensemble members can use overlapping, non-duplicate information
        coupled; % Which variables are coupled
        auto_Couple; % Whether to automatically couple a variable to new variables
    end
    
    % Constructor
    methods
        function obj = stateVector( name, verbose )
            % Creates a new state vector design.
            %
            % obj = stateVector;
            % Initializes a new stateVector object.
            %
            % obj = stateVector(name)
            % Includes an identifying name.
            %
            % obj = stateVector(name, verbose)
            % Specify whether to print various messages to console. Default
            % is true.
            %
            % ----- Inputs -----
            %
            % title: An optional title for the state vector. A string scalar
            %    or character row vector.
            %
            % verbose: A scalar logical indicating whether to print various
            %    messages to the console (true -- default) or not (false).
            %
            % ----- Outputs -----
            %
            % obj: A new, empty stateVector object.
            
            % Defaults
            if ~exist('title','var') || isempty(name)
                name = "";
            end
            if ~exist('verbose','var') || isempty(verbose)
                verbose = true;
            end
            
            % Save name. Set console output
            obj = obj.rename(name);
            obj = obj.displayConsoleOutput(verbose);
            
            % Initialize
            obj.overlap = false(0,1);
            obj.auto_Couple = false(0,1);
            obj.coupled = false(0,0);
            obj.variables = [];
        end
    end
    
    % Object utilities
    methods
        varNames = variableNames(obj);
        [v, varNames] = checkVariables(obj, varNames, multiple);
        str = errorTitle(obj);
        obj = updateCoupledVariables(obj, t, v);
    end
    
    % User interface methods with stateVectorVariable
    methods
        obj = sequence(obj, varNames, dims, indices, metadata);
        obj = mean(obj, varNames, dims, indices, omitnan);
        obj = weightedMean(obj, varNames, dims, weights);
        obj = resetMeans(obj, varNames);
        obj = design(varNames, dims, type, indices);
        
        info;
        buildEnsemble;
    end
    
    % User methods
    methods
        obj = rename(obj, name);
        obj = displayConsoleOutput(obj, verbose);
        
        obj = add(obj, name, file, autoCouple);
        obj = remove(obj, varNames);
        
        obj = autoCouple(obj, varNames, auto);
        obj = allowOverlap(obj, varNames, overlap);
        
        obj = couple(obj, varNames);
        uncouple;
        copy;
        

    end
     
end