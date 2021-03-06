classdef particleFilter < dashFilter
    % Implements a particle filter.
    %
    % particleFilter Methods:
    %   particleFilter - Creates a new particleFilter
    %   settings - Changes the settings for a particle filter
    %   run - Runs the particle filter
    %   setValues - Change the data used in an existing particle filter
    
    properties
        % Settings
        type;    % Weighting scheme, N best or probabilistic
        N;       % Number of best particles for N best weights
        big;     % Whether the ensemble is too large to fit into memory
        nEns;   % How many ensemble members to process per batch for large ensembles.
    end
    
    % Constructor
    methods
        function obj = particleFilter( M, D, R, F )
            % Creates a new particleFilter object
            %
            % obj = particleFilter( M, D, R, F )
            %
            % ----- Inputs -----
            %
            % M: A model prior. Either an ensemble object or a matrix (nState x nEns)
            %
            % D: A matrix of observations (nObs x nTime)
            %
            % R: Observation uncertainty. NaN entries in time steps with observations
            %    will be calculated dynamically via the PSMs.
            %
            %    scalar: (1 x 1) The same value will be used for all proxies in all time steps
            %    row vector: (1 x nTime) The same value will be used for all proxies in each time step
            %    column vector: (nObs x 1) The same value will be used for each proxy in all time steps.
            %    matrix: (nObs x nTime) Each value will be used for one proxy in one time step.
            %
            % F: A cell vector of PSM objects. {nObs x 1}
            %
            % ----- Outputs -----
            % 
            % obj: A new particleFilter object.
            
            % Default settings
            obj.type = 'weight';
            obj.N = NaN;
            obj.big = false;
            obj.nEns = NaN;
            
            % Block empty constructor, set values
            if isempty(M) || isempty(D) || isempty(R) || isempty(F)
                error('M, D, R, and F cannot be empty.');
            end
            obj.setValues( M, D, R, F );
        end
    end
    
    % User methods
    methods
        
        % Run the filter
        output = run( obj );
        
        % Change the settings
        settings( obj, varargin );
        
    end
    
    % Static analysis utilities
    methods (Static)
        
        % Particle filter
        output = pf( M, D, R, F, N );
        
        % Particle filter for big ensemble
        output = bigpf( ens, D, R, F, N, batchSize );
        
        % Compute particle weights
        weights = pfWeights( sse, N );
        
        % Normalize exponentials by their combined sum (efficiently)
        [Y] = normexp( X, dim, nanflag )
        
    end
    
end