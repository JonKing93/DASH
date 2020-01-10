function[reconH] = checkReconH( recon, F )
% Checks if PSM H values will be reconstructed
%
% reconH = dash.checkReconH( recon, F )
%
% ----- Inputs -----
%
% recon: A vector of logical indices (nState x 1)
%
% F: A cell vector of PSMs
%
% ----- Outputs -----
%
% reconH: A scalar logical indicating whether the reconstructed elements
%         include all of the state elements needed to run the PSMs (H).

% Error check
if ~isvector(recon) || ~islogical(recon)
    error('recon must be a logical vector.');
elseif ~isvector(F) || ~iscell(F)
    error('F must be a cell vector.');
end

% Get the H indices from each PSM
nPSM = numel(F);
psmIndices = cell(nPSM,1);
for s = 1:nPSM
    if ~isscalar(F{s}) || ~isa( F{s}, 'PSM' )
        error('Each element of F must be a scalar PSM.');
    end
    psmIndices{s} = F{s}.H;
end
psmIndices = cell2mat(psmIndices);

% Compare to the reconstruction indices
reconIndices = find( recon );
reconH = true;
if any( ~ismember(psmIndices, reconIndices) )
    reconH = false;
end

end