classdef vslite < PSM.Interface
    %% Implements the VS-Lite tree-ring PSM
    %
    % Find it on Github at: https://github.com/suztolwinskiward/VSLite
    %
    % Or read the paper:
    % Tolwinski-Ward, S. E., Evans, M. N., Hughes, M. K.,
    % and Anchukaitis, K. J.: An efficient forward model of the climate
    % controls on interannual variation in tree-ring width, Clim. Dynam.,
    % 36, 2419–2439, doi:10.1007/s00382-010-0945-5, 2011.
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        phi;
        T1;
        T2;
        M1;
        M2;
        options;
    end
    
    methods (Static)
        function[Y] = run(phi, T1, T2, M1, M2, T, P, varargin)
            %% Runs the VS-Lite forward model
            %
            % trw = vslitePSM.run(phi, T1, T2, M1, M2, T, P, varargin)
            % Runs the VS-Lite PSM given monthly temperature and
            % precipitation data at a site.
            %
            % ----- Inputs -----
            %
            % T: A matrix of temperature data with 12 rows (one per month).
            %    First row is January
            %
            % P: A matrix of precipitation data with 12 rows (one per moth).
            %    First row is January.
            %
            % Please see the documentation on VS-Lite function
            % "VSLite_v2_3" for details on the other inputs.
            %
            % ----- Outputs -----
            %
            % trw: Estimates of tree ring width.
            
            % Error check
            vars = {phi, T1, T2, M1, M2};
            names = ["phi","T1","T2","M1","M2"];
            for v = 1:numel(vars)
                assert(isnumeric(vars{v}) && isscalar(vars{v}), sprintf('%s must be a numeric scalar', names(v)));
            end
            assert(isnumeric(T) && ismatrix(T) && size(T,1)==12, 'T must be a numeric matrix with 12 rows');
            assert(isnumeric(P) && ismatrix(P) && size(P,1)==12, 'P must be a numeric matrix with 12 rows');
            assert(isequal(size(T), size(P)), 'T and P must have the same size');
            
            % Run the PSM
            syear = 1;
            eyear = size(T,2);
            Y = VSLite_v2_3(syear, eyear, phi, T1, T2, M1, M2, T, P, varargin{:});
        end
    end
    
    methods
        % Constructor
        function[obj] = vslite(rows, phi, T1, T2, M1, M2, options, name)
            %% Creates a new vslitePSM object
            %
            % obj = vslitePSM(rows, phi, T1, T2, M1, M2, options)
            % Creates a VS-Lite PSM for a set of temperature and
            % precipitation values
            %
            % obj = vslitePSM(..., name)
            % Optionally name the PSM
            %
            % ----- Inputs -----
            %
            % rows: The state vector rows with the monthly temperature and
            %    precipitation data for the site. The first 12 rows are
            %    January-December temperature. Rows 13-24 are
            %    January-December precipitation.
            %
            % options: A cell vector with the "varargin" inputs for the
            %    VS-Lite function.
            %
            % name: An optional name for the PSM. A string.
            %
            % ----- Outputs -----
            %
            % obj: A new vslitePSM object

            % Name, rows, etc
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            obj@PSM.Interface(name, false);
            obj = obj.useRows(rows, 24);
            
            % Save the parameters
            obj.phi = phi;
            obj.T1 = T1;
            obj.T2 = T2;
            obj.M1 = M1;
            obj.M2 = M2;
            obj.options = options;
        end
        
        function[Y] = runPSM(obj, X)
            %% Runs the VS-Lite PSM given data from a state vector ensemble
            %
            % trw = obj.runPSM(X)
            %
            % ----- Inputs -----
            %
            % X: State vector data used to run the PSM. A numeric matrix
            %    with 24 rows. Rows 1-12 are monthly temperatures from
            %    January to December. Rows 13-24 are monthly precipitations
            %    from January to December.
            %
            % ----- Outputs -----
            %
            % trw: Estimates of tree-ring width.
            
            T = X(1:12, :);
            P = X(13:24, :);
            Y = obj.run(obj.phi, obj.T1, obj.T2, obj.M1, obj.M2, T, P, obj.options{:});
        end
    end
    
end