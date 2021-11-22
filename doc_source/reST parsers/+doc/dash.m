function[] = dash(root, examplesRoot)
%% Builds the documentation for all of DASH
% 
% Different from doc.package because the toolbox does not have a title to
% add to the title chain

% Get the docs to include
include = ["+dash", "@gridMetadata"];

% Get the contents
contents = dir(root);
files = string({contents.name});
files = files(ismember(files, include));
contents = strcat(root, filesep, files);

% Document the contents
for c = 1:numel(contents)
    doc.content("", contents(c), examplesRoot);
end

end