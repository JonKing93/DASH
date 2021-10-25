function[names, types, details] = parameters(type, header)
%% Parse names, types, and details of function inputs and outputs
% ----------
%   [names, types, details] = parse.parameters(type, header)
% ----------
%   Inputs:
%       type (string scalar): "Inputs" or "Outputs"
%       header (char vector): Function help text
%
%   Outputs:
%       names (string vector): List of parameter names
%       type (string vector): Info about the data type of each parameter
%       details (cell vector): Details about each parameter. Elements are
%           paragraphs of the description.

% Extract header text
args = get.args(type, header);

% Initialize outputs
names = strings(0,1);
types = strings(0,1);
details = cell(0,1);
entry = 0;

% Scan through lines
eol = find(args==10);
for k = 2:numel(eol)
    line = args(eol(k-1)+1:eol(k));
    line = strip(line, 'right');
    line = line(9:end);
    
    % New parameter
    if ~isspace(line(1))        
        space1 = find(isspace(line),1);
        colon1 = find(line==':', 1);
        
        % Type and name
        if isempty(space1) || colon1<space1   % no type
            name = line(1:colon1-1);
            type = '';        
        else                                  % has type
            name = line(1:space1-1);
            type = line(space1+2:colon1-2);
        end
        names = cat(1, names, name);
        types = cat(1, types, type);
        
        % Initialize details
        details = cat(1, details, {strings(0,1)});
        entry = entry+1;
        paragraph = 0;
        
        % Begin first paragraph if details are on line
        if ~isempty(line(colon1:end))
            details{entry} = cat(1, details{entry}, line(colon1+2:end));
            paragraph = 1;
        end
        
    % Bracket or empty first line initiate new paragraph
    elseif line(5)=='[' || isempty(details{entry})
        details{entry} = cat(1, details{entry}, line(5:end));
        paragraph = paragraph + 1;
        
    % Otherwise continue current paragraph
    else
        line = strip(line, 'left');
        details{entry}(paragraph) = strcat(details{entry}(paragraph), " ", line);
    end
end

end