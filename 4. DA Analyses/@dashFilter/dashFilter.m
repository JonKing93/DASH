classdef (Abstract) dashFilter < dash
    % Implements setValues error checking for particle and kalman filters
    
    properties
        M;
        D;
        R;
        F;
        Rtype;
    end
    
    methods
        % Set values and error check
        setValues( obj, M, D, R, F)
    end
    
end