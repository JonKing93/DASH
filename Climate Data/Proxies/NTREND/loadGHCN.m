function[gmeta, ghcn] = loadGHCN

% Load the metadata
gmeta = load('ghcnMeta.mat');

% Load ghcn
if nargout > 1
    ghcn = load('GHCN_Tavg.mat');
    ghcn = ghcn.ghcn;
end

end