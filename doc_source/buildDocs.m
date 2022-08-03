function[] = buildDocs
%% buildDocs  Builds the DASH HTML documentation set
% ----------
%   buildDocs
%   Converts examples markdown into RST files. Compiles the RST file set
%   for sphinx, then runs sphinx to build the HTML documentation set.
%   Locates and builds files within the "doc_source" directory of the DASH
%   toolbox using the file paths specified in the configuration parameters.
%   
%   You can adjust which contents of the DASH toolbox are documented using
%   the "include" parameter in the configuration.
% ----------
%   Outputs:
%       Writes the sphinx RST file set, and the HTML documentation set.

%% Configuration parameters

% File locations and written file destinations.
% Note: All locations are relative to the folder holding the "buildDocs"
% function. The root of the DASH toolbox is assumed to be the folder
% immediately above the folder holding the "buildDocs" function.
examplesLocation = {"examples"};                % The root of the examples markdown file set
rstDestination = {"sphinx","source"};           % The directory in which to write the RST file set for sphinx
sphinxConfig = {"sphinx","config","conf.py"};   % The location of the sphinx configuration file
sphinxIndex = {"sphinx","config","index.rst"};  % The location of the index RST file for sphinx
htmlDestination = {"build", "html"};            % The directory in which to write the HTML documentation set 

% The contents of the toolbox that should be documented.
include = "+dash";


%% Build the documentation

% Get the location of the the "buildDocs" method
fullpath = mfilename('fullpath');
folders = split(fullpath, filesep);
folders = folders(1:end-1);
docSource = strjoin(folders, filesep);

% Move to the location of "buildDocs", but return to current location when finished
currentDir = pwd;
goback = onCleanup( @()cd(currentDir) );
cd(docSource);

% Clear the source .rst folder
source = fullfile(docSource, rstDestination{:});
if isfolder(source)
    rmdir(source, 's');
end
mkdir(source);

% Move to the source folder and build .rst files
cd(source);
dashRoot = fullfile(folders{1:end-1});
examplesRoot = fullfile(docSource, examplesLocation{:});
doc.dash(dashRoot, examplesRoot, include);

% Add the sphinx config and index rst to the sphinx reST source
conf = fullfile(docSource, sphinxConfig{:});
copyfile(conf, source);
index = fullfile(docSource, sphinxIndex{:});
copyfile(index, source);

% Clear the HTML build
build = fullfile(docSource, htmlDestination{:});
if isfolder(build)
    rmdir(build, 's');
end
mkdir(build);

% Use sphinx to build the html pages
command = sprintf('sphinx-build -qa %s %s', source, build);
system(command);

end