function[rst] = content(helpText)
%% build.package.content  Builds the "Content" section of a package RST from help text
% ----------
%   rst = build.package.content(helpText)
% ----------
%   Inputs:
%       helpText (char vector): Help text for a package
%
%   Outputs:
%       rst (char vector): Formatted RST for the contents section

% Get contents and details
[sections, sectionTypes, summaries, headings, files, h1] = parse.packageContents(helpText);

% Link the files in each section/heading
subfolder = parse.name(helpText);
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