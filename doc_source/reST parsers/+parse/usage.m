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

title = parse.title(header);
usage = get.usage(header);

signatures = {};
details = {};
newParagraph = true;
entry = 0;

eol = [0, find(usage==10)];
for k = 2:numel(eol)
    line = usage(eol(k-1)+1:eol(k));
    hasinfo = any(~isspace(line(2:end)));
    
    % Strip newlines and tabs from information lines
    if hasinfo
        line = strip(line, 'right');
        line = line(5:end);
        line = string(line);
        
        % Signature
        if newParagraph && contains(line, title)
            signatures = cat(1, signatures, line);
            details = cat(1, details, {strings(0,1)});
            entry = entry + 1;
            paragraph = 0;
            
        % New details paragraph
        elseif newParagraph
            details{entry} = cat(1, details{entry}, line); %#ok<AGROW>
            paragraph = paragraph + 1;
            newParagraph = false;
            
        % Continuing details paragraph
        else
            details{entry}(paragraph) = strcat(details{entry}(paragraph), " ", line); %#ok<AGROW>
        end
        
    % No information triggers new paragraph
    else
        newParagraph = true;
    end
end

end


