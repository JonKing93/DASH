classdef meanCorrector < biasCorrector
    % meanCorrector
    % Implements bias correction via adjustment of mean
    %
    % meanCorrector Methods:
    %   meanCorrector - Creates a mean adjustment bias corrector.
    %   biasCorrect - Applies bias correction
    %   review - Error checks the bias corrector
    
    properties
        addUnit;
    end
    
    % Constructor
    methods
        function obj = meanCorrector( Xt, Xs, nanflag )
            % Creates a mean adjustment bias corrector. 
            %
            % obj = meanCorrector( Xt, Xs )
            % Uses a target and source dataset to determine an additive
            % constant to apply to inputs.
            %
            % obj = meanCorrector( Xt, Xs, nanflag )
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
            
            % Get the mean adjustment
            [~, addUnit] = biasCorrector.getRenormalization( Xt, Xs, nanflag );
            
            % Save values
            obj.addUnit = addUnit;
            obj.type = "mean";
        end
    end
    
    % Review and run
    methods
        
        % Error checks
        function[] = review( obj, H ) 
            if numel(H) ~= numel(obj.addUnit)
                error('The number of state indices (H) does not match the number of variables in the bias corrector.');
            end
        end
        
        % Applies the bias correction
        function[M] = run( obj, M )
            M = M + obj.addUnit;
        end
    end
    
end