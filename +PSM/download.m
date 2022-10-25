function[] = download(psmName, varargin)
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
%   PSM.download(..., 'path', path)
%   Downloads the repository contents into the specified folder. The folder
%   must be empty.
%
%   PSM.download(..., 'latest', useLatest)
%   Specify whether the command should checkout the latest commit of the
%   forward model - regardless of whether the latest commit is officially
%   supported by the DASH toolbox. By default, checks out a supported
%   commit.
% ----------
%   Inputs:
%       psmName (string scalar): The name of a PSM codebase supported by
%           DASH. You can see the names of supported PSMs using the
%           "PSM.supported" command. The general linear PSM, and the identity
%           PSM are built-in directly to DASH and do not need to be downloaded.
%       path (string scalar | char row vector): The name of the folder in
%           which to download the repository code. The folder must be
%           empty. By default, uses the current folder.
%       useLatest (scalar logical): Set to true if the command should
%           checkout the latest forward model commit - regardless of
%           whether the latest commit is officially supported by DASH. Set
%           to false to checkout the supported commit. Default is to
%           checkout the supported commit.
%
%   Downloads:
%       Downloads the specified repository to the indicated folder and adds
%       the repository to the Matlab active path.
%
% <a href="matlab:dash.doc('PSM.download')">Documentation Page</a>

% Error check the PSM name.
header = "DASH:PSM:download";
psmName = dash.assert.strflag(psmName, 'psmName', header);
dash.assert.strsInList(psmName, PSM.supported, 'psmName', 'name of a supported PSM codebase', header);

% Explain if the PSM is a built-in
if ismember(psmName, ["linear","identity"])
    fprintf(['\nThe "%s" PSM is built-in directly to DASH. You do not need ',...
        'to download this PSM.\n\n'], psmName);
    return
end

% Parse the optional inputs
[path, useLatest] = dash.parse.nameValue(varargin, ["path","latest"], {[], false}, 1, header);
dash.assert.scalarType(useLatest, 'logical', 'useLatest', header);

% Get the Github information for the PSM
info = PSM.githubInfo(psmName);
repo = sprintf('https://github.com/%s', info.Repository);

% Default and error check path
if isempty(path)
    path = string(pwd);
    [~, folder] = fileparts(repo);
    path = fullfile(path, folder);
else
    path = dash.assert.strflag(path, 'path', header);
end

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
    if numel(contents) > 2
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

% If moving to the folder (to checkout the supported commit), ensure that
% the current path is always restored
if ~useLatest
    home = pwd;
    reset = onCleanup( @()cd(home) );
    cd(path);

    % Checkout the supported commit
    checkout = sprintf("git checkout %s -q", info.Commit);
    status = system(checkout);
    if status ~= 0
        checkoutFailedError(info, header);
    end
end

% Add PSM to active path
addpath(genpath(path));

end


%% Error messages
function[] = invalidPathError(path, header)
id = sprintf('%s:invalidPath', header);
ME = MException(id, ['The requested download path:\n\t%s\n',...
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