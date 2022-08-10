function[rst] = args(sectionTitle, names, types, details, links, handles)
%% format.args  Build the rst markup for input/output arguments
% ----------
%   rst = format.args(sectionTitle, names, types, details, links, handles)
%   Builds the reST markup for an input/output section. Emphasizes type
%   descriptions and places the content for each argument in a collapsible
%   accordion.
% ----------
%   Inputs:
%       sectionTitle (string scalar): The title of the section. Typically
%           "Input Arguments" or "Output Arguments"
%       names (string vector [nArgs]): The names of the input/output arguments
%       types (string vector [nArgs]): A type description of each argument
%       details (string vector [nArgs]): A description of each argument.
%           Individual paragraphs are separated by newlines
%       links (string vector): A reference hyperlink for each argument
%       handles (string vector): The handles for the collapsible accordion sections
%
%   Outputs:
%       rst (char vector): The reST markdown for the section

% Empty case
if isempty(names)
    rst = '';
    return
end

% Italicize the type declarations. Bold struct fields. Combine with the
% details to get the formatted content for each argument
types = italicizeTypes(types);
details = boldStructFields(details);
content = formatContent(types, details);

% Section underline
underline = repmat('-', [1, strlength(sectionTitle)]);

% Content blocks
nArgs = numel(content);
blocks = strings(nArgs, 1);
for a = 1:nArgs
    blocks(a) = formatBlock(names(a), content(a), links(a), handles(a));
end
blocks = join(blocks, "\n\n\n");

% Format the section
rst = strcat(...
    sectionTitle,"\n",...
    underline,   '\n',...
                 '\n',...
    blocks,           ... trailing newline
                 '\n',...
                 '\n',...
    '----',      '\n',...
                 '\n'...
    );

end


% Utilities
function[rst] = italicizeTypes(types)
%% format.argTypes  Italicizes alphanumeric text in an argument type description
% ----------
%   rst = format.argTypes(types)
%   Formats reST markdown for a type description such that numbers and
%   letters are italicized. Punctuation and whitespaces are not italicized.
% ----------
%   Inputs:
%       types (string vector [nArgs]): A series of argument type descriptions
%
%   Outputs:
%       rst (char vector): reST markdown for the type descriptions

rst = strings(size(types));

% Initialize each line with emphasis
for t = 1:numel(types)
    line = char(types(t));
    out = '';
    
    % Cycle through characters
    inEmphasis = false;
    inBracket = false;
    nChars = numel(line);
    for c = 1:nChars
        
        % Initiate emphasis
        if ~inEmphasis && ~inBracket && isletter(line(c)) % || ismember(line(c), '1234567890'))
            out = [out, '*', line(c)]; 
            inEmphasis = true;
            
        % Begin bracket
        elseif inEmphasis && line(c)=='['
            out = [out, '* ['];
            inBracket = true;
            inEmphasis = false;
            
        % End bracket
        elseif inBracket && line(c)==']'
            out = [out, ']']; %#ok<*AGROW>
            inBracket = false;
            
        % End emphasis with |
        elseif inEmphasis && line(c)=='|'
            out = [out, '*|'];
            inEmphasis = false;
            
        % End emphasis with non-letter
        elseif inEmphasis && ~isletter(line(c))  %  && ~ismember(line(c), '1234567890')
            out = [out, '*', line(c)];
            inEmphasis = false;
            
        % End emphasis with end of description
        elseif inEmphasis && c==nChars
            out = [out, line(c), '*'];
            
        % Anything else gets pasted directly into output
        else
            out = [out, line(c)];
        end
    end
    
    % Return string format
    rst(t) = string(out);
end

end
function[details] = boldStructFields(details)

% Get the paragraphs in each set of details
for k = 1:numel(details)
    paragraphs = split(details(k), newline);

    % If a paragraph begins with a ., bold the first word
    for p = 1:numel(paragraphs)
        line = char(paragraphs(p));
        if line(1) == '.'
            spaces = strfind(line, ' ');
            space1 = spaces(1);
            line = ['**', line(1:space1-1), '**', line(space1:end)];

            % Reform the details
            paragraphs(p) = line;
        end
    end
    details(k) = join(paragraphs, newline);
end

end
function[content] = formatContent(types, details)
%% Formats the combined type description and argument details
%
% Inputs:
%   types (string vector [nArgs]): reST markup for the type descriptions in which
%       the descriptions have been italicized
%   details (string vector [nArgs]): Details for each argument. Separate
%       paragraphs are separated by newlines
%
% Outputs:
%   content (string vector [nArgs]): Formatted RST for the type description
%       and details of each argument. Separate paragraphs are separated by
%       newlines.

% Preallocate content string for each arg
nArgs = numel(types);
content = strings(nArgs, 1);

% Split apart the paragraphs of each description
for a = 1:nArgs
    paragraphs = split(details(a), newline);

    % Glue the type description to the first paragraph
    paragraphs(1) = sprintf([...
        '| %s\n',...
        '| %s'], ...
        types(a), paragraphs(1));

    % All subsequent paragraphs receive normal spacing. End the description
    % with a newline
    content(a) = join(paragraphs, [newline newline]);
    content(a) = strcat(content(a), "\n");
end

end
function[rst] = formatBlock(name, content, link, handle)

% Build components
accordion = format.accordion(name, content, handle, true);
reflink = sprintf(".. _%s:", link);
underline = repmat('+', [1, strlength(name)]);

% Format
rst = strcat(...
    ".. rst-class:: collapse-examples", '\n',...
                                        '\n',...
    reflink,                            '\n',...
                                        '\n',...
    name,                               '\n',...
    underline,                          '\n',...
                                        '\n',...
    accordion                                ... % trailing newline
    );
    
end