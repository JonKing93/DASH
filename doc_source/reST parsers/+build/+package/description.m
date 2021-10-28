function[rst] = description(text)

[title, h1] = parse.h1(text);
description = get.description(text);
description = parse.paragraphs(description);
rst = format.package.description(title, h1, description);

end