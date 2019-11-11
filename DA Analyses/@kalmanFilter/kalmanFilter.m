classdef kalmanFilter < dashFilter
    % Implements an offline, ensemble square root kalman filter.
    
    properties
        % Settings
        type;
        w;
        inflate;
        append;
        meanOnly;
    end
    
    % Constructor
    methods
        function obj = kalmanFilter( M, D, R, F )
            
            % Default settings
            obj.type = 'joint';
            obj.w = [];
            obj.inflate = 1;
            obj.append = false;
            obj.meanOnly = false;
            obj.returnFull = false;
            
            % Block empty constructor, set values
            if isempty(M) || isempty(D) || isempty(R) || isempty(F)
                error('M, D, R, and F cannot be empty.');
            end
            obj.setValues( M, D, R, F );
        end
    end
            
            