function[title, h1] = h1(header)
%% Parse function title and H1 description
% ----------
%   [title, description] = parse.title(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       title (string scalar): The title of the function
%       description (string scalar): The H1 description

line = get.title(header);
line = strip(line, 'right');
line = string(strsplit(line));
line(1) = [];
title = line(1);
h1 = strjoin(line(2:end));

end