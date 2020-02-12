classdef kalmanFilter < dashFilter
    % Implements an offline, ensemble square root kalman filter.
    %
    % kalmanFilter Methods:
    %   kalmanFilter - Creates a new kalmanFilter
    %   settings - Adjusts the settings for the kalman filter
    %   run - Runs the kalman filter
    %   setValues - Changes the data used in an existing kalman filter
    %   reconstructVars - Specify which variables to reconstruct
    
    properties
        % Settings
        type;            % Serial or joint updates
        localize;        % Localization weights
        inflate;         % The inflation factor
        append;          % Whether to use the appended Ye method
        meanOnly;        % Whether to only calculate the ensemble mean
        fullDevs;        % Whether to return full ensemble deviations
        percentiles;     % Which percentiles of the ensemble to return
        reconstruct;     % Which state vector elements to reconstruct
        reconH;          % Whether all H indices are reconstructed
    end
    
    % Constructor
    methods
        function obj = kalmanFilter( M, D, R, F )
            % Creates a new kalmanFilter object
            %
            % obj = kalmanFilter( M, D, R, F )
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
            % obj: A new kalmanFilter object
            
            % Default settings
            obj.type = 'joint';
            obj.localize = [];
            obj.inflate = 1;
            obj.append = false;
            obj.meanOnly = false;
            obj.fullDevs = false;
            obj.percentiles = [];
            
            % Block empty constructor, set values
            if isempty(M) || isempty(D) || isempty(R) || isempty(F)
                error('M, D, R, and F cannot be empty.');
            end
            obj.setValues( M, D, R, F );
            
            % Defaults for reconstructed variables
            obj.reconstruct = [];
            obj.reconH = [];
        end
    end
        
    % User methods
    methods
        
        % Run the filter
        output = run( obj );
        
        % Change settings
        settings( obj, varargin );
        
        % Specify variables to reconstruct
        reconstructVars( obj, vars, ensMeta )
        
    end
    
    % Utilities
    methods
        checkValues( obj, M, D, ~, F, ~ );
    end
    
    % Static analysis methods
    methods (Static)
        
        % Serial updating scheme
        [output] = serialENSRF( M, D, R, F, w, fullDevs, percentiles );
        
        % Full inversion
        [output] = jointENSRF( M, D, R, F, w, yloc, meanOnly, fullDevs, percentiles, reconstruct );
        
        % Serial kalman gain
        [K, a] = serialKalman( Mdev, Ydev, w, R );
        
        % Joint kalman gain
        [varargout] = jointKalman(type, varargin);
        
        % Append Ye
        [M, F, Yi, reconstruct] = appendYe( M, F, reconstruct );
        
        % Unappend Ye
        [Amean, Avar] = unappendYe( Amean, Avar, nObs )
        
        % Adjust PSM H indices for partial reconstruction
        F = adjustH( F, reconstruct );
        
    end
    
end