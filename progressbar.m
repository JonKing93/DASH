classdef progressbar < handle
    %% This is a skeleton progress bar class


    properties
        handle;             % The handle to the waitbar
        message;            % The message for the waitbar
        ongoing;    % Whether the progress bar is part of an ongoing operation

        count;
        max;
    end


    methods
        function[obj] = progressbar
            obj.handle = waitbar(0,'');
        end
        function[] = delete(obj)
            %% Deletes the progress bar window no matter the error case
            delete(obj.handle);
        end
        function[] = setMessage(obj, message)
            obj.message = [char(message), ': '];
        end
        function[] = update(obj, x)
            messageText = [obj.message, sprintf('%.f%%', 100*x)];
            waitbar(x, obj.handle, messageText);
        end
        function[] = updateMessage(obj, message)
            messageText = obj.message;
            if exist('message','var')
                messageText = [messageText, message];
            end
            waitbar(0, obj.handle, messageText);
        end
        function[] = startCount(max)
            obj.count = 0;
            obj.max = max;
        end
    end
end

        