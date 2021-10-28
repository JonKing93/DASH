function[line, hastext] = line(line, k)

% Default is text in the description section
if ~exist('k','var') || isempty(k)
    k = 5;
end

% Parse
hastext = any(~isspace(line(2:end)));
if hastext
    line = strip(line, 'right');
    line = line(k:end);
    line = string(line);
end
end
