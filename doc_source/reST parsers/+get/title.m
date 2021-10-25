function[line] = title(header)
%% Get the H1 line
% ----------
%   line = get.title(header)
% ----------
%   Inputs:
%       header (char vector): The function help text
%
%   Outputs:
%       line (char vector): The initial (H1) line
eol1 = find(header==10,1);
line = header(1:eol1);
end