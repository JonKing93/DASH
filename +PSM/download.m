function[] = download(psmName, path)
%% PSM.download  Download the codebase for a PSM from Github
% ----------
%   PSM.download(psmName)
%   Downloads the repository for the specified PSM from Github and adds the
%   repository to the Matlab active path. The repository is downloaded to
%   the current directory in a folder that matches the name of the
%   repository. If the current directory already has a folder matching the
%   name of the repostiory, then that folder must be empty. The downloaded
%   repository is checked out at the commit supported by the DASH toolbox.  
%
%   This command requires:
%       1. An internet connection, and
%       2. You have git installed and on your system path
%
%   PSM.download(psmName, path)
%   Downloads the repository contents into the specified folder. The folder
%   must be empty.
% ----------
%   Inputs:
%       psmName (string scalar): The name of a PSM codebase supported by
%           DASH. Options are "bayfox", "baymag", "bayspar", "bayspline",
%           "prysm", and "vslite". The general linear PSM is built-in
%           directly to DASH and does not need to be downloaded. 
%
%           Note that you can also use "prysm.cellulose", "prysm.coral",
%           "prysm.icecore", or "prysm.speleothem" to download the PRYSM
%           suite of Python forward models. However, these options will
%           download the entire PRYSM suite, and not just the single
%           indicated forward model.
%       path (string scalar | char row vector): The name of the folder in
%           which to download the repository code. The folder must be
%           empty. By default, uses the current folder.
%
%   Downloads:
%       Downloads the specified repository to the indicated folder and adds
%       the repository to the Matlab active path.
%
% <a href="matlab:dash.doc('PSM.download')">Documentation Page</a>

% Error check the PSM name.
header = "DASH:PSM:download";
psmName = dash.assert.strflag(psmName, 'psmName', header);

% Require a supported PSM
supported = PSM.supported;
dash.assert.strsInList(psmName, supported, 'psmName', 'name of a supported PSM codebase', header);

% If linear, explain the PSM is a built-in
if strcmpi(psmName, 'linear')
    fprintf(['\nThe "linear" PSM is built-in directly to DASH. You do not need ',...
        'to download this PSM.\n\n']);
    return
end

% Default and error check the path
if ~exist('path','var') || isempty(path)
    path = pwd;
    userPath = false;
else
    path = dash.assert.strflag(path, 'path', header);
    userPath = true;
end

% Get the Github information for the PSM
info = PSM.githubInfo(psmName);
repo = sprintf('https://github.com/%s', info.Repository);

% Get the default download path. If the folder exists, ensure it is empty
if ~userPath
    [~, folder] = fileparts(repo);
    path = fullfile(path, folder);
end

% Ensure that new folders and changes to location are reverted if the
% download fails for any reason
if isfolder(path)
    newFolder = false;
else
    newFolder = true;
end
home = pwd;
reset = onCleanup( @()cleanup(home, path, newFolder) );

% Create download folder if it does not exist
if ~isfolder(path)
    try
        mkdir(path);
    catch
        invalidPathError(path, header);
    end

% Otherwise, ensure the folder is empty
else
    contents = dir(path);
    if ~strcmp([contents.name], "...")
        folderNotEmptyError(path, header);
    end
end

% Clone the repository.
clone = sprintf("git clone %s ""%s""", repo, path);
status = system(clone);
fprintf('\n');
if status ~= 0
    downloadFailedError(info, header);
end

% Checkout the supported commit
cd(path);
checkout = sprintf("git checkout %s -q", info.Commit);
status = system(checkout);
if status ~= 0
    checkoutFailedError(info, header);
end

% Add PSM to active path
addpath(genpath(path));

end

%% Utilities
function[] = cleanup(home, path, newFolder)

% Return to initial folder
cd(home);

% % Delete new folder
% if newFolder && isfolder(path)
%     rmdir(path, 's');
% end

end

%% Error messages
function[] = invalidPathError(path, header)
id = sprintf('%s:invalidPath', header);
ME = MException(id, ['The indicated download path:\n\t%s\n',...
    'is not a valid path.'], path);
throwAsCaller(ME);
end
function[] = folderNotEmptyError(path, header)
id = sprintf('%s:folderNotEmpty', header);
ME = MException(id, 'The download path:\n\t%s\nis not an empty folder.', path);
throwAsCaller(ME);
end
function[] = downloadFailedError(info, header)
id = sprintf('%s:downloadFailed', header);
href = sprintf("https://github.com/%s/tree/%s", info.Repository, info.Commit);
link = sprintf('<a href="%s">%s</a>', href, href);
ME = MException(id, ['Could not download the repository for the "%s" codebase. ',...
    'Please check that:\n\t1. You are connected to the internet, and\n\t',...
    '2. git is installed and on your system path.\nIf the problem ',...
    'persists, you can download the PSM code manually at:\n\t%s'],...
    info.Name, link);
throwAsCaller(ME);
end
function[] = checkoutFailedError(info, header)
id = sprintf('%s:checkoutFailed', header);
href = sprintf("https://github.com/%s/tree/%s", info.Repository, info.Commit);
link = sprintf('<a href="%s">%s</a>', href, href);
ME = MException(id, ['Could not checkout the supported version of the repository ',...
    'for the "%s" codebase. Please check that git is installed and on your ',...
    'system path. If the problem persists, you can download the PSM code ',...
    'manually at:\n\t%s\nIf this commit no longer exists on Github, please ',...
    'send an email to DASH.toolbox@gmail.com'], info.Name, link);
throwAsCaller(ME);
end