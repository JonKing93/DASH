classdef (Abstract) PSM
    %% Implements a common interface for all PSMs
    %
    % PSM Methods:
    %   estimate - Estimate proxy values from a state vector ensemble
    %   rename - Renames a PSM
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties (SetAccess = private)
        name;
        rows;
        estimatesR;
    end
    
    methods
        % Constructor
        function[obj] = PSM(name, estimatesR)
            %% PSM constructor. Records a name and whether the PSM can estimate R
            %
            % obj = PSM
            % Does not specify a name. Does not estimate R.
            %
            % obj = PSM(name)
            % Creates a PSM with a particular name. Does not estimate R.
            %
            % obj = PSM(name, estimatesR)
            % Creates a PSM with a name and specifies whether the PSM can
            % estimate R.
            %
            % ----- Inputs -----
            %
            % name: A name for the PSM. A string.
            %
            % estimatesR: A scalar logical indicating whether the PSM can
            %    estimate R (true), or not (false -- defalt)
            %
            % ----- Outputs -----
            %
            % obj: The new PSM object
            
            % Note if PSM can estimate R
            if ~exist('estimatesR', 'var') || isempty(estimatesR)
                estimatesR = false;
            end
            obj = obj.canEstimateR(estimatesR);
            
            % Optionally record a name
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            obj = obj.rename(name);     
        end
        
        % Rename
        function[obj] = rename(obj, name)
            %% Renames a PSM
            %
            % obj = obj.rename(newName)
            %
            % ----- Inputs -----
            %
            % newName: A new name for the PSM. A string
            %
            % ----- Outputs -----
            %
            % obj: The renamed PSM
            
            obj.name = dash.assertStrFlag(name, 'name');
        end
        
        % Return name for error messages
        function[name] = messageName(obj, n)
            %% Returns an identifying name for the PSM for use in messages
            %
            % name = obj.messageName
            % Returns a name for the PSM.
            %
            % name = obj.messageName(n)
            % Returns a name for the PSM and identifies its position in a list
            %
            % ----- Inputs -----
            %
            % n: A list index. A scalar, positive integer
            %
            % ----- Outputs -----
            %
            % name: A string identifying the PSM
            
            % Get some settings
            hasNumber = exist('n', 'var');
            hasName = ~strcmp(obj.name, "");
            
            % Create the message string
            name = "PSM";
            if hasNumber
                name = strcat(name, sprintf(' %.f', n));
                if hasName
                    name = strcat(name, sprintf(' ("%s")', obj.name));
                end
            elseif hasName
                name = strcat(name, sprintf(' "%s"', obj.name));
            end
        end
                
        % Set the rows
        function[obj] = useRows(obj, rows, nRows)
            %% Specifies the state vector rows used by a PSM
            %
            % obj = obj.useRows(rows)
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows holding the data required to run
            %    the PSM to estimate observations. If a column vector, uses
            %    the same rows for every ensemble member. If a matrix, each
            %    column indicates the rows to use for the corresponding
            %    ensemble member. Either a logical matrix or matrix of
            %    linear indices.
            %
            % nRows: The number of rows required by the PSM. A scalar
            %    positive integer.
            %
            % ----- Outputs -----
            %
            % obj: The updated PSM object
            
            % Error check
            assert(~isempty(rows), 'rows cannot be empty');
            assert(ndims(rows)<=3, 'rows cannot have more than 3 dimensions');
            assert(islogical(rows) || isnumeric(rows), 'rows must be numeric or logical');
            
            % Error check numeric indices
            if isnumeric(rows)
                dash.assertRealDefined(rows, 'rows');
                dash.assertPositiveIntegers(rows, 'rows');
                assert(size(rows,1)==nRows, sprintf('row(s) must have %.f element(s) along the first dimension', nRows));
                
            % Error check logical indices
            else
                nRows = unique(sum(rows, 1));
                assert(isscalar(nRows), 'Each column of rows must select the same number of state vector elements (must have the same number of "true" elements).')
                assert(nRows~=0, 'rows is not selecting any state vector rows because it has no "true" elements');
                
                % Convert logical indices to linear
                siz = size(rows, 1:3);
                [rows, ~, ~] = ind2sub(siz, find(rows));
                rows = reshape(rows, nRows, siz(2), siz(3));
            end
            
            % Save
            obj.rows = rows;
        end
            
        % Allow R to be estimated
        function[obj] = canEstimateR(obj, tf)
            %% Specifies whether a PSM can estimate R
            %
            % obj = obj.canEstimateR(tf)
            %
            % ----- Inputs -----
            %
            % tf: A scalar logical indicating if the PSM can estimate R
            %    (true) or not (false)
            %
            % ----- Outputs -----
            %
            % obj: The updated PSM object
            
            dash.assertScalarType(tf, 'tf', 'logical', 'logical');
            obj.estimatesR = tf;
        end
    end
    
    % Download PSM repositories
    methods (Static)
        download(psmName, path);
        [repo, commit] = githubLocation(psmName);
    end

    % Estimate proxy values
    methods (Static)
        [Ye, R] = estimate(X, F);   % User function call
        F = setupEstimate(X, F);    % Does error checking before computing estimates
        [Ye, R] = computeEstimates(X, F);
    end
    
    % Run individual PSM objects
    methods (Abstract)
        [Y, R] = runPSM(obj, X);
    end
    
    % Run PSMs directly
    methods (Abstract, Static)
        [Y, R] = run(varargin);
    end
end                 