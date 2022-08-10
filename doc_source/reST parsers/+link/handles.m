function[handles] = handles(sectionName, N)
%% link.handles  Get handle IDs for a section with collapsible accordions
% ----------
%   handles = link.handles(sectionName, N)
% ----------
%   Inputs:
%       sectionName (string scalar): The name of the section with collapisble
%           accordions. Usually "input", "output", "example", etc.
%       N (scalar integer): The number of collapsible accordions in the
%           section.
%
%   Outputs:
%       handles (string vector): List of handle IDs.

handles = strings(N,1);
for k = 1:N
    handles(k) = sprintf("%s%.f", sectionName, k);
end

end