function[] = functionRST(title, examplesFile, saveIn)
%% Convert a function header to .rst file

% Defaults
if ~exist('examplesFile','var')
    examplesFile = [];
end
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get the new file name
name = parse.name(title, true);
newfile = [saveIn, filesep, char(name), '.rst'];

% Get the rst content
rst = build.function.rst(title, examplesFile);

% Write
fid = fopen(newfile, 'w');
closeFile = onCleanup( @()fclose(fid) );
fprintf(fid, rst);

end