function[links] = syntax(title, nSyntax)
%% Get the links to descriptions of function signatures. (From sytnax to description)
% ----------
%   links = link.syntax(title, nSyntax)
% ----------
%   Inputs:
%       title (char vector): Title of a function
%       nSyntax (scalar integer): The number of syntaxes in the docs
%
%   Outputs:
%       links (string vector): A link for the description of each syntax.

links = strings(nSyntax, 1);
for k = 1:nSyntax
    links(k) = sprintf('%s.syntax%.f', title, k);
end

end