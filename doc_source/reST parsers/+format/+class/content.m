function[rst] = content(sections, summaries, headings, files, h1, links, inherited)

% Join the section blocks
rst = [];
for s = 1:numel(sections)
    nextblock = format.class.section(sections(s), summaries(s), headings{s}, files{s}, h1{s}, links{s}, inherited{s});
    rst = strjoin([rst, nextblock], "\n\n\n");
end

end