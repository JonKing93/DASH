function[title, description] = packageTitle(help)
title = get.title(help);
[title, description] = parse.title(title);
end