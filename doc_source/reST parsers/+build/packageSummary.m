function[rst] = packageSummary(help)

[title, h1] = parse.packageTitle(help);
details = parse.packageDescription(help);
rst = format.packageSummary(title, h1, details);

end