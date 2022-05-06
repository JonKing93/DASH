function[signatures, details] = usage(header)
%% pages.usage  Extract function signatures and usage details from the description section of help text
% ----------
%   [signatures, details] = parse.usage(header)
%   Searches through function help text to find the description/syntax
%   section, which should be between two section breaks.
% ----------
%   Inputs: 
%       header (char vector): Function help text
%
%   Outputs:
%       signatures (string vector [nSyntax]): List of possible function signatures
%       details (cell vector [nSyntax] {string vector}): Usage details for each signature. Elements
%           are paragraphs of the description.

% Get the usage text
usage = get.description(header);
if isempty(usage)
    error('Missing syntax descriptions');
end

% Iterate through each line of the usage text
eol = find(usage==10);
lineStarts = [1, eol+1];
lineEnds = [eol, numel(usage)];
for k = 1:numel(lineStarts)
    line = lineStarts(k):lineEnds(k);
    line = usage(line);

    % Remove trailing whitespace. Require empty line or proper indentation
    line = strip(line, 'right');
    if numel(line)>1
        assert(numel(line)>=4 && strcmp(line(1:4),'%   '), 'Syntax description line %.f is not indented correctly', k);
    end
end

% Pad usage with newlines
usage = [newline, usage, newline];

% Regular title
title = parse.h1(header);
signatureIndices = strfind(usage, title);

% Object methods
if isempty(signatureIndices)
    name = parse.name(header);
    objCall = sprintf("obj.%s", name);
    signatureIndices = sprintf("<strong>%s</strong>", objCall);

    % Ensure that all object calls have <strong> tags
    if any(objCall)
        assert(all(ismember(objCall, signatureIndices)), 'There are object calls missing the <strong> tags');
    end
end

% Class constructor
if isempty(signatureIndices)
    titleParts = split(title, '.');
    if strcmp(titleParts(end), titleParts(end-1))
        constructorTitle = strjoin(titleParts(1:end-1), '.');
        signatureIndices = strfind(usage, constructorTitle);
    end
end

% Throw error if no signatures
assert(~isempty(signatureIndices), 'Could not locate usage signatures');

% Group the signature blocks
eol = find(usage==10);
sigBlocks = {};
b = 0;
previousLine = -Inf;
for k = 1:numel(signatureIndices)
    currentLine = find(eol>signatureIndices(k),1);
    if currentLine>previousLine+1
        b = b+1;
        sigBlocks{b,1} = signatureIndices(k);
    else
        sigBlocks{b,1} = cat(1, sigBlocks{b,1}, signatureIndices(k));
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