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

% Use regular expression to replace keys
for k = 1:numel(keys)
    pattern = sprintf("[ ,]%s[ ,]", keys(k));
    ref = sprintf(':ref:`%s <%s>`', keys(k), links(k));
    text = regexprep(text, pattern, ref);
end

end