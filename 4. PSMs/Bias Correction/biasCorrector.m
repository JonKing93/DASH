classdef biasCorrector
    
    %% This is the interface part of the bias corrector. It allows PSM
    % developers to access any bias correction with a single line.
   
    % The type of bias corrector
    properties
        type = 'none';  % Default is no bias-correction
    end
    
    % Constructor and interface method.
    methods
        
        function obj = biasCorrector()
        end
        
        % This is a single command that anyone can use in runPSM to access
        % the appropriate bias correction.
        function[M] = biasCorrect( obj, M )
            
            % If there is no bias-correction, just return the ensemble
            if strcmp( obj.type, 'none' )
                return;
                
            % Otherwise, if a npdft
            elseif strcmp( obj.type, 'npdft' )
                
                
            end
            
        end
    end
        

    %% This is the part of the code that implements N-pdft in conjunction
    % with MVN sampling and BJP parameter estimation
    
    properties
        bjpvars;
    end

    
    methods
        
        % 
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
end
    
    
    
    
    
        