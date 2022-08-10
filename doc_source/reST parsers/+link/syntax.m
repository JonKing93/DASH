function[links] = syntax(title, nSyntax)
%% link.syntax  Gets the links from the syntax signature blocks to their usage details
% ----------
%   links = link.syntax(title, nSyntax)
%   Gets the link to the usage details for each syntax signature block.
% ----------
%   Inputs:
%       title (string scalar): The title of the function
%       nSyntax (scalar positive integer): The number of syntaxes in the help text
%
%   Outputs:
%       links (string vector [nSyntax]): The link to the usage details for each syntax

links = strings(nSyntax, 1);
for k = 1:nSyntax
    links(k) = sprintf('%s.syntax%.f', title, k);
end

end