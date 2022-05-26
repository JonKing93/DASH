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

% The Github location associated with each PSM. Order is 1. key (name for
% DASH), 2. Github Repository, 3. Commit 
info = [
    "bayspar", "https://github.com/jesstierney/BAYSPAR", "310e876513151bf01e7c39f5dbdde7b991ea7204";
    "bayspline", "https://github.com/jesstierney/BAYSPLINE", "1e6f9673bcc55b483422c6d6e1b1f63148636094";
    "baymag", "https://github.com/jesstierney/BAYMAG", "358de1545d47cbde328fa543c66ab50a20680b00";
    "bayfox", "https://github.com/jesstierney/bayfoxm", "cb98a5259c7340c3b19669c45a599799b9a491c2";
    "vslite", "https://github.com/suztolwinskiward/VSLite", "f86cc33ee0eb9a2b9818994542d3c4179e618631";
    "prysm", "https://github.com/sylvia-dee/PRYSM", "13dc4fbc1a4493e86a4568d2d83d8495f6f40fe1"
];

% Error check the psm name
psmName = dash.assert.strflag(psmName);
p = strcmpi(psmName, info(:,1));
if ~any(p)
    error('Unrecognized PSM name. Allowed options are %s.', dash.string.messageList(info(:,1)));
end

% Return the repo and commit
repo = info(p,2);
commit = info(p,3);

end