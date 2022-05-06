function[line] = title(helpText)
%% get.title  Extracts the H1 line of help text
% ----------
%   line = get.title(header)
% ----------
%   Inputs:
%       header (char vector): The function help text
%
%   Outputs:
%       line (char vector): The initial (H1) line
eol1 = find(helpText==10,1);
line = helpText(1:eol1);
end