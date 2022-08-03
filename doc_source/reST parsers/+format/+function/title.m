function[rst] = title(title, description)
%% format.function.title  Formats the RST page title from a function title and summary
% ----------
%   rst = format.function.title(title, summary)
%   Formats the RST page title for the function. The title of the page is
%   the dot-indexing name of the function. This title is major level
%   section heading and described by the function summary. The summary is
%   followed by a section break.
% ----------
%   Inputs:
%       title (string scalar): The dot-indexing title of a function
%       summary (string scalar): A summary of a function
%
%   Outputs:
%       rst (char vector): Formatted RST for the page title

% Page heading
underline = repmat('=', [1, strlength(title)]);

% Format
rst = strcat(...
    title,       "\n",...
    underline,   '\n',...
    description, '\n',...
                 '\n',...
    '----',      '\n',...
                 '\n'...
    );

end