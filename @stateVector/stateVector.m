classdef stateVector
    % A class that designs a state vector and builds an ensemble.
    %
    % stateVector Methods:
    %   stateVector - Intializes a new state vector.
    %   add - Adds a new variable to a state vector.
    %   design - Options for dimensions of variables in a state vector.
    %   mean - Options for taking a mean
    %   weightedMean - Options for taking a weighted mean
    %   sequence - Options designing a sequence.
    %   copy - Copy options between variables
    %   buildEnsemble - Builds a state vector ensemble
    %
    % *** Summary Information ***
    % stateVector Methods:
    %   variableNames - Returns a list of variables in the state vector
    %   dimensions - Returns a list of dimensions for variables
    %   info - Return a summary of a state vector
    %
    % *** Advanced ***
    % stateVector Methods:
    %   autoCouple - Specify whether to automatically couple variables
    %   uncouple - Uncouple variables in a state vector
    %   couple - Couples variables
    %   allowOverlap - Enable overlap for variables in a state vector
    %   specifyMetadata - Specify metadata for variable dimensions
    %   convertMetadata - Convert metadata for variable dimensions
    %    
    % *** Additional Options ***
    % stateVector Methods:
    %   notifyConsole - Enable or disable console notifications
    %   rename - Change the name of a state vector
    %   renameVariables - Change the names of variables
    %   append - Concatenate state vectors
    %   extract - Get the state vector for specific variables
    %   remove - Removes a variable from a state vector
    %   resetMeans - Reset options for means
    %   resetMetadata - Reset options for metadata
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = private)
        name; % An optional identifier for the state vector
        verbose; % Whether to print a messages to the console
        
        variables; % The array of variable designs
        overlap; % Whether variable ensemble members can use overlapping, non-duplicate information
        coupled; % Which variables are coupled
        auto_Couple; % Whether to automatically couple a variable to new variables
        
        subMembers; % Subscripted ensemble members for each set of coupled variables
        dims; % The order of dimensions of the subscripted ensemble members
        unused; % Unselected ensemble members for each set of coupled variables
        editable; % Indicates whether the state vector can be edited
    end
    
    properties (Hidden, Constant)
        defaultName = 'this stateVector';
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
            % name: An optional title for the state vector. A string scalar
            %    or character row vector.
            %
            % verbose: A scalar logical indicating whether to print various
            %    messages to the console (true -- default) or not (false).
            %
            % ----- Outputs -----
            %
            % obj: A new, empty stateVector object.
            
            % Defaults
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            if ~exist('verbose','var') || isempty(verbose)
                verbose = true;
            end
            
            % Save name. Set console output
            obj = obj.rename(name);
            obj = obj.notifyConsole(verbose);
            
            % Initialize
            obj.overlap = false(0,1);
            obj.auto_Couple = false(0,1);
            obj.coupled = false(0,0);
            obj.variables = [];
            obj.subMembers = cell(0,1);
            obj.dims = cell(0,1);
            obj.unused = cell(0,1);
            obj.editable = true;
        end
    end
    
    % Object utilities
    methods
        limits = variableLimits(obj);
        [v, varNames] = checkVariables(obj, varNames);
        assertEditable(obj);
        checkVariableNames(obj, newNames, v, inputName, methodName);
        str = errorTitle(obj);
        obj = updateCoupledVariables(obj, t, v);        
        [grids, sources, f] = prebuildSources(obj);
        [X, meta, obj] = buildEnsemble(obj, nEns, random, filename, overwrite, showprogress);
    end
    
    % User interface methods with stateVectorVariable
    methods
        obj = design(obj, varNames, dims, type, indices);
        obj = sequence(obj, varNames, dims, indices, metadata);    
        obj = mean(obj, varNames, dims, indices, omitnan);
        obj = weightedMean(obj, varNames, dims, weights);
        obj = resetMeans(obj, varNames, dims);
        obj = specifyMetadata(obj, varNames, dim, metadata);
        obj = convertMetadata(obj, varNames, dim, convertFunction, functionArgs);
        obj = resetMetadata(obj, varNames, dims);
        dims = dimensions(obj, varNames, type);
        [vectorInfo, varInfo] = info(obj, vars);
        obj = renameVariables(obj, varNames, newNames);
    end
    
    % User methods
    methods
        obj = rename(obj, name);
        obj = notifyConsole(obj, verbose);
        obj = add(obj, name, file, autoCouple);
        obj = remove(obj, varNames);
        obj = couple(obj, varNames);
        obj = uncouple(obj, varNames);
        obj = autoCouple(obj, varNames, auto);
        obj = allowOverlap(obj, varNames, overlap);
        obj = append(obj, secondVector);
        obj = extract(obj, varNames);
        obj = copy(obj, templateName, varNames, varargin);
        varNames = variableNames(obj, v);
        [X, meta, obj] = build(obj, nEns, random, filename, overwrite, showprogress);
        [X, meta, obj] = addMembers(obj, nAdd, showprogress);
    end
     
end