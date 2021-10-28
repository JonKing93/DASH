function[] = functionRST(title, examplesFile, saveIn)
%% Convert a function header to .rst file

% Defaults
if ~exist('examplesFile','var')
    examplesFile = [];
end
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get file, and write rst content
newfile = write.filename(title, saveIn);
rst = build.function.rst(title, examplesFile);
write.rst(newfile, rst);

end