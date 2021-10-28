function[] = packageRST(title, saveIn)
%% Convert a package help file to .rst file

% Default
if ~exist('saveIn','var') || isempty(saveIn)
    saveIn = pwd;
end

% Get the new file
name = parse.name(title, true);
newfile = [saveIn, filesep, char(name), '.rst'];

% Get the rst
rst = build.package.rst(title);

% Write
fid = fopen(newfile, 'w');
closeFile = onCleanup( @()fclose(fid) );
fprintf(fid, rst);

end