function[rst] = packageRST(title)
%% build.packageRST  Builds the reST markup for the help text from a package's Contents.m file
% ----------
%   rst = build.packageRST(title)
%   Scans the help text from a package's Contents.m file and formats the
%   contents into reST markup.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the package
%
%   Outputs:
%       rst (char vector): Formatted RST for the package documentation page

% Get the help text sections
try
    [h1, description, contents] = get.help(title);
    contents = get.aboveLink(title, contents);
    
    % Parse the description and the package contents
    [descriptionSections, descriptionContents] = parse.description(description);
    [contentSections, sectionFiles, fileSummaries] = parse.content(contents);
    
    % Build the file links in the content sections
    sectionFiles = link.content(title, sectionFiles);
    
    % Format the RST sections and join into the final rst markup
    rst.introduction = format.introduction(title, h1, descriptionSections, descriptionContents);
    rst.contents = format.content(contentSections, sectionFiles, fileSummaries);
    rst = strcat(rst.introduction, rst.contents);

% Informative errors
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        editLink = sprintf('<a href="matlab:edit %s.Contents">%s</a>', title, title);
        ME = MException('rst:parser', 'Could not build the RST for %s', editLink);
        ME = addCause(ME, cause);
        throw(ME);
    else
        rethrow(cause);
    end
end

end
