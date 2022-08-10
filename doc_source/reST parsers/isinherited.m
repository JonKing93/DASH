function[tf] = isinherited(title)
%% isinherited  Test if a class method is inherited from a superclass
% ----------
%   tf = isinherited(title)
%   True if a class method is inherited. Otherwise false
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the method
%
%   Outputs:
%       tf (scalar logical): True if the method is inherited. Otherwise false

% Get the help text for the method
methodHelp = help(title);
if isempty(methodHelp)
    error('rst:parser', 'method "%s" not found', title);
end

% Check for the Matlab provided inheritance string
eol = find(methodHelp==10);
lastLine = get.line(numel(eol), methodHelp, eol);
if startsWith(lastLine, 'Help for') && contains(lastLine, 'is inherited from superclass')
    tf = true;
else
    tf = false;
end

end