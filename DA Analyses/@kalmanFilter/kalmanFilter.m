classdef kalmanFilter < dashFilter
    % Implements an offline, ensemble square root kalman filter.
    
    properties
        % Settings
        type;
        localize;
        inflate;
        append;
        meanOnly;
        fullDevs;
    end
    
    % Constructor
    methods
        function obj = kalmanFilter( M, D, R, F )
            
            % Default settings
            obj.type = 'joint';
            obj.localize = [];
            obj.inflate = 1;
            obj.append = false;
            obj.meanOnly = false;
            obj.fullDevs = false;
            
            % Block empty constructor, set values
            if isempty(M) || isempty(D) || isempty(R) || isempty(F)
                error('M, D, R, and F not be empty.');
            end
            obj.setValues( M, D, R, F );
        end
    end
        
    % User methods
    methods
        
        % Run the filter
        output = run( obj );
        
        % Change settings
        settings( obj, varargin );
        
    end
    
    % Static analysis methods
    methods (Static)
        
        % Serial updating scheme
        [output] = serialENSRF( M, D, R, F, w );
        
        % Full inversion
        [output] = jointENSRF( M, D, R, F, w, yloc, meanOnly );
        
        % Serial kalman gain
        [K, a] = serialKalman( Mdev, Ydev, w, R );
        
        % Joint kalman gain
        [varargout] = jointKalman(type, varargin);
        
        % Append Ye
        [M, F, Yi] = appendYe( M, F );
        
        % Unappend Ye
        [Amean, Avar] = unappendYe( Amean, Avar, nObs )
        
    end