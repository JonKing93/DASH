function[class, isinherited] = methodClass(header)

% Get the class name
title = char(parse.h1(header));
title = replace(title, '/', '.');
lastDot = strfind(title, '.');
lastDot = lastDot(end);
class = title(1:lastDot-1);

% Parse whether inherited
eol = find(header==10);
lastLine = header(eol(end-1)+1:eol(end));
if contains(lastLine, '%elp for') && contains(lastLine, 'is inherited from superclass')
    isinherited = true;
else
    isinherited = false;
end

end