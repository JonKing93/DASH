classdef vslitePSM < PSM
    
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
        function[obj] = vslitePSM(rows, phi, T1, T2, M1, M2, options, name)
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            obj@PSM(name, false);
            obj = obj.useRows(rows, 24);
            
            obj.phi = phi;
            obj.T1 = T1;
            obj.T2 = T2;
            obj.M1 = M1;
            obj.M2 = M2;
            obj.options = options;
        end
        
        %
        function[Y] = runPSM(obj, X)
            
            T = X(1:12, :);
            P = X(13:24, :);
            
            Y = obj.run(obj.phi, obj.T1, obj.T2, obj.M1, obj.M2, T, P, obj.options{:});
        end
    end
    
end