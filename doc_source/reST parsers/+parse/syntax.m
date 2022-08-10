function[signatures, usageDetails] = syntax(titles, description)
%% parse.syntax  Parses syntax and usage details from a help text description
% ----------
%   [signatures, usageDetails] = parse.syntax(title, description)
%   Scans through description text for syntax signatures. Groups blocks of
%   signatures and returns usage details.
% ----------
%   Inputs:
%       title (string vector): The syntax titles of the function or method
%       description (char vector): The description help text for a function or method
%       
%   Outputs:
%       signatures (string vector [nSyntax]): A collection of signature
%           blocks. Individual signatures are separated by newlines
%       usageDetails (string vector [nSyntax]): Usage details for each
%           signature block. Paragraphs are separated by newlines.

% Don't allow an empty description
if isempty(description)
    error('rst:parser', 'The description is empty');
end

% Locate syntax signatures. Disregard signatures that follow the Matlab
% console prompt >>
signatures = [];
for t = 1:numel(titles)
    signatures = [signatures, strfind(description, titles(t))]; %#ok<AGROW> 
    prompt = strcat(">> ", titles(t));
    disregard = strfind(description, prompt) + 3;
    remove = ismember(signatures, disregard);
    signatures(remove) = [];
end
signatures = sort(signatures);

% Throw error if there are no signatures
nSignatures = numel(signatures);
if nSignatures == 0
    error('rst:parser', 'Could not locate syntax signatures');
end

% Get the end of each line of the description
eol = find(description==10);
nLines = numel(eol);

% Determine the lines holding a signature
signatureLines = NaN(nSignatures, 1);
for s = 1:nSignatures
    signatureLines(s) = find(eol>signatures(s), 1);
end
if signatureLines(1)~=1
    error('rst:parser', 'The first line of the description does not contain a syntax signature');
end

% Check that each signature line has no text following the end of the signature
for s = 1:nSignatures
    line = get.line(signatureLines(s), description, eol);
    if ~endsWith(line, ')') && ~endsWith(line, titles)
        error('rst:parser', 'Signature %.f has text following the signature', s);
    end
end

% Group signatures on adjacent lines into a single signature block.
adjacent = signatureLines(2:end) == signatureLines(1:end-1)+1;
isstart = [true; ~adjacent];
blockID = cumsum(isstart);

% Get the line limits of each signature block
[~, start] = unique(blockID);
[~, stop] = unique(blockID, 'last');
signatureLimits = signatureLines([start, stop]);
if iscolumn(signatureLimits)
    signatureLimits = signatureLimits';
end

% Get the line limits of each usage block. Require usage details for each syntax
usageLimits = [signatureLimits(:,2)+1, [signatureLimits(2:end,1)-2; nLines]];
missingUsage = usageLimits(:,1) > usageLimits(:,2);
if any(missingUsage)
    bad = find(missingUsage);
    error('rst:parser', 'syntax %.f does not have usage details', bad);
end

% Preallocate signature blocks and usage details
nSyntax = size(signatureLimits,1);
signatures = strings(nSyntax, 1);
usageDetails = strings(nSyntax, 1);

% Iterate through syntaxes. Require an empty line between each syntax
for s = 1:nSyntax
    if s>1
        lineNumber = signatureLimits(s,1) - 1;
        line = get.line(lineNumber, description, eol);
        if line ~= ""
            error('rst:parser', 'There is not an empty line before syntax %.f', s);
        end
    end

    % Get the signature block
    nSignatures = signatureLimits(s,2) - signatureLimits(s,1) + 1;
    signatureBlock = strings(nSignatures, 1);
    for k = 1:nSignatures
        lineNumber = signatureLimits(s,1) + k - 1;
        signatureBlock(k) = get.line(lineNumber, description, eol);
    end
    signatures(s) = join(signatureBlock, newline);

    % Iterate through lines of the usage details
    for lineNumber = usageLimits(s,1) : usageLimits(s,2)
        line = get.line(lineNumber, description, eol);

        % The first line cannot be empty
        if lineNumber == usageLimits(s,1)
            if line == ""
                error('rst:parser', 'The first line of the usage details for syntax %.f is empty', s);
            end
            usageDetails(s) = line;
            newParagraph = false;

        % Empty lines trigger a new paragraph
        elseif line == ""
            newParagraph = true;
        elseif newParagraph
            usageDetails(s) = join([usageDetails(s), line], newline);
            newParagraph = false;

        % For continuing paragraphs, add a space between each consecutive line
        else
            usageDetails(s) = strcat(usageDetails(s), " ", line);
        end
    end
end

end