function[] = buildDocs
%% Builds the DASH HTML documentation pages

% Get the location of the doc builder
fullpath = mfilename('fullpath');
folders = split(fullpath, filesep);
folders = folders(1:end-1);
docSource = strjoin(folders, filesep);

% Move to the doc builder, but return to current location when finished
currentDir = pwd;
goback = onCleanup( @()cd(currentDir) );
cd(docSource);

% Clear the source .rst folder
source = fullfile(docSource, 'sphinx', 'source');
if isfolder(source)
    rmdir(source, 's');
end
mkdir(source);

% Move to the source folder and build .rst files
cd(source);
dashRoot = fullfile(folders{1:end-1});
% examplesRoot = fullfile(docSource, 'examples');
examplesRoot = 'ignore-the-examples';
doc.dash(dashRoot, examplesRoot);

% Add the sphinx config and index rst to the sphinx reST source
conf = fullfile(docSource, 'sphinx', 'config', 'conf.py');
copyfile(conf, source);
index = fullfile(docSource, 'sphinx', 'config', 'index.rst');
copyfile(index, source);

% Clear the HTML build
build = fullfile(docSource, 'build', 'html');
if isfolder(build)
    rmdir(build, 's');
end
mkdir(build);

% Use sphinx to build the html pages
command = sprintf('sphinx-build -qa %s %s', source, build);
system(command);

end