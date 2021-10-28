function[name] = name(header, istitle)
%% parse.name  The short name of a function/class/method/package/etc.

% Default
if ~exist('istitle','var') || isempty(istitle)
    istitle = false;
end

% Extract title if a full header
if ~istitle
    title = parse.h1(header);
else
    title = header;
end

% Split off the name
titleParts = split(title, {'.','/'});
name = string( titleParts(end) );

end