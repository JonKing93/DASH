classdef biasCorrector < handle
    
    %% This is the interface part of the bias corrector. It allows PSM
    % developers to access any bias correction with a single line of code.
   
    % The biasType of bias corrector
    properties
        biasType = "none";  % Default is no bias-correction
        bias = struct();    % A structure to hold bias-correction args
    end
    
    %% Constructor and interface method.
    methods
        
        % This is the placeholder biasCorrector constructor. It is 
        % automatically called every time a PSM is created. You do not need
        % to explicitly call this constructor.
        function obj = biasCorrector()
        end
        
        % This is a single command that anyone can use in runPSM to access
        % the appropriate bias correction. It is switch interface that
        % routes an ensemble to the appropriate bias-correction algorithm.
        function[M] = biasCorrect( obj, M )
            
            % Just return the ensemble if not bias-correcting
            if strcmp( obj.biasType, 'none' )
                return;
                
            % Renormalization
            elseif strcmp( obj.biasType, 'renorm' )
                M = obj.renormCorrector( M );
                
            % Mean adjustment
            elseif strcmp( obj.biasType, 'mean' )
                M = obj.meanCorrector( M );
                
            % A demo for future bias-correction development
            elseif strcmp( obj.biasType, 'some other corrector')
                M = obj.someOtherCorrector( M );  
            end
        end
        
        % This is a single command that anyone can use in checkPSM to
        % access the appropriate error checking for a bias-correction
        % method. It is a switch interface that routes the saved bias
        % correction arguments to the appropriate error checker.
        function[] = reviewBiasCorrector( obj )
            
             % No error checking needed if no bias-correction
            if strcmp( obj.biasType, 'none' )
                return;
                
            % Error check renormalization
            elseif strcmp( obj.biasType, 'renorm' )
                obj.checkRenorm;
                
            % Error check the mean adjuster
            elseif strcmp( obj.biasType, 'mean' )
                obj.checkMean;
                
            % A demo for future bias-correction development
            elseif strcmp( obj.biasType, 'some other corrector' )
                obj.checkSomeOther;
                
            else
                error('Unrecognzied bias-corrector.');
            end
        end
        
    end
    
    %% This implements mean adjustment
    methods
        
        % This activates the mean adjuster
        function[] = useMeanCorrector( obj, addConstant )
  
            % Set the value for mean adjustment
            obj.bias.addConstant = addConstant(:);
            
            % Specify to use a mean adjustment
            obj.biasType = "mean";
        end
        
        % This actually does the adjustment
        function[M] = meanCorrector( obj, M )
            % Adjust the mean
            M = M + obj.bias.addConstant;
        end
        
        % This error checks the additive constant
        function[] = checkMean( obj )
            
            % This needs to be written
        end
    end
       
    %% This implements a renormalization bias-corrector
    methods
        
        % A function that specifies to use renormalization bias-correction
        function[] = useRenormCorrector( obj, timesConstant, addConstant )
            obj.bias = struct();
            obj.bias.timesConstant = timesConstant(:);
            obj.bias.addConstant = addConstant(:);
            obj.biasType = "renorm";
        end
        
        % A function that implements renormalization
        function[M] = renormCorrector( obj, M )
            
            % Apply the multiplicative constant
            M = M .* obj.bias.timesConstant;
            
            % Apply the additive constant
            M = M + obj.bias.addConstant;
        end
        
        % A function to error check renormalization
        function[] = checkRenorm( obj )
            % Need to write this
            % ....
        end
    end
    
    %% This part of the code is a demo for bias-corrector developers.
    methods
        
        % A function that specifies to use some other bias corrector
        function[] = useSomeOtherCorrector( obj, inArgs )
            
            %%%%%
            % This is just a demo, stop anyone from actually using it.
            error('Some other bias corrector is just a demo!');
            %%%%%
            
            % Clear the bias corrector input arguments
            obj.bias = struct();
            
            % Save the input arguments
            obj.bias.args = inArgs;
            
            % Specify that the PSM should use some other corrector
            obj.biasType = "some other corrector";
        end
    
        % A function that implements bias correction for an ensemble
        function[M] = someOtherCorrector( obj, M )
            
            %%%%%
            % This is just a demo, stop anyone from actually using it.
            error('"Some other corrector" is just a demo!');
            %%%%%
            
            % Apply the bias correction
            M = someCorrectorFunction( M );
        end
    
        % A function that error checks the arguments for some other bias
        % corrector
        function[] = checkSomeOther( obj )
            
            %%%%%
            % This is just a demo, stop anyone from actually using it.
            error('Some other bias corrector is just a demo!');
            %%%%%
            
            if ~isreasonable( obj.bias.inArgs )
                error('inArgs are not reasonable.');
            end
        end
    
    end
    
end
    
    
    
    
    
        