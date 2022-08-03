function[rst] = rst(title)

% Get the help text, remove everything below the doc link
header = get.help(title);
header = get.aboveLink(header);

% Build file parts
description = build.class.description(header);
contents = build.class.content(header);

% Join into rst
rst = strcat(description, contents);

end