function[] = method(title, examplesRoot)
%% document.method  Writes the RST documentation file for a class method
% ----------
%   document.method(title, examplesRoot)
%   Writes the RST markup for a class method. Saves the RST to the current
%   folder with a file name <method name>.rst
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the method
%       examplesRoot (string scalar): The absolute path to the folder that
%           holds the examples markdown for the function

% Get the short title of the function
try
    title = string(title);
    titleParts = split(title, '.');
    classTitle = join(titleParts(1:end-1), '.');
    name = titleParts(end);
    
    % Get the name of the examples file. Build the RST markup
    examplesFile = strcat(examplesRoot, filesep, name, ".md");
    rst = build.methodRST(classTitle, name, examplesFile);
    
    % Replace any RST escapes
    rst = replace(rst, '\n', newline);
    rst = replace(rst, '|', '\|');
    rst = replace(rst, [newline, '\|'], [newline,'|']);
    
    % Write the file
    newfile = [pwd, filesep, char(name), '.rst'];
    fid = fopen(newfile, 'w');
    closeFile = onCleanup( @()fclose(fid) );
    fprintf(fid, '%s', rst);

% Informative errror
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        throw(cause);
    else
        rethrow(cause);
    end
end


end
