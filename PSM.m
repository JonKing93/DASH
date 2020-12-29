classdef (Abstract) PSM
    
    properties (SetAccess = private)
        name;
        rows;
        estimatesR;
    end
    
    methods
        % Constructor
        function[obj] = PSM(name, estimatesR)
            
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
            obj.name = dash.assertStrFlag(name, 'name');
        end
        
        % Return name for error messages
        function[name] = messageName(obj, n)
            
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
            dash.assertScalarType(tf, 'tf', 'logical', 'logical');
            obj.estimatesR = tf;
        end
    end
    
    % Estimate Y values for a set of PSMs
    methods (Static)                
        function[Y, R] = estimate(X, F)
            
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
            Y = NaN(nSite, nEns, nPriors);
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
                    Y(s,:,p) = Yrun;
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