function[] = documentDASH(rebuildReference)
%% documentDASH  Builds the complete reference guide for the DASH toolbox
% ----------
%   documentDASH
%   Builds the reference guide for the DASH toolbox. Requires that the DASH
%   reST parsers in the doc_source folder are added to the active path.
%   Currently requires that "PSM.template" is temporarily removed from the toolbox. 
% 
%   Builds reST markup for each item in the toolbox and saves the reST in
%   the doc_source/sphinx/source folder. Then, runs sphinx on the reST
%   markup (using the config and index files in doc_source/sphinx/config)
%   to generate the final HTML reference set. The final set is located in
%   doc_source/sphinx/build/html.
%
%   documentDASH(rebuildReference)
%   Indicate whether to rebuild the RST for the reference guide
% ----------
%   Inputs:
%       rebuildReference (scalar logical): True if the command should
%           rebuild the RST pages for the reference guide. False to skip
%           building the reference guide RSTs.


%%%%% Parameters

% File locations (relative to the location of this function)
examplesLocation = "examples";
rstDestination = "sphinx/source";
sphinxResources = "sphinx/resources";
htmlBuild = "build/html";
doctrees = "build/doctrees";


% Note the items to document and whether they are classes or packages
contents = ["gridMetadata",      "class"
            "gridfile",          "class"
            "stateVector",       "class"
            "ensemble",          "class"
            "ensembleMetadata",  "class"
            "PSM",               "package"
            "kalmanFilter",      "class"
            "particleFilter",    "class"
            "optimalSensor",     "class"
            "dash",              "package"];
%%%%%


%% Setup

if ~exist('rebuildReference', 'var')
    rebuildReference = true;
end

% Get the location of this function
fullpath = mfilename('fullpath');
folders = split(fullpath, filesep);
folders = folders(1:end-1);
docSource = strjoin(folders, filesep);

% Locate the source folder
source = fullfile(docSource, rstDestination);

% Move to the location of "buildDocs", but return to current location when finished
currentDir = pwd;
goback = onCleanup( @()cd(currentDir) );
cd(docSource);


%% Prepare source
% This section prepares the source folder to receive the RST files

if rebuildReference
    fprintf('Preparing source\n');
    
    % Clear the source .rst folder and move to it
    if isfolder(source)
        rmdir(source, 's');
    end
    mkdir(source);
    cd(source);
    
    %% Build RST
    % This section builds the RST files for each item in DASH
    fprintf('Building reST files\n');
    
    % Document each item
    examplesRoot = fullfile(docSource, examplesLocation);
    nContents = size(contents, 1);
    for c = 1:nContents
        item = contents(c,1);
        type = contents(c,2);
        examples = strcat(examplesRoot, filesep, item);
        document.(type)(item, examples);
    end
    
    % Write the documentation for PSM.template
    writePSMTemplate;
    
    % Fix the links to inherited methods
    fixInheritanceLinks;
end

%% Run sphinx
% This section runs sphinx in order to generate HTML from the RST
fprintf('Preparing sphinx\n');

% Add the sphinx conf.py, index.rst, and _static folder to the source
conf = fullfile(docSource, sphinxResources);
copyfile(conf, source);

% Clear the HTML build
build = fullfile(docSource, htmlBuild);
if isfolder(build)
    rmdir(build, 's');
end
mkdir(build);

% Clear the doctrees
doctrees = fullfile(docSource, doctrees);
if isfolder(doctrees)
    rmdir(doctrees, 's');
end
mkdir(doctrees);

% Use sphinx to build the html pages
fprintf('Running sphinx\n');
command = sprintf('sphinx-build -d %s -qEa %s %s', doctrees, source, build);
system(command);
fprintf('Documentation complete\n');

% Delete the doctrees
if isfolder(doctrees)
    rmdir(doctrees, 's');
end

end