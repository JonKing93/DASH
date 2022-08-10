function[] = documentDASH
%% documentDASH  Builds the complete reference guide for the DASH toolbox
% ----------
%   documentDASH
%   Builds the reference guide for the DASH toolbox. Requires that the DASH
%   reST parsers in the doc_source folder are added to the active path.
%   Currently requires that the PSM.template and PSM.prysm.* contents are
%   temporarily removed from the toolbox. 
% 
%   Builds reST markup for each item in the toolbox and saves the reST in
%   the doc_source/sphinx/source folder. Then, runs sphinx on the reST
%   markup (using the config and index files in doc_source/sphinx/config)
%   to generate the final HTML reference set. The final set is located in
%   doc_source/sphinx/build/html.
% ----------


%%%%% Parameters

% File locations (relative to the location of this function)
examplesLocation = "examples";
rstDestination = "sphinx/source";
sphinxConfig = "sphinx/config/conf.py";
sphinxIndex = "sphinx/config/index.rst";
htmlBuild = "build/html";


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

%% Prepare source
% This section prepares the source folder to receive the RST files
fprintf('Preparing source\n');

% Get the location of this function
fullpath = mfilename('fullpath');
folders = split(fullpath, filesep);
folders = folders(1:end-1);
docSource = strjoin(folders, filesep);

% Move to the location of "buildDocs", but return to current location when finished
currentDir = pwd;
goback = onCleanup( @()cd(currentDir) );
cd(docSource);

% Clear the source .rst folder and move to it
source = fullfile(docSource, rstDestination);
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

%% Run sphinx
% This section runs sphinx in order to generate HTML from the RST
fprintf('Preparing sphinx\n');

% Add the sphinx config and index rst to the sphinx reST source
conf = fullfile(docSource, sphinxConfig);
copyfile(conf, source);
index = fullfile(docSource, sphinxIndex);
copyfile(index, source);

% Clear the HTML build
build = fullfile(docSource, htmlBuild);
if isfolder(build)
    rmdir(build, 's');
end
mkdir(build);

% Use sphinx to build the html pages
fprintf('Running sphinx\n');
command = sprintf('sphinx-build -qa %s %s', source, build);
system(command);
fprintf('Documentation complete\n');

end