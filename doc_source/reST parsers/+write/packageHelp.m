function[] = packageHelp(file)
%% Convert a package help file to .rst file

% Get the help text
help = get.packageHelp(file);

% Get the new file
newfile = parse.packageSubfolder(help);
newfile = [char(newfile), '.rst'];

% Build file parts
summary = build.packageSummary(help);
contents = build.packageContents(help);
filetext = strcat(summary, contents);

% Write
fid = fopen(newfile, 'w');
closeFile = onCleanup( @()fclose(fid) );
fprintf(fid, filetext);

end