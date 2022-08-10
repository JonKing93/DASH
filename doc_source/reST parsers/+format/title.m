function[rst] = title(title, summary)
%% format.title  Formats the RST page title from a function title and h1 summary
% ----------
%   rst = format.function.title(title, summary)
%   Formats the RST page title for the function. The title of the page is
%   the dot-indexing name of the function. This title is major level
%   section heading and described by the function summary. The summary is
%   followed by a section break.
% ----------
%   Inputs:
%       title (string scalar): The dot-indexing title of a function
%       summary (string scalar): The H1 summary of a function
%
%   Outputs:
%       rst (char vector): Formatted RST for the page title

% Page heading
underline = repmat('=', [1, strlength(title)]);

% Format
rst = strcat(...
    title,       "\n",...
    underline,   '\n',...
    summary,     '\n',...
                 '\n',...
    '----',      '\n',...
                 '\n'...
    );

end