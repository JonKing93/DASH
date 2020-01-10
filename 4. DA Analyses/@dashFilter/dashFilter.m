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
        checkValues( ~, M, D, R, F, Rtype)
    end
    
    % Set the values for a particular filter
    methods (Abstract)
        setValues( M, D, R, F );
    end
    
end