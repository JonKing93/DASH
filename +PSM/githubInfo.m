function[info] = githubInfo(psmNames)
%% PSM.githubInfo  Return information about the Github repository for each PSM
% ----------
%   info = PSM.githubInfo
%   Returns information about the Github repository and commit for each PSM
%   supported by the DASH toolbox. Information includes the Github
%   repository, the commit hash of the supported version, and a comment
%   about the commit.
%
%   info = PSM.githubInfo(psmNames)
%   Returns information about the specified PSMs.
% ----------
%   Inputs:
%       psmNames (string vector [nNames]): The names of the PSMs for which
%           to return information.
%
%   Outputs:
%       info (table [nNames x 4]): A table with information about the specified
%           PSMs. Includes PSM names, Github repository, commit hash of 
%           the supported version, and a comment about the commit.
%
% <a href="matlab:dash.doc('PSM.githubInfo')">Documentation Page</a>

% Setup
header = "DASH:PSM:githubInfo";
supported = PSM.supported;

% Default and error check PSM names
if ~exist('psmNames', 'var')
    psmNames = PSM.supported;
else
    psmNames = dash.assert.strlist(psmNames, 'psmNames', header);
    dash.assert.strsInList(psmNames, supported, 'psmNames', 'the name of a supported PSM', header);
end

% Alias prysm to the package superclass
alias = strcmp(psmNames, "prysm");
psmNames(alias) = "prysm.package";

% Preallocate
nNames = numel(psmNames);
repositories = strings(nNames, 1);
commits = strings(nNames, 1);
comments = strings(nNames, 1);

% Get information
for n = 1:nNames
    name = psmNames(n);
    repositories(n) = PSM.(name).repository;
    commits(n) = PSM.(name).commit;
    comments(n) = PSM.(name).commitComment;
end

% Organize as a table
psmNames(alias) = "prysm";
info = table(psmNames(:), repositories, commits, comments);
info.Properties.VariableNames = ["Name", "Repository", "Commit", "Comment"];

end