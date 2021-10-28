function[rst] = content(header)
%% Build the rst for class content

% Get contents, details, title
title = parse.h1(header);
[sections, summaries, headings, methods, h1] = parse.packageContents(header);

% Initialize method links and inherited status
links = methods;
inherited = methods;

% Cycle through the sections and headings of class content
for s = 1:numel(sections)
    for h = 1:numel(headings{s})
        nMethod = numel(methods{s}{h});
        inherited{s}{h} = false(nMethod,1);
        for m = 1:nMethod
            
            % Get the method reference links
            links{s}{h}(m) = link.method(title, methods{s}{h}(m));
            
            % Get inheritance status
            methodTitle = strcat(title, '.', methods{s}{h}(m));
            methodHelp = get.help(methodTitle);
            [~, isinherited] = parse.methodClass(methodHelp);
            inherited{s}{h}(m) = isinherited;
        end
    end
end

% Format the rst
rst = format.class.content(sections, summaries, headings, methods, h1, links, inherited);

end