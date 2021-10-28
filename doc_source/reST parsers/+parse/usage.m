function[signatures, details] = usage(header)
%% Parse function signatures and usage details from help text
% ----------
%   [signatures, details] = parse.usage(header)
% ----------
%   Inputs: 
%       header (char vector): Function help text
%
%   Outputs:
%       signatures (string vector): List of possible function signatures
%       details (cell vector): Usage details for each signature. Elements
%           are paragraphs of the description.

% Get the usage text, pad with newlines
usage = get.description(header);
usage = [newline, usage, newline];

% Get the title and object signature title
title = parse.h1(header);
objTitle = sprintf("<strong>obj.%s</strong>", parse.name(header));

% Find the signature lines
if contains(usage, objTitle)
    sigIndex = strfind(usage, objTitle);
else
    sigIndex = strfind(usage, title);
end
nSyntax = numel(sigIndex);

% Preallocate
signatures = strings(nSyntax, 1);
details = cell(nSyntax, 1);

% Find the EOLs that bracket each usage block
eol = find(usage==10);
eolLimit = NaN(nSyntax+1, 1);
for s = 1:nSyntax
    eolLimit(s) = find(eol<sigIndex(s), 1, 'last');
end
eolLimit(end) = numel(eol)-1;

% Get each signature
for s = 1:nSyntax
    start = eol( eolLimit(s) ) + 1;
    stop = eol( eolLimit(s)+1 );
    line1 = usage(start:stop);
    signatures(s) = parse.line(line1);
    
    % And each details block
    start = stop+1;
    stop = eol( eolLimit(s+1) );
    description = usage(start:stop);
    details{s} = parse.paragraphs(description);
end

end