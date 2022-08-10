function[] = class(title, examplesRoot)
%% document.class  Build and write the RST files for a class and its methods
% ----------
%   document.class(title, examplesRoot)
%   Writes the RST markup for a class, and also the RST for the class
%   methods. Ignores inherited methods. The RST file for the class is
%   written to the current directory. The files for the methods are written
%   to a subfolder matching the short title of the class.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of the class
%       examplesRoot (string scalar): The absolute path to the folder that
%           holds the examples markdown for the class methods
%
%   Outputs:
%       Writes the RST file set for the class

% Build the RST for the classdef help
try
    rst = build.classRST(title);
    
    % Get the name of the file
    titleParts = split(title, '.');
    name = string(titleParts(end));
    newFile = [pwd, filesep, char(name), '.rst'];
    
    % Write the file
    fid = fopen(newFile, 'w');
    closeFile = onCleanup( @()fclose(fid) );
    rst = replace(rst, '\n', newline);
    fprintf(fid, '%s', rst);
    
    % Create a subfolder for the class methods
    subfolder = strcat(pwd, filesep, name);
    if ~isfolder(subfolder)
        mkdir(subfolder);
    end
    
    % Move to the subfolder, but return the the current location when finished
    home = pwd;
    goback = onCleanup( @()cd(home) );  % Return to initial location when function ends
    cd(subfolder);
    
    % Get the methods in the package.
    methodNames = string(methods(title));
    
    % Remove methods inherited from handle
    handleMethods = string(methods('handle'));
    remove = ismember(methodNames, handleMethods);
    methodNames(remove) = [];
    
    % Get the class title
    titleParts = split(title, '.');
    classTitle = string(titleParts(end));
    
    % Iterate through methods. Get help text if availabe
    for m = 1:numel(methodNames)
        method = methodNames(m);
        methodTitle = strcat(title, ".", method);
    
        % Ignore inherited methods
        if isinherited(methodTitle)
            continue
        end
        
        % Ignore undefined constructors. Constructor is undefined if its help
        % text matches the class help text
        if strcmpi(classTitle, method)
            classHelp = getClassHelp(title);
            methodHelp = getClassHelp(methodTitle);
            if strcmp(classHelp, methodHelp)
                continue
            end
        end
    
        % Document the method
        document.method(methodTitle, examplesRoot);
    end

% Informative errror
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        throw(cause);
    else
        rethrow(cause);
    end
end

end

function[text] = getClassHelp(title)
text = help(title);
eol = find(text==10);
text = text(1:eol(end-3));
end