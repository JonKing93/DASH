function[description] = description(header)
%% get.description  Get the description section of help text
% ----------
%   description = get.description(header)
%   The description (if it exists), begins at the third line and ends with
%   10 -s.
%
%   This is another line of details
%
%   desc = get.description
%   That was another signature line
% ----------
%   Inputs:
%       header (char vector): Help text
%
%   Outputs:
%       description (char vector): The text of the description section

% Begin at line 3
[header, eol] = get.belowH1(header);

% Check for end of description
breaks = strfind(header, '----------');
nBreaks = numel(breaks);

% Get description text
if nBreaks==0
    description = '';
elseif nBreaks==1
    lastEOL = find(eol<breaks, 1, 'last');
    endDescription = eol(lastEOL);
    description = header(1:endDescription);
else
    error('Too many section breaks "----------"');
end

end