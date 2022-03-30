classdef progressbar < handle

    properties
        handle;
        max;
        count;
        title;
    end

    methods
        update(obj, k);
        message = message(obj, x);
        draw(obj);
        delete(obj);
    end

    % Constructor
    methods
        function[obj] = progressbar(title, max)
            obj.title = title;
            obj.count = 0;
            obj.max = max;
            obj.handle = waitbar(0, obj.message(0));
        end
    end
end