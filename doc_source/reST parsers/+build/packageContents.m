function[rst] = packageContents(help)

% Get contents and details
[sections, files, h1] = parse.packageContents(help);

% Content links
subfolder = parse.packageSubfolder(help);
links = link.packageContents(subfolder, files);

% Format the rst
rst = format.packageContents(sections, files, h1, links);

end