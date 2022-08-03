function[rst] = content(sections, sectionTypes, summaries, headings, files, h1, links)

% Join the section blocks
rst = [];
for s = 1:numel(sections)
    nextblock = format.package.section(sections(s), sectionTypes(s), summaries(s), ...
        headings{s}, files{s}, h1{s}, links{s});
    rst = strjoin([rst, nextblock], "\n\n\n");
end

end