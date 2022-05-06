function[line] = h1(helpText)
%% get.title  Extracts the H1 line of help text
% ----------
%   line = get.h1(helpText)
% ----------
%   Inputs:
%       helpText (char vector): The help text for an item
%
%   Outputs:
%       line (char vector): The initial (H1) line of the help text

eol1 = find(helpText==10,1);
line = helpText(1:eol1-1);

end