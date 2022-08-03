function[details, eol] = details(header)
%% get.details
%
% Everything below the description, or below line 3

% Begin at line 3
[header, eol] = get.belowH1(header);

% Check for end of description block and get its line end
breaks = strfind(header, '----------');
nBreaks = numel(breaks);
if nBreaks>1
    error('Too many section breaks "----------"');
elseif nBreaks==1
    breakEOL = find(eol>breaks, 1, 'first');
end

% Get details text
if nBreaks==0 || breakEOL==numel(eol)
    details = header;
else
    start = eol(breakEOL)+1;
    details = header(start:end);
    eol = eol(breakEOL+1:end) - eol(breakEOL);
end

end