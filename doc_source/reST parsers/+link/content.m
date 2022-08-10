function[sectionLinks] = content(title, sectionFiles)
%% link.content  Gets links to the contents of a class or package
% ----------
%   sectionLinks = link.content(title, sectionFiles)
%   Builds the toctree links to the contents of a package or class.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the item
%       sectionFiles (string vector [nSections]): The files in each section of the
%           item's contents. Individual files within a section are
%           separated by newlines.
%
%   Outputs:
%       sectionLinks (string vector [nSections]): The toctree links for the files
%           within each section. Individual links within a section are
%           separated by newlines

% Get the immediate subfolder matching the item's name
title = split(title, '.');
name = string(title(end));

% Preallocate
nSections = numel(sectionFiles);
sectionLinks = strings(nSections, 1);

% Get the files in each section
for s = 1:nSections
    files = split(sectionFiles(s), newline);

    % Get the link for each file
    for f = 1:numel(files)
        files(f) = sprintf('%s <%s/%s>', files(f), name, files(f));
    end

    % Reformat links with newlines
    sectionLinks(s) = join(files, newline);
end

end

