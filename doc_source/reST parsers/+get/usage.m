function[usage] = usage(header)
%% Get the usage section of function help text
% ----------
%   usage = get.usage(header)
%   
%   The usage section is bracketed by 10 -s.
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       usage (char vector): The usage section text

eol = find(header==10);
k = get.lastUsageLine(header, eol);
usage = header(eol(2)+1:eol(k-1));

end