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
        title; % An optional identifier for the state vector
        verbose; % Whether to print a messages to the console
        warn; % Whether to warn the user about certain requests
        
        variables; % The array of variable designs
        coupled; % Which variables are coupled
        autoCouple; % Whether to automatically couple a variable to new variables
    end
    
    % Constructor
    methods
        function obj = stateVector( title, verbose, warn )
            % Creates a new state vector design.
            %
            % obj = stateVector;
            % Initializes a new stateVector object.
            %
            % obj = stateVector(title)
            % Includes an identifying title.
            %
            % obj = stateVector(title, verbose)
            % Specify whether to print various messages to console. Default
            % is true.
            %
            % obj = stateVector(title, verbose, warn)
            % Specify whether to provide warnings for various design
            % choices. Default is true.
            %
            % ----- Inputs -----
            %
            % title: An optional title for the state vector. A string scalar
            %    or character row vector.
            %
            % verbose: A scalar logical indicating whether to print various
            %    messages to the console (true -- default) or not (false).
            %
            % warn: A scalar logical indicating whether to provide warnings
            %    for certain design choices (true -- default) or not (false)
            %
            % ----- Outputs -----
            %
            % obj: A new, empty stateVector object.
            
            % Defaults
            if ~exist('title','var') || isempty(title)
                title = "";
            end
            if ~exist('verbose','var') || isempty(verbose)
                verbose = true;
            end
            if ~exist('warn','var') || isempty(warn)
                warn = true;
            end
            
            % Error check
            dash.assertStrFlag(title, 'title');
            if ~isscalar(verbose) || ~islogical(verbose)
                error('verbose must be a scalar logical');
            elseif ~isscalar(warn) || ~islogical(warn)
                error('warn must be a scalar logical.');
            end
            
            % Save
            obj.title = string(title);
            obj.verbose = verbose;
            obj.warn = warn;
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