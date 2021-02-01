classdef (Abstract) biasCorrector < handle
    % biasCorrector
    % Implements behavior for bias correction algorithms
    
    properties
        type = "none";
    end
    
    % Constructor
    methods
        function obj = biasCorrector()
        end
    end
    
    % Abstract methods implemented by individual correctors
    methods (Abstract)
        
        % Error checks the corrector
        review( obj, H );
        
        % Applies bias correction to an ensemble
        M = biasCorrect( obj, M );
        
    end
    
    % Renorm utility
    methods (Static)
        function[timesUnit, addUnit] = getRenormalization( Xt, Xs, nanflag )
            % Gets multiplicative and additive constants needed to match a
            % source dataset to the mean and variance of a target dataset.
            %
            % [timesUnit, addUnit] = biasCorrector.getRenormalization( Xt, Xs, nanflag )
            %
            % ----- Inputs -----
            %
            % Xt: The target dataset. Each row is treated independently. (nVar x nTime1)
            %
            % Xs: The source dataset. Typically the model prior. Each row is treated
            %     independently. (nVar x nTime2)
            %
            % nanflag: A string specifying how to treat NaNs in the datsets. Default
            %      behavior is to include NaN in means.
            %      'includenan': Includes NaN values in means.
            %      'omitnan': Removes NaN values before computing means.
            %
            % ----- Outputs -----
            %
            % timesUnit: The multiplicative constants needed to adjust the standard
            % deviations of the rows of Xs to match the rows of Xt. 
            % 
            % addUnit: The additive constants needed to adjust the means of the rows
            % of Xs to match the means of the rows of Xt.            
            
            % Set default
            if ~exist('nanflag','var')
                nanflag = 'includenan';
            end
            
            % Error check
            if ~ismatrix(Xt) || ~isnumeric(Xt) || ~isreal(Xt)
                error('Xt must be a real, numeric matrix.');
            elseif ~ismatrix(Xs) || ~isnumeric(Xs) || ~isreal(Xs)
                error('Xs must be a real, numeric matrix.');
            elseif size(Xt,1) ~= size(Xs,1)
                error('The number of rows in Xs must match the number of rows of Xt.');
            elseif ~ismember( nanflag, ["omitnan","includenan"] )
                error('Unrecognized nanflag.');
            end
            
            % Get the means and standard deviations
            meanS = mean(Xs, 2, nanflag);
            meanT = mean(Xt, 2, nanflag);

            stdS = std( Xs, 0, 2, nanflag );
            stdT = std( Xt, 0, 2, nanflag );
            
            % Get the renormalization constants
            timesUnit= (stdT ./ stdS);
            addUnit = meanT - (stdT .* meanS ./ stdS);
        end
    end       
            
end
  