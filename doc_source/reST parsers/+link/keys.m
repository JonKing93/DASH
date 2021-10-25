function[text] = keys(text, keys, links)
%% Replaces arg keys with links in a section of text
% ----------
%   text = link.keys(text, keys, links)
% ----------
%   Inputs:
%       text (char vector): Text containing keys to be linked
%       keys (string vector): List of keys that should be linked
%       links (string vector): The link for each key
%
%   Outputs:
%       text (char vector): Text with linked keys

newKey = true;
keyEnded = false;
current = '';
for t = numel(text):-1:1
    char = text(t);
    isarg = ~ismember(char, [" ", ","]);
    
    % Part of an arg
    if isarg
        if newKey
            last = t;
            newKey = false;
        end
        if t==1
            first = t;
            keyEnded = true;
        end
        current = [char, current]; %#ok<AGROW>
        
    % Exited an arg
    elseif ~isarg && ~isempty(current)
        first = t+1;
        keyEnded = true;
    end
    
    % Replace completed keys with links
    if keyEnded
        k = strcmp(current, keys);
        ref = sprintf(':ref:`%s <%s>`', current, links{k});
        text = [text(1:first-1), ref, text(last+1:end)];
        
        newKey = true;
        keyEnded = false;
        current = '';
    end
end

end