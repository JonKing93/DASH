function[rst] = classRST(title)
%% build.classRST  Builds the reST markup for the help text of a class
% ----------
%   rst = build.classRST(title)
%   Scans the help text for a class and formats into reST markup
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the class
%
%   Outputs:
%       rst (char vector): Formatted RST for the class documentation page

% Get the help text sections
try
    [h1, description, methods] = get.help(title);
    methods = get.aboveLink(title, methods);
    
    % Parse the description and the class methods
    [descriptionSections, descriptionContents] = parse.description(description);
    [groups, groupTypes, groupSummaries, groupSections, sectionMethods, methodSummaries] = ...
                                                        parse.methods(title, methods);
    
    % Get inheritance for each group
    nGroups = numel(groups);
    groupInheritance = strings(nGroups, 1);
    for g = 1:nGroups
    
        % Get inheritance for group sections
        sections = split(sectionMethods(g), [newline newline]);
        nSections = numel(sections);
        sectionInheritance = strings(nSections, 1);
        for s = 1:nSections
    
            % Get inheritance for methods in sections
            methodNames = split(sections(s), newline);
            nMethods = numel(methodNames);
            inherited = false(nMethods, 1);
            for m = 1:nMethods
                methodTitle = strcat(title, ".", methodNames(m));
                inherited(m) = isinherited(methodTitle);
            end
    
            % Restructure back into groups
            inherited = inherited + 0;
            inherited = string(inherited);
            sectionInheritance(s) = join(inherited, "");
        end
        groupInheritance(g) = join(sectionInheritance, newline);
    end
    methodInheritance = groupInheritance;
    
    % Link the files in each section of each group
    for g = 1:nGroups
        groupFiles = split(sectionMethods(g), [newline newline]);
        groupFiles = link.content(title, groupFiles);
        sectionMethods(g) = join(groupFiles, [newline newline]);
    end
    
    % Format the RST sections and join into the final rst markup
    rst.introduction = format.introduction(title, h1, descriptionSections, descriptionContents);
    rst.methods = format.methods(groups, groupTypes, groupSummaries, groupSections, sectionMethods, methodSummaries, methodInheritance);
    rst = strcat(rst.introduction, rst.methods);

% Informative errors
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        editLink = sprintf('<a href="matlab:edit %s">%s</a>', title, title);
        ME = MException('rst:parser', 'Could not build the RST for %s', editLink);
        ME = addCause(ME, cause);
        throw(ME);
    else
        rethrow(cause);
    end
end

end