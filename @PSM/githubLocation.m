function[repo, commit] = githubLocation(psmName)
%% Returns the Github repository and commit hash associated with a PSM's code
%
% [repo, commit] = githubLocation(psmName)
%
% ----- Inputs -----
%
% psmName: The name of a PSM. A string.
%
% ----- Outputs -----
%
% repo: The web address of the Github repository for the PSM. A string.
%
% commit: The commit hash for the PSM code. A string.

% The Github location associated with each PSM
info = [
    "bayspar", "https://github.com/jesstierney/BAYSPAR", "13446fb098445d9a8899d9f9a4ea9d81cd916ac9";
    "bayspline", "https://github.com/jesstierney/BAYSPLINE", "1e6f9673bcc55b483422c6d6e1b1f63148636094";
    "baymag", "https://github.com/jesstierney/BAYMAG", "358de1545d47cbde328fa543c66ab50a20680b00"
];

% Error check the psm name
psmName = dash.assertStrFlag(psmName);
p = strcmpi(psmName, info(:,1));
if ~any(p)
    error('Unrecognized PSM name. Allowed options are %s.', dash.messageList(info(:,1)));
end

% Return the repo and commit
repo = info(p,2);
commit = info(p,3);

end