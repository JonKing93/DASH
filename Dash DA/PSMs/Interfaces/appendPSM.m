%% This is an interface for PSMs that use the appended DA method. It ensures
% that they support bulk calculation of Ye values.
classdef (Abstract) appendPSM < handle
    
    % This is the method that all appendPSMs must implement
    methods (Abstract = true)
        
        % Does a bulk calculation of Ye for all observations that use a
        % particular PSM.
        Ye = calculateYe( obj, M, H, obNum )
    end
end