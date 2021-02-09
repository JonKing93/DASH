classdef progressbar < handle
    % Implements a progress bar
    
    % ----- Written By -----
    % Jonathan King, University of Arizona, 2019-2020
    
    properties
        show;
        handle;
        title;
        current;
        max;
        step;
    end
    
    methods
        function[obj] = progressbar(show, title, max, step)
            obj.show = show;
            if obj.show
                obj.title = title;
                obj.current = 0;
                obj.max = max;
                obj.step = step;
            end
        end
        function[msg] = message(obj, x)
            msg = strcat(obj.title, sprintf(' %.f%%', 100*x));
        end
        function[] = update(obj)
            if obj.show
                obj.current = obj.current+1;
                if isempty(obj.handle)
                    x = obj.current / obj.max;
                    obj.handle = waitbar(x, obj.message(x));
                elseif obj.current == obj.max
                    obj.delete;
                elseif mod(obj.current, obj.step)==0
                    x = obj.current / obj.max;
                    waitbar(x, obj.handle, obj.message(x));
                end
            end
        end
        function[] = delete(obj)
            delete(obj.handle);
        end
    end 
end
        
            