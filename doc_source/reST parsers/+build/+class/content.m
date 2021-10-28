function[rst] = content(header)
%% Build the rst for class content

% Get contents and details
[sections, summaries, headings, methods, h1] = parse.packageContents(header);

% Link the methods in each section/heading
title = parse.h1(header);
links = methods;
for s = 1:numel(sections)
    for h = 1:numel(headings{s})
        for m = 1:numel(methods{s}{h})
            links{s}{h}(m) = link.method(title, methods{s}{h}(m));
        end
    end
end

% Format the rst
rst = format.class.content(sections, summaries, headings, methods, h1, links);

end