function[rst] = content(help)

% Get contents and details
[sections, sectionTypes, summaries, headings, files, h1] = parse.packageContents(help);

% Link the files in each section/heading
subfolder = parse.name(help);
links = files;
for s = 1:numel(sections)
    for h = 1:numel(headings{s})
        for f = 1:numel(files{s}{h})
            links{s}{h}(f) = link.content(subfolder, files{s}{h}(f));
        end
    end
end

% Format the rst
rst = format.package.content(sections, sectionTypes, summaries, headings, files, h1, links);

end