function[] = functionHelp(file, examplesFile)
%% Convert a function header to .rst file

% Default for no examples
if ~exist('examplesFile','var')
    examplesFile = [];
end

% Get the new file
[~, name] = fileparts(file);
newfile = [char(name), '.rst'];

% Get help text
header = get.functionHelp(file);

% Build file parts
title = build.title(header);
syntax = build.syntax(header);
description = build.description(header);
examples = build.examples(examplesFile);
inputs = build.inputs(header);
outputs = build.outputs(header);
content = strcat(title, syntax, description, examples, inputs, outputs);

% Trim the final transition line
content = char(content);
k = strfind(content, '----');
k = k(end);
content(k:end) = [];

% Write
fid = fopen(newfile, 'w');
closeFile = onCleanup( @()fclose(fid) );
fprintf(fid, content);

end