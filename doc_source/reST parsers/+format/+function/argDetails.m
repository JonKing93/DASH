function[content] = argDetails(types, details)
%% reST markup for input/output descriptions
% ----------
%   content = argDetails(types, details)
% ----------
%   Inputs:
%       types (string vector [nInput]): Data type details for each input
%       details (cell vector [nInput]): Description of each input. Elements
%           are paragraphs of description
%
%   Outputs:
%       content (string scalar): .rst markup for each input/output


% Get content string for each arg
content = strings(size(types));
for k = 1:numel(types)
    
    % Type, if available
    typeline = "";
    if strlength(types(k))~=0
        typeline = sprintf("| %s\n", types(k));
    end
    
    % Glue the type to the first paragraph of the description
    paragraph1 = sprintf("| %s", details{k}(1));
    content(k) = strcat(...
        typeline, ...
        paragraph1, "\n" ...
        );
    
    % All following paragraphs receive normal spacing.
    for p = 2:numel(details{k})
        content(k) = strcat(content(k), "\n", details{k}(p), '\n');
    end
end

end