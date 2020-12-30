classdef (Abstract) PSM
    %% Implements a common interface for all PSMs
    %
    % PSM Methods:
    %   estimate - Estimate proxy values from a state vector ensemble
    %   rename - Renames a PSM
    
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
        function[obj] = useRows(obj, rows)
            %% Specifies the state vector rows used by a PSM
            %
            % obj = obj.useRows(rows)
            %
            % ----- Inputs -----
            %
            % rows: The rows used by the PSM. A vector of positive integers.
            %
            % ----- Outputs -----
            %
            % obj: The updated PSM object
            
            % Error check
            assert(isvector(rows), 'rows must be a vector');
            assert(islogical(rows) || isnumeric(rows), 'rows must be numeric or logical');
            
            % Error check numeric indices
            if isnumeric(rows)
                dash.assertPositiveIntegers(rows, 'rows');
                
            % Convert logical to numeric
            else
                rows = find(rows);
            end
            
            % Save
            obj.rows = rows(:);
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
    
    % Estimate Y values for a set of PSMs
    methods (Static)                
        function[Ye, R] = estimate(X, F)
            %% Estimates proxies values from a state vector ensemble
            %
            % Ye = PSM.estimate(X, psms)
            % Estimates proxies values for a state vector ensemble given a
            % set of PSMs.
            %
            % [Ye, R] = PSM.estimates(X, psms)
            % Also estimates proxy uncertainties (R).
            %
            % ----- Inputs -----
            %
            % X: A state vector ensemble. A numeric array with the
            %    following dimensions (State vector x ensemble members x priors)
            %
            % psms: A set of PSMs. Either a scalar PSM object or a cell
            %    vector whose elements are PSM objects.
            %
            % ----- Outputs -----
            %
            % Ye: Proxy estimates. A numeric array with the dimensions
            %    (Proxy sites x ensemble members x priors)
            %
            % R: Proxy uncertainty estimates. A numeric array with
            %    dimensions (proxy sites x ensemble members x priors)
            
            % Parse and error check the ensemble. Get size
            if isa(X, 'ensemble')
                isens = true;
                assert(isscalar(X), 'ens must be a scalar ensemble object');
                [nState, nEns] = X.metadata.sizes;
                nPriors = 1;
                m = matfile(X.file);
            else
                assert(isnumeric(X), 'X must be numeric');
                assert(ndims(X)<=3, 'X cannot have more than 3 dimensions');
                isens = false;
                [nState, nEns, nPriors] = size(X);
            end
            
            % Error check the ensemble, get sizes
            dash.assertRealDefined(X, 'X');
            
            % Parse the PSM vector
            nSite = numel(F);
            [F, wasCell] = dash.parseInputCell(F, nSite, 'F');
            name = "F";
            
            % Error check the individual PSMs
            for s = 1:nSite
                if wasCell
                    name = sprintf('Element %.f of F', s);
                end
                dash.assertScalarType(F{s}, name, 'PSM', 'PSM');
                
                % Check the rows of the PSM do not exceed the number of rows
                if max(F{s}.rows) > nState
                    error('The ensemble has %.f rows, but %s uses rows that are larger (%.f)', ...
                        nState, F{s}.messageName(s), max(F{s}.rows));
                end
            end
            
            % Preallocate
            Ye = NaN(nSite, nEns, nPriors);
            if nargout>1
                R = NaN(nSite, nEns, nPriors);
            end
            
            % Get the values needed to run each PSM
            for s = 1:nSite
                if ~isens
                    Xpsm = X(F{s}.rows,:,:);
                
                % If using an ensemble object, first attempt to read all rows at once
                else
                    try
                        rows = dash.equallySpacedIndices(F{s}.rows);
                        Xpsm = m.X(rows,:);
                        [~, keep] = ismember(F{s}.rows, rows);
                        Xpsm = Xpsm(keep,:);
                        
                    % If unsuccessful, load values iteratively
                    catch
                        nRows = numel(F{s}.rows);
                        Xpsm = NaN(nRows, nEns);
                        for r = 1:nRows
                            Xpsm(r,:) = m.X(F{s}.rows(r),:);
                        end
                    end
                end
                
                % Get the values for each prior and run the PSM
                for p = 1:nPriors
                    Xrun = Xpsm(:,:,p);
                    if nargout>1
                        [Yrun, Rrun] = F{s}.runPSM(Xrun);
                    else
                        Yrun = F{s}.runPSM(Xrun);
                    end
                    
                    % Error check the R output
                    if nargout>1
                        name = sprintf('R values for %s for prior %.f', F{s}.messageName(s), p);
                        dash.assertVectorTypeN(Rrun, 'numeric', nEns, name);
                        if ~isrow(Rrun)
                            error('%s must be a row vector', name);
                        end
                    end
                    
                    % Error check the Y output
                    name = sprintf('Y values for %s for prior %.f', F{s}.messageName(s), p);
                    dash.assertVectorTypeN(Yrun, 'numeric', nEns, name);
                    if ~isrow(Yrun)
                        error('%s must be a row vector', name);
                    end
                    
                    % Save
                    Ye(s,:,p) = Yrun;
                    if nargout>1
                        R(s,:,p) = Rrun;
                    end
                end
            end
        end
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