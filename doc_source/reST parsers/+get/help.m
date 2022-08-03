function[text] = help(name)
%% get.help  Returns the help text for an item
% ----------
%   text = help(name)
%   Returns the help text for an item. Includes "%" comment characters
%   in the help text. Double %% from H1 lines are converted to a single %.
% ----------
%   Inputs:
%       name (string scalar): The full dot-indexing title of an item.
%
%   Outputs:
%       text (char vector): The help text for the item.

% Extract the help text. Throw error if undocumented
text = help(name);
if ~isspace(text(1))
    error('"%s" does not have help text', name);
end

% Replace the first space in each line with a % character
eol = find(text==10);
comments = [1, eol(1:end-1)+1];
text(comments) = '%';

end
