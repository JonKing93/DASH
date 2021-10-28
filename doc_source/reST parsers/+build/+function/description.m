function[rst] = description(header)
%% Markup the description section from function help text
% ----------
%   rst = build.description(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       rst (string scalar): reST markup for the description section

% Get the usage information and title
[signatures, details] = parse.usage(header);
title = parse.h1(header);

% Syntax Links
links = link.syntax(title, numel(signatures));

% Link signature inputs and outputs
inputs = parse.parameters('Inputs', header);
outputs = parse.parameters('Outputs', header);
signatures = link.signatureArgs(signatures, title, inputs, outputs);

% Format
rst = format.function.description(links, signatures, details);

end

