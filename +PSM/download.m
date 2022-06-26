function[] = download(psmName)
%% PSM.download  Download the code for a PSM from Github
% ----------
%   PSM.download(psmName)
%   Downloads the repository for the specified PSM from Github and adds the
%   repository to the Matlab active path. The repository is downloaded to
%   the current directory. The repository is downloaded at the commit that
%   is supported by the DASH toolbox.
%
%   PSM.download(psmName, path)
%   Downloads the repository to the specified directory (and adds the
%   repository to the active path). The directory must be empty.
% ----------
%   Inputs:
%       psmName (string scalar): The name of a PSM codebase supported by DASH.
%           "bayfox": The BayFOX model of foraminiferal d18Oc 
%           "baymag": The BayMAG model of foraminiferal Mg/Ca
%           "bayspar": The BaySPAR TEX86 forward model
%           "bayspline": The BaySPLINE UK'37 forward model
%           "prysm": The PRYSM Python suite of forward models
%           "vslite": The VS-Lite model of tree-ring width
%       path (string scalar | char row vector): The name of the folder in
%           which to download the repository code.
%
%   Outputs:
%       Downloads the specified repository to the indicated folder.
%
% <a href="matlab:dash.doc('PSM.download')">Documentation Page</a>

% Header
header = "DASH:PSM:download";

% Check the PSM name is supported








% Default path
userPath = true;
if ~exist('path', 'var') || isempty(path)
    path = pwd;
    userPath = false;
end

% 





else
    path = dash.assert.strflag(path, 'path', header);
end

% Error check the PSM
dash.assert.strflag(psmName, 'psmName', header);

