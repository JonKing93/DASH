function[rst] = packageContents(sections, files, h1, links)

% Join the section blocks
rst = [];
for s = 1:numel(sections)
    nextblock = format.block.packageContent(sections(s), files{s}, h1{s}, links{s});
    rst = strjoin([rst, nextblock], "\n\n");
end

end