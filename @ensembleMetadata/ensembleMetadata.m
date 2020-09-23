classdef ensembleMetadata
    % Manages metadata for an ensemble
    
    properties
        ensembleName; % Name of the ensemble
        vectorName; % Name of the state vector template
        
        variableNames; % Names of each metadata
        varLimit; % The limit of each variable down the state vector
        dims; % The dimensions for each variable
        stateSize; % The length of each dimension for each variable
        
        metadata; % Metadata for each dimension of each variable
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

            % !!!!!!!!!!!!!!!!!!!!!!!!
            % Currently only building for state vector

            % Error check
            if ~isa(sv, 'stateVector') || ~isscalar(sv)
                error('sv must be a scalar stateVector object.');
            end

            % Get names
            obj.ensembleName = [];
            obj.vectorName = sv.name;

            % Variable indexing
            obj.variableNames = sv.variableNames;
            obj.varLimit = sv.variableLimits;

            % Preallocate dimensions
            nVars = numel(obj.variableNames);
            obj.dims = cell(nVars, 1);
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
                    
                        % State dimensions
                        if var.isState(d)
                            state = var.dimMetadata(grid, dim);
                            if var.takeMean(d)
                                state = permute(state, [3 2 1]);
                            end
                            ensemble = [];
                        end
                    
                        % Ensemble dimensions
                        if ~var.isState(d)
                            k = strcmp(dim, sv.dims{s});
                            members = sv.subMembers{s}(:, k);
                            ref = var.indices{d}(members);
                            ensemble = grid.meta.(dim)(ref, :);
                            state = var.seqMetadata{d};
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