function[info] = info(psmNames)
%% PSM.info  Return information about the PSMs supported by DASH
% ----------
%   info = PSM.info
%   Return information about all the PSMs supported by the DASH toolbox.
%   Information includes PSM names, descriptions, and whether each PSM can
%   estimate R uncertainties.
%
%   info = PSM.info(psmNames)
%   Returns information about the specified PSMs.
% ----------
%   Inputs:
%       psmNames (string vector [nNames]): The names of the PSMs for which
%           to return information.
%
%   Outputs:
%       info (table [nNames x 3]): A table with information about the specified
%           PSMs. Includes PSM names, descriptions, and whether each PSM
%           can estimate R uncertainties.
%
% <a href="matlab:dash.doc('PSM.info')">Documentation Page</a>

% Setup
header = "DASH:PSM:info";
supported = PSM.supported;

% Default and error check PSM names
if ~exist('psmNames', 'var')
    psmNames = PSM.supported;
else
    psmNames = dash.assert.strlist(psmNames, 'psmNames', header);
    dash.assert.strsInList(psmNames, supported, 'psmNames', 'the name of a supported PSM', header);
end

% Preallocate
nNames = numel(psmNames);
descriptions = strings(nNames, 1);
estimatesR = false(nNames, 1);
hasMemory = false(nNames, 1);

% Get information
for n = 1:nNames
    name = psmNames(n);
    estimatesR(n) = PSM.(name).estimatesR;
    hasMemory(n) = PSM.(name).hasMemory;

    % Get description
    description = PSM.(name).description;
    if isempty(description)
        description = PSM.(name).packageDescription;
    end
    descriptions(n) = description;
end

% Organize as a table
info = table(psmNames(:), descriptions, estimatesR, hasMemory);
info.Properties.VariableNames = ["Name", "Description","Can_Estimate_R","Has_Memory"];

end