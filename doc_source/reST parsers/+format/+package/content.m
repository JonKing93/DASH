function[rst] = content(sections, summaries, headings, files, h1, links)

% Join the section blocks
rst = [];
for s = 1:numel(sections)
    nextblock = format.block.section(sections(s), summaries(s), headings{s}, files{s}, h1{s}, links{s});
    rst = strjoin([rst, nextblock], "\n\n\n");
end

end