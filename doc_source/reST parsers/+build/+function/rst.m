function[rst] = rst(title, examplesFile)
%% build.function.rst  Returns the RST text for a function
% ----------
%   rst = build.function.rst(title, examplesFile)
%   Parses the help text and markdown examples for a function and converts
%   them into RST formatted text.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing name of a function
%       examplesFile (string scalar): The absolute path to the markdown
%           examples file for a function.
%
%   Outputs:
%       rst (char vector): RST formatted text for the function.

% Defaults
if ~exist('examplesFile','var') || isempty(examplesFile)
    examplesFile = [];
end

% Get the help text
try
    helpText = get.help(title);
    
    % Build each part of the .rst file
    title = build.function.title(helpText);
    syntax = build.function.syntax(helpText);
    description = build.function.description(helpText);
    examples = build.function.examples(examplesFile);
    inputs = build.function.inputs(helpText);
    outputs = build.function.outputs(helpText);

% Report cause of failure
catch cause
    ME = MException('function:rst:failed', 'Could not format the RST for function "%s"', title);
    ME = addCause(ME, cause);
    throw(ME);
end

% Join into the complete .rst contents
rst = strcat(title, syntax, description, examples, inputs, outputs);

% Trim the final transition line
rst = char(rst);
k = strfind(rst, '----');
k = k(end);
rst(k:end) = [];

end
