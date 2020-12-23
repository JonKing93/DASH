classdef (Abstract) PSM
    
    properties (SetAccess = private)
        name;
        rows;
        estimatesR;
    end
    
    methods
        % Constructor
        function[obj] = PSM(estimatesR, name)
            
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
            obj.name = dash.asssertStrFlag(name, 'name');
        end
        
        % Return name for error messages
        function[name] = messageName(obj, n)
            
            % Get some settings
            hasNumber = exist(n, 'var');
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
            obj.rows = rows;
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
            
            % Error check the ensemble
            assert(isnumeric(X), 'X must be numeric');
            dash.assertRealDefined(X, 'X');
            assert(ndims(X)<=3, 'X cannot have more than 3 dimensions');
            
            % Get ensemble sizes
            [nState, nEns, nPriors] = size(X);
            
            % Error check the PSMs
            dash.assertVectorTypeN(F, 'cell', [], 'F');
            nSite = numel(F);
            for s = 1:nSite
                name = sprintf('Element %.f of F', s);
                dash.assertScalarType(F{s}, name, 'PSM', 'PSM');
                
                % Check the rows of the PSM do not exceed the number of rows
                if max(F{s}.rows) > nState
                    error('X has %.f rows, but %s uses rows that are larger (%.f)', ...
                        nState, F{s}.messageName(s), max(F{s}.rows));
                end
                
                % Check the PSM can return R if requested
                if nargout>1 && ~F{s}.estimatesR
                    error('%s cannot estimate R', F{s}.messageName(s));
                end
            end
            
            % Preallocate
            Y = NaN(nSite, nEns, nPriors);
            if nargout>1
                R = NaN(nSite, nEns, nPriors);
            end
            
            % Get the values needed to run each PSM for each prior
            for s = 1:nSite
                Xpsm = X(F{s}.rows,:,:);
                for p = 1:nPriors
                    Xrun = Xpsm(:,:,p);
                    
                    % Run the PSM
                    if nargout>1
                        [Yrun, Rrun] = F{s}.run(Xrun);
                    else
                        Yrun = F{s}.run(Xrun);
                    end
                    
                    % Error check the R output
                    if nargout>1
                        name = sprintf('R values for %s for prior %.f', F{s}.messageName, p);
                        dash.assertVectorTypeN(Rrun, 'numeric', nEns, name);
                        if ~isrow(Rrun)
                            error('%s must be a row vector', name);
                        end
                        dash.assertRealDefined(Rrun, name);
                    end
                    
                    % Error check the Y output
                    name = sprintf('Y values for %s for prior %.f', F{s}.messageName, p);
                    dash.assertVectorTypeN(Yrun, 'numeric', nEns, name);
                    if ~isrow(Yrun)
                        error('%s must be a row vector', name);
                    end
                    dash.assertRealDefined(Yrun, name); 
                    
                    % Save
                    Y(s,:,p) = Yrun;
                    if nargout>1
                        R(s,:,p) = Rrun;
                    end
                end
            end
        end
    end
    
    % Run individual PSMs
    methods (Abstract)
        Y = run(X, F);
    end
end                 