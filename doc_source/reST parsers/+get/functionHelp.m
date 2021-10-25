function[header] = functionHelp(file)
%% Return the help text for a function
% ----------
%   header = get.functionHelp(file)
% ----------
%   Inputs:
%       file (string scalar): The name of a function file
%
%   Outputs:
%       header (char vector): The function's help text

% Load file text
text = fileread(file);

% Locate function header
eol = find(text==10);
for k = 2:numel(eol)
    if text(eol(k)+1) ~= '%'
        stop = eol(k);
        break;
    end
end

% Extract
header = text(eol(1)+1:stop);

end