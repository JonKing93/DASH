function[rst] = args(section, names, details, links, handles)
%% Get .rst markup for an Inputs or Outputs section
% ----------
%   rst = format.args(section, names, details, links, handles)
% ----------
%   Inputs:
%       section (string scalar): Section title. "Input Arguments" or
%           "Output Arguments"
%       names (string vector): The name of each input/output
%       details (string vector): The .rst markup for the description of
%           each input/output
%       links (string vector): The reference link to each input/output
%       handles (string vector): Accordion handles for each input/output
%
%   Outputs:
%       rst: The .rst markup for the input/output section

% Section underline
underline = repmat('-', [1, strlength(section)]);

% Details blocks
blocks = [];
for s = 1:numel(names)
    nextblock = format.block.arg(names(s), details(s), links(s), handles(s));
    blocks = strcat(blocks, nextblock);
end

% Format the section
rst = strcat(...
    section,     "\n",...
    underline,   '\n',...
                 '\n',...
    blocks,           ...
                      ... % trailing whitespace
    '----',      '\n',...
                 '\n' ...
    );

end
