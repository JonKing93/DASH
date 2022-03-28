function[] = download(psmName, path)
%% Loads the code for a PSM and adds it to the active path.
%
% PSM.download(psmName)
% Downloads the code for a PSM to the current directory and adds it to the
% active path.
%
% PSM.download(psmName, path)
% Downloads the code for a PSM to the specified directory and adds it to the
% active path. The specified directory must be empty
%
% ----- Inputs -----
%
% psmName: The name of a PSM to download. A string. Options are
%   'bayfox': The BayFOX Bayesian model for d18Oc of planktic foraminifera
%   'baymag': The BayMAG Bayesian model for Mg/Ca of planktic foraminifera
%   'bayspar': The BaySPAR Bayesian model for TEX86
%   'bayspline': The BaySPLINE Bayesian model for UK'37
%   'prysm': The PRySM python package of proxy system modelling tools
%   'vslite': The Vaganov-Shaskin Lite model of tree-ring width
%
% path: Indicates the folder where the PSM code should be downloaded. A
%    string.

% Default and error check the path
if ~exist('path','var') || isempty(path)
    path = pwd;
    userPath = false;
else
    userPath = true;
    path = dash.assert.strflag(path);
end

% Get the Github repository for the PSM
[repo, commit] = PSM.githubLocation(psmName);

% Get the final download path. Ensure the folder is empty if it exists
if ~userPath
    [~, defaultFolder] = fileparts(repo);
    path = fullfile(path, defaultFolder);
end
if isfolder(path)
    contents = dir(path);
    if ~strcmp([contents.name], "...")
        error('The folder "%s" is not empty. You can only download PSM code to a new or empty folder.', path);
    end
end

% Clone the repository
clone = sprintf("git clone %s ""%s""", repo, path);
status = system(clone);
if status~=0
    gitFailureError(repo, commit);
end

% Checkout the commit
home = pwd;
try
    cd(path);
    checkout = sprintf( "git checkout %s -q", commit );
    status = system(checkout);
    assert(status==0);
    
% Delete the clone and return to the working directory if checkout fails
catch
    cd(home);
    rmdir(path, 's');
    gitFailureError(repo, commit);    
end

% Add PSM code to path and return to working directory
cd(home);
addpath(genpath(path));

end

% Long error message
function[] = gitFailureError(repo, commit)
github = strcat(repo, '/tree/', commit);
error(['Could not download the repository. Please check that you have ',...
    'git installed and on your system path. If problems persist, you ',...
    'can download the PSM code manually at "%s".'], github);
end