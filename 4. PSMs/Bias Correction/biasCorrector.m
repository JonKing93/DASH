classdef biasCorrector < handle
    
    %% This is the interface part of the bias corrector. It allows PSM
    % developers to access any bias correction with a single line of code.
   
    % The biasType of bias corrector
    properties
        biasType = "none";  % Default is no bias-correction
        bias = struct();    % A structure to hold bias-correction args
    end
    
    % Constructor and interface method.
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
                
            % Use an npdft scheme if specified
            elseif strcmp( obj.biasType, 'mvn-npdft' )
                M = obj.mvnNpdftCorrector( M );
                
            % Renormalization
            elseif strcmp( obj.biasType, 'renorm' )
                M = obj.renormCorrector( M );
                
            % A demo for future bias-correction development
            elseif strcmp( obj.biasType, 'some other corrector')
                M = obj.someOtherCorrector( M );
                
            end
        end
        
        % This is a single command that anyone can use in checkPSM to
        % access the appropriate error checking for a bias-correction
        % method. It is a switch interface that routes the saved bias
        % correction arguments to the appropriate error checker.
        function[] = checkBiasCorrector( obj )
            
             % No error checking needed if no bias-correction
            if strcmp( obj.biasType, 'none' )
                return;
                
            % Check on an mvn-npdft scheme
            elseif strcmp( obj.biasType, 'mvn-npdft' )
                obj.checkMvnNpdft;
                
            % Error check renormalization
            elseif strcmp( obj.biasType, 'renorm' )
                obj.checkRenorm;
                
            % A demo for future bias-correction development
            elseif strcmp( obj.biasType, 'some other corrector' )
                obj.checkSomeOther;
                
            end
        end
        
    end
     

    %% This is the part of the code that implements N-pdft    
    methods
        
        % This function sets the values needed for a static N-pdft map. It
        % also specifies that the PSM should use an npdft bias correction.
        function[] = useMvnNpdftCorrector( obj, Xt0, Xs0, R, normT, normS, transform, params )
            
            % Ensure there are the correct number of inputs
            if nargin ~= 7
                error('There must be 7 input arguments.');
            end
            
            % Empty the bias-correction structure of any previous values
            obj.bias = struct();
            
            % Add a field for each input
            obj.bias.Xt0 = Xt0;
            obj.bias.Xs0 = Xs0;
            obj.bias.R = R;
            obj.bias.normT = normT;
            obj.bias.normS = normS;
            obj.bias.transform = transform;
            obj.bias.params = params;
            
            % Specify that the PSM is using an MVN-NPDFT corrector
            obj.biasType = "mvn-npdft";
        end
        
        % This function applies a static npdft mapping.
        function[M] = mvnNpdftCorrector( obj, M )
            
            % Flip the ensemble to (nEns x nVar)
            M = M';
            
            % Transform the variables to the MVN distributions used in the
            % calibration period.
            M = mvnTransform( M, obj.bias.transform, obj.bias.params );
            
            % Apply the static npdft mapping.
            M = npdft_static( M, obj.bias.Xt0, obj.bias.Xs0, obj.bias.R, ...
                                 obj.bias.normT, obj.bias.normS );
                             
            % Apply the inverse transforms
            M = invMvnTransform( M, obj.bias.transform, obj.bias.params );
            
            % Flip back to (nVar x nEns)
            M = M';
        end
            
        % This error checks the MVN-NPDFT bias corrector args
        function[] = checkMvnNpdft( obj )
            
            % Do some error checking
            % ...
        end
        
    end
    
    %% This implements a renormalization bias-corrector
    methods
        
        % A function that specifies to use renormalization bias-correction
        function[] = useRenormCorrector( obj, slope, intercept )
            obj.bias = struct();
            obj.bias.slope = slope(:);
            obj.bias.intercept = intercept(:);
            obj.biasType = "renorm";
        end
        
        % A function that implements renormalization
        function[M] = renormCorrector( obj, M )
            
            % Apply the multiplicative constant
            M = M .* obj.bias.slope;
            
            % Apply the additive constant
            M = M + obj.bias.intercept;
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
    
    
    
    
    
        