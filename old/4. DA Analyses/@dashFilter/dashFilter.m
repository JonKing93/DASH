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
        % Error check values before setting
        setValues( obj, M, D, R, F )
    end
    
    % Set the values for a particular filter
    methods (Abstract)
        checkValues( obj, M, D, R, F, Rtype );
    end
    
end