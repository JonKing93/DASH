function[rst] = rst(title, examplesFile)
%% Builds the complete rst for a function file

% Defaults
if ~exist('examplesFile','var') || isempty(examplesFile)
    examplesFile = [];
end

% Get the help text
header = get.help(title);

% Build each part of the .rst file
title = build.function.title(header);
syntax = build.function.syntax(header);
description = build.function.description(header);
examples = build.function.examples(examplesFile);
inputs = build.function.inputs(header);
outputs = build.function.outputs(header);

% Join into the complete .rst contents
rst = strcat(title, syntax, description, examples, inputs, outputs);

% Trim the final transition line
rst = char(rst);
k = strfind(rst, '----');
k = k(end);
rst(k:end) = [];

end
