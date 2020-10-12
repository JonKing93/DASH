classdef ensembleMetadata
    % Manages metadata for an ensemble
    %
    % ensembleMetadata Methods:
    %   ensembleMetadata - Creates a new ensembleMetadata object
    %   sizes - Size of variables in a state vector ensemble.
    %   variableNames - Returns the names of the variables in a state vector
    %   variable - Metadata for a variable in a state vector ensemble
    %   dimension - Metadata for a dimension down a state vector
    %   coordinates - Lat-Lon coordinates down a state vector.
    %   regrid - Reshapes a state vector into gridded variables.
    %   findRows - Finds elements of a variable in a state vector
    %
    % *** Advanced ***
    % ensembleMetadata Methods:
    %   append - Update metadata after appending state vectors.
    %   remove - Updates metadata after removing variables from a state vector
    %   extract - Updates metadata after restricting a state vector to
    %             specific variables
    %   removeMembers - Update metadata after removing ensemble members
    %   useMembers - Update metadata after restricting an ensemble to
    %                specific members
    %   appendMembers - Update metadata after appending ensembles.

    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = private)
        ensembleName; % Name of the ensemble
        vectorName; % Name of the state vector template
        
        variableNames; % Names of each metadata
        varLimit; % The limit of each variable down the state vector
        nEls; % The number of elements down the state vector for each variable
        
        dims; % The dimensions for each variable
        stateSize; % The length of each dimension for each variable
        isState; % Whether the dimensions are state or ensemble
        meanSize; % The size of any means
        
        nEns; % The number of ensemble members.
        metadata; % Metadata for each dimension of each variable. Organized
                  % as a structure metadata.(variable).(state or ensemble).(dimension)
    end
    
    properties (Hidden, Constant)
        directionFlags = ["state", "s", "down", "d", "rows", "r", ...
            "ensemble", "ens", "e", "across", "a", "columns", "cols", "c"];
        nStateFlags = 6;
    end
    
    % Constructor
    methods
        function obj = ensembleMetadata(sv)
            %% Returns an ensembleMetadata object for a stateVector, ensemble, or .ens file.
            %
            % obj = ensembleMetadata(sv)
            % Creates an ensembleMetadata object for a state vector.
            %
            % ----- Inputs -----
            %
            % sv: A stateVector object
            %
            % ----- Outputs -----
            %
            % meta: The ensemble metadata object

            % Error check.
            if ~isa(sv, 'stateVector') || ~isscalar(sv)
                error('sv must be a scalar stateVector object.');
            end
            
            % Get names and size
            obj.ensembleName = [];
            obj.vectorName = sv.name;

            obj.nEns = 0;
            if ~isempty(sv.subMembers)
                obj.nEns = size(sv.subMembers{1}, 1);
            end

            % Variable indexing
            obj.variableNames = sv.variableNames;
            obj.varLimit = sv.variableLimits;

            % Preallocate
            nVars = numel(obj.variableNames);
            obj.stateSize = cell(nVars, 1);
            obj.nEls = NaN(nVars, 1);
            obj.dims = cell(nVars, 1);
            obj.isState = cell(nVars, 1);
            obj.meanSize = cell(nVars, 1);
            obj.metadata = struct();

            % Get the coupling index for each variable
            sets = unique(sv.coupled, 'rows');
            for v = 1:nVars
                s = find(sets(:,v));

                % Get the gridfile
                var = sv.variables(v);
                grid = var.gridfile;
                var.checkGrid(grid);
                
                % Get all user dimensions
                d = find(grid.isdefined | ~var.isState);
                obj.dims{v} = var.dims(d);
                obj.stateSize{v} = var.stateSize(d);
                obj.nEls(v) = prod(var.stateSize(d));
                obj.isState{v} = var.isState(d);
                obj.meanSize{v} = var.meanSize(d);
                
                % Get metadata for each dimension
                for k = 1:numel(d)
                    dim = var.dims(d(k));
                    ensemble = [];
                    
                    % State dimensions
                    if var.isState(d(k))
                        state = var.dimMetadata(grid, dim);
                        if var.takeMean(d(k))
                            state = permute(state, [3 2 1]);
                        end
                    
                    % Sequences
                    else
                        state = var.seqMetadata{d(k)};
                    end
                        
                    % Ensemble metadata
                    if ~var.isState(d(k)) && obj.nEns>0
                        col = strcmp(dim, sv.dims{s});
                        members = sv.subMembers{s}(:, col);
                        ref = var.indices{d(k)}(members);
                        ensemble = grid.meta.(dim)(ref, :);
                    end
                        
                    % Buile the metadata structure
                    obj.metadata.(var.name).state.(dim) = state;
                    obj.metadata.(var.name).ensemble.(dim) = ensemble;
                end
            end
        end
    end
    
    % Static utilities
    methods (Static)
        returnState = parseDirection(type, nDims);
    end
    
    % User methods
    methods
        % variableNames -- Just a direct call to the field
        [V, meta] = regrid(obj, X, varName, dimOrder, d, keepSingletons);
        meta = variable(obj, varName, dims, type, indices);
        meta = dimension(obj, dim, alwaysStruct);
        [latlon] = coordinates(obj, dim, verbose);
        rows = findRows(obj, varName, varRows);
        [nState, nEns] = sizes(obj, vars);
        
        obj = remove(obj, varNames);
        obj = append(obj, meta2);
        obj = extract(obj, varNames);
        
        obj = removeMembers(obj, members)
        obj = appendMembers(obj, meta2);
        obj = extractMembers(obj, members);
    end
    
end