classdef ensembleMetadata
    % Manages metadata for an ensemble
    
    properties (SetAccess = private)
        ensembleName; % Name of the ensemble
        vectorName; % Name of the state vector template
        
        variableNames; % Names of each metadata
        varLimit; % The limit of each variable down the state vector
        dims; % The dimensions for each variable
        stateSize; % The length of each dimension for each variable
        
        hasMembers; % Whether associated with ensemble members
        metadata; % Metadata for each dimension of each variable. Organized
                  % as a structure metadata.(variable).(dimension).(state or ensemble)
    end
    
    % Constructor
    methods
        function obj = ensembleMetadata(sv)
            %% Returns an ensembleMetadata object for a stateVector, ensemble, or .ens file.
            %
            % obj = ensembleMetadata(sv)
            % Creates an ensembleMetadata object for a state vector.
            %
            % obj = ensembleMetadata(ensfile)
            % Returns the ensembleMetadata object for an ensemble saved in a .ens file.
            %
            % obj = ensembleMetadata(ens)
            % Returns the ensembleMetadata object for an ensemble.
            %
            % ----- Inputs -----
            %
            % sv: A stateVector object

            % Error check.
            if ~isa(sv, 'stateVector') || ~isscalar(sv)
                error('sv must be a scalar stateVector object.');
            end
            
            % Check if associated with ensemble members
            obj.hasMembers = false;
            if ~isempty(sv.subMembers)
                obj.hasMembers = true;
            end

            % Get names
            obj.ensembleName = [];
            obj.vectorName = sv.name;

            % Variable indexing
            obj.variableNames = sv.variableNames;
            obj.varLimit = sv.variableLimits;

            % Preallocate
            nVars = numel(obj.variableNames);
            if obj.hasMembers
                obj.dims = cell(nVars, 1);
            end
            obj.stateSize = cell(nVars, 1);
            obj.metadata = struct();

            % Get the coupling index for each variable
            sets = unique(sv.coupled, 'rows');
            for v = 1:nVars
                s = find(sets(:,v));

                % Get the gridfile
                var = sv.variables(v);
                grid = var.gridfile;
                var.checkGrid(grid);

                % Dimensions and sizes. Initialize metadata
                obj.dims{v} = var.dims;
                obj.stateSize{v} = var.stateSize;
                
                % Get metadata for each ensemble and defined dimension
                for d = 1:numel(var.dims)
                    if grid.isdefined(d) || ~var.isState(d)
                        dim = var.dims(d);
                        state = [];
                        ensemble = [];
                    
                        % State dimensions
                        if var.isState(d)
                            state = var.dimMetadata(grid, dim);
                            if var.takeMean(d)
                                state = permute(state, [3 2 1]);
                            end
                        end
                    
                        % Sequences
                        if ~var.isState(d)
                            state = var.seqMetadata{d};
                        end
                        
                        % Ensemble metadata
                        if ~var.isState(d) && obj.hasMembers
                            k = strcmp(dim, sv.dims{s});
                            members = sv.subMembers{s}(:, k);
                            ref = var.indices{d}(members);
                            ensemble = grid.meta.(dim)(ref, :);
                        end
                        
                        % Build the metadata structure
                        obj.metadata.(var.name).(dim).state = state;
                        obj.metadata.(var.name).(dim).ensemble = ensemble;
                    end
                end
            end
        end
    end
    
    % User methods
    methods
        regrid;
    end
    
end