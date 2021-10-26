function[lastLine] = lastUsageLine(header, eols)
%% Find the index of the last line of the usage section of help text
% ----------
%   lastLine = get.lastUsageLine(header, eols)
%   Get the index of the second line with 10 -s.
% ----------
%   Inputs:
%       header (char vector): The function help text
%       eols (vector, linear indices): The indices of end-of-line markers
%           in the help text
%
%   Outputs:
%       lastLine (scalar, linear index): The index of the element in eols
%           that corresponds to the last line of the usage section.

for k = numel(eols):-1:2
    line = header(eols(k-1):eols(k));
    if contains(line, '% ----------')
        lastLine = k;
        break;
    end
end

end