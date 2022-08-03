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

% Whitespace pad
text = [' ', text, ' '];

% Use regular expression to find args
for k = 1:numel(keys)
    pattern = sprintf("[ ,]%s[ ,]", keys(k));
    [start, stop] = regexp(text, pattern);
    replace = sprintf(':ref:`%s <%s>`', keys(k), links(k));
    
    % Replace each match with a link
    for s = numel(start):-1:1
        text = [text(1:start(s)), replace, text(stop(s):end)];
    end
end

% Remove whitespace padding
text = text(2:end-1);

end