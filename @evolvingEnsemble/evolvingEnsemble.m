classdef evolvingEnsemble
    %% Implements evolving ensembles that are too large to fit in active memory
    
    properties
        ensembles;
        nState;
        nEns;
        nPrior = 0;
    end
    
    % User methods
    methods
        function[obj] = evolvingEnsemble(varargin)
            %% Concatenate ensemble objects into an evolving ensemble
            %
            % obj = evolvingEnsemble(ens1, ens2, ..., ensN)
            %
            % ----- Inputs -----
            %
            % ensN: An ensemble object. All ensemble objects must have the
            %    same number of LOADED ensemble members and state vector
            %    elements.
            %
            % ----- Outputs -----
            %
            % obj: The evolvingEnsemble object
            
            % Require at least one ensemble. Get sizes
            assert(~isempty(varargin), 'You must provide at least one ensemble object to create an evolvingEnsemble.');
            dash.assert.scalarType(varargin{1}, 'The first input', 'ensemble', 'ensemble');
            [obj.nState, obj.nEns] = varargin{1}.loadedMetadata.sizes;
            
            % Add to the evolving ensemble
            obj.add(varargin);
        end
        
        function[obj] = add(obj, varargin)
            % Adds additional ensemble objects to an evolving ensemble
            %
            % obj = obj.add(ens1, ens2, ..., ensN)
            %
            % ------ Inputs -----
            %
            % ensN: An ensemble object.
            %
            % ----- Outputs -----
            %
            % obj: The updated evolving ensemble
            
            % Check each input is a scalar ensemble object
            nPriors = numel(varargin);
            for k = 1:nPriors
                dash.assert.scalarType(varargin{k}, sprintf('Input %.f', k), 'ensemble', 'ensemble');
            end
            
            % Ensure all ensemble objects are the same size
            for k = 1:nPriors
                [S, E] = varargin{k}.loadedMetadata.sizes;
                assert(S==obj.nState, sprintf(['Each ensemble object must load %.f ',...
                    'state vector elements, but input ensemble %.f loads %.f elements.'], obj.nState, k, S));
                assert(E==obj.nEns, sprintf(['Each ensemble must load %.f ensemble members, ',...
                    'but input ensemble %.f loads %.f members.'], obj.nEns, k, E));
            end
            
            % Add to the evolving ensemble
            obj.ensembles = [obj.ensembles; varargin{:}];
            obj.nPrior = obj.nPrior + nPriors;
        end
        
        function[obj] = remove(obj, p)
            % Remove ensembles from the evolving ensemble
            %
            % obj = obj.remove(p)
            %
            % ----- Inputs -----
            %
            % p: The index of the priors to remove from the evolving ensemble
            %
            % ----- Outputs -----
            %
            % obj: The updated evolvingEnsemble object
            
            % Check the indices are allowed
            p = dash.assert.indices(p, 'p', obj.nPrior, 'the number of priors in the evolving ensemble');
            p = unique(p);            
            assert(numel(p)<obj.nPrior, 'You cannot remove all the priors from an evolving ensemble');
            
            % Remove
            obj.ensemble(p) = [];
            obj.nPrior = obj.nPrior - numel(p);
        end
        
        function[ens] = ensemble(obj, p)
            % Return a particular ensemble object for the evolving ensemble
            %
            % obj = obj.ensemble(p)
            %
            % ----- Inputs -----
            %
            % p: The index of one of the priors in the evolving ensemble
            %
            % ----- Outputs -----
            %
            % ens: The requested ensemble object
            
            p = dash.assert.indices(p, 'p', obj.nPrior, 'the number of priors in the evolving ensemble');
            assert(isscalar(p), 'p must index a single prior');
            ens = obj.ensembles(p);
        end
    end
    
    % Object utilities
    
end         