classdef prebuiltGrids
    
    properties
        grids;
        dataSources;
        f;
    end
    
    methods
        function[obj] = prebuiltGrids(grids, sources, f)
            obj.grids = grids;
            obj.dataSources = sources;
            obj.f = f;
        end
        function[g] = grid(obj, v)
            g = obj.grids{obj.f(v)};
        end
        function[s] = source(obj, v)
            s = obj.sources{obj.f(v)};
        end
        function[obj] = sources(obj, sources, v)
            obj.dataSources(obj.f(v)) = sources;
        end
    end
end