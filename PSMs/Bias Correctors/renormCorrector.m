classdef renormCorrector < biasCorrector
    % renormCorrector
    % Implements bias correction by adjusting mean and variance
    %
    % renormCorrector Methods:
    %   renormCorrector - Creates a renormalization bias corrector.
    %   biasCorrect - Applies bias correction
    %   review - Error checks the bias corrector
    
    properties
        addUnit;
        timesUnit;
    end
    
    % Constructor
    methods
        function obj = renormCorrector( Xt, Xs, nanflag )
            % Creates a renormalization bias corrector
            %
            % obj = renormCorrector( Xt, Xs )
            % Uses a target and source dataset to determine an additive and
            % multiplicative constant to apply to inputs.
             %
            % obj = renormCorrector( Xt, Xs, nanflag )
            % Specify how to treat NaN. Default is 'includenan'.
            %
            % ----- Inputs -----
            %
            % Xt: A target dataset. The source dataset will be adjusted to
            %    match the mean of this target. (nVar x nEns)
            %
            % Xs: A source dataset. Typically from a model prior. (nVar x nEns)
            %
            % nanflag: A string specifying how to treat NaN values
            %       'includenan' (Default)
            %       'omitnan'
            
            % Set default
            if ~exist('nanflag','var') || isempty(nanflag)
                nanflag = 'includenan';
            end
            
            % Get the constants
            [timesUnit, addUnit] = biasCorrector.getRenormalization( Xt, Xs, nanflag );
            
            % Save values
            obj.addUnit = addUnit;
            obj.timesUnit = timesUnit;
            obj.type = "renorm";
        end
    end
    
    % Run and review
    methods
        
        % Error checks
        function[] = review( obj, H )
            if numel(H) ~= numel(obj.addUnit)
                error('The number of state indices (H) does not match the number of variables in the bias corrector.');
            end
        end
        
        % Apply the correction
        function[M] = biasCorrect( obj, M )
            M = M .* obj.timesUnit;
            M =M + obj.addUnit;
        end
        
    end
    
end