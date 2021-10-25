function[rst] = example(label, content, handle)
%% reST formatting for a collapsible example
% ----------
%   rst = format.block.example(label, content, handle)
% ----------
%   Inputs:
%       label (string scalar): The label for the example section
%       content (string scalar): reST formatted details for the example
%       handle (string scalar): Handle ID for the collapsible accordion
%
%   Outputs:
%       rst (string scalar): reST markup for the example

% Build components
underline = repmat('+', [1, strlength(label)]);
accordion = format.accordion(label, content, handle, false);

% Format
rst = strcat(...
    ".. rst-class:: collapse-examples", "\n",...
                                        '\n',...
    label,                              '\n',...
    underline,                          '\n',...
                                        '\n',...
    accordion,                               ... % trailin whitespace
                                        '\n',...
                                        '\n',...
                                        '\n'...
    );

end
