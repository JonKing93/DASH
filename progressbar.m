classdef progressbar < handle
    %% This is a skeleton progress bar class


    properties
        handle;     % The handle to the waitbar
        max;        % The maximum number of iterations
    end


    methods
        function[] = delete(obj)
            %% Deletes the progress bar window no matter the error case
            delete(obj.handle);
        end
    end
end

        