function[titleEnd] = titleEnd(text, istitle)

% Default
if ~exist('istitle','var') || isempty(istitle)
    istitle = false;
end

% Get the title text
if ~istitle
    title = parse.title(text);
else
    title = text;
end

% Split and get end
titleParts = split(title, ".");
titleEnd = titleParts(end);

end
   