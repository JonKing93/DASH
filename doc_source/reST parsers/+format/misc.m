function[rst] = misc(sectionTitle, description)
%% format.misc  Builds the RST for a miscellaneous block in a function or method
% ----------
%   rst = format.misc(sectionTitle, description)
%   Formats the rst for a miscellaneous description block in a function or
%   method. Typically, these are "Prints", "Saves", or "Downloads". If the
%   description is empty, returns an empty char array.
% ----------
%   Inputs:
%       sectionTitle (string vector): The title of the section
%       description (string scalar | ''): The section description. If
%           empty, returns an empty char
%
%   Outputs:
%       rst (char vector | ''): The rst markup for the section

% Empty case
if isempty(description)
    rst = '';
    return
end

% Build components
newlin = string(newline);
underline = repmat('-', [1 strlength(sectionTitle)]);

% Format
rst = strcat(...
    sectionTitle,    newlin,...
    underline,       newlin,...
                     newlin,...
    description,     newlin,...
                     newlin,...
                     newlin,...
    '----',          newlin,...
                     newlin...
    );

end

