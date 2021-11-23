function[signatures, details] = usage(header)
%% Parse function signatures and usage details from help text
% ----------
%   [signatures, details] = parse.usage(header)
% ----------
%   Inputs: 
%       header (char vector): Function help text
%
%   Outputs:z
%       signatures (string vector): List of possible function signatures
%       details (cell vector): Usage details for each signature. Elements
%           are paragraphs of the description.

% Get the usage text, pad with newlines
usage = get.description(header);
usage = [newline, usage, newline];

% Regular title
title = parse.h1(header);
sigIndex = strfind(usage, title);

% Object method
if isempty(sigIndex)
    objTitle = sprintf("<strong>obj.%s</strong>", parse.name(header));
    sigIndex = strfind(usage, objTitle);
end

% Class constructor
if isempty(sigIndex)
    titleParts = split(title, '.');
    if strcmp(titleParts(end), titleParts(end-1))
        constructorTitle = strjoin(titleParts(1:end-1), '.');
        sigIndex = strfind(usage, constructorTitle);
    end
end

% Group the signature blocks
eol = find(usage==10);
sigBlocks = {};
b = 0;
previousLine = -Inf;
for k = 1:numel(sigIndex)
    currentLine = find(eol>sigIndex(k),1);
    if currentLine>previousLine+1
        b = b+1;
        sigBlocks{b,1} = sigIndex(k);
    else
        sigBlocks{b,1} = cat(1, sigBlocks{b,1}, sigIndex(k));
    end
    previousLine = currentLine;
end

% Preallocate
nSyntax = numel(sigBlocks);
signatures = cell(nSyntax, 1);
details = cell(nSyntax, 1);

% Find the EOLs that bracket each usage block
eol = find(usage==10);
eolLimit = NaN(nSyntax+1, 1);
for s = 1:nSyntax
    eolLimit(s) = find(eol<sigBlocks{s}(1), 1, 'last');
end
eolLimit(end) = numel(eol)-1;

% Get each signature line
for s = 1:nSyntax
    stop = eol(eolLimit(s));
    for k = 1:numel(sigBlocks{s})
        start = stop+1;
        stop = eol(eolLimit(s)+k);
        line = usage(start:stop);
        line = parse.line(line);
        line = erase(line, '<strong>');
        line = erase(line, '</strong>');
        signatures{s}(k) = line;
    end
    
    % And each details block
    start = stop+1;
    stop = eol( eolLimit(s+1) );
    description = usage(start:stop);
    details{s} = parse.paragraphs(description);
end

end