function[rst] = title(title, description)
%% reST markup for the title of a documentation page
% ----------
%   rst = format.title(title, description)
% ----------
%   Inputs:
%       title (string scalar): Function title
%       description (string scalar): Function H1 description
%
%   Outputs:
%       rst (string scalar): reST markup for the title

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




