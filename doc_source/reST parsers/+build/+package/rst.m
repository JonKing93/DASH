function[rst] = rst(title)

% Get the help text, remove everything below the doc link
help = get.help(title);
help = get.aboveLink(help);

% Build file parts
description = build.package.description(help);
contents = build.package.content(help);

% Join into rst
rst = strcat(description, contents);

end
