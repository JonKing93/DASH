function[Ye, R] = computeEstimates(X, F)
%% Computes proxy estimates for an ensemble and set of PSMs. This is a
% low-level function and does not apply error-checking. Please see
% "PSM.estimate" for the recommended user command.
%
% Ye = PSM.computeEstimates(X, F)
% Estimate observations from the ensemble using the PSMs
%
% [Ye, R] = PSM.computeEstimates(X, F)
% Also estimate error-variances from PSMs when possible
%
% ----- Inputs -----
%
% X: A model ensemble. A numeric array with up to 3 
%    dimensions. (nState x nEns x nPrior)
%
% F: Cell vector of PSMs
%
% ----- Outputs -----
%
% Ye: Proxy estimates for the prior(s). (nSite x nEns x nPrior)
%
% R: Error-variances for the priors. (nSite x nEns x nPrior)

% Sizes
nSite = numel(F);
[~, nEns, nPrior] = size(X);

% Preallocate
Ye = NaN(nSite, nEns, nPrior);
if nargout>1
    R = NaN(nSite, nEns, nPrior);
end

% Get the estimates for each PSM.
for s = 1:nSite
    psm = F{s};
    
    % Propagate rows over ensemble members and priors
    [~, nCols, nDim3] = size(psm.rows, 1:3);
    if nCols==1
        psm.rows = repmat(psm.rows, [1 nEns, 1]);
    end
    if nDim3==1
        psm.rows = repmat(psm.rows, [1 1 nPrior]);
    end
    
    % Extract the data required to run the PSM
    [~, c, p] = ind2sub(siz, 1:prod(siz));
    index = sub2ind([nState, nEns, nPrior], psm.rows(:), c, p);
    Xpsm = reshape( X(index), siz );
    
    % Run the PSM for each prior
    for p = 1:nPrior
        Xrun = Xpsm(:,:,p);
        
        % Run the PSM with R estimation
        ranPSM = false;
        if nargout>1 && psm.estimatesR
            Rfailed = false;
            try
                [Yrun, Rrun] = psm.runPSM(Xrun);
                ranPSM = true;           
            catch
                Rfailed = true;
            end            
            if ~isnumeric(Rrun) || ~isrow(Rrun) || numel(Rrun)~=nEns
                Rfailed = true;
            end
            
            % Notify user and reset R if failed
            if Rfailed
               warning('Failed to estimate R values for %s for prior %.f', psm.messageName(s), p);
               Rrun = NaN(1, nEns);
            end
        end
        
        % Run the PSM without R estimation
        if ~ranPSM
            Yrun = psm.runPSM(Xrun);
        end
        
        % Error check the Y output
        name = sprintf('Y values for %s for prior %.f', psm.messageName(s), p);
        dash.assertVectorTypeN(Yrun, 'numeric', nEns, name);
        if ~isrow(Yrun)
            error('%s must be a row vector', name);
        end  
        
        % Record values
        Ye(s,:,p) = Yrun;
        if nargout>1 && psm.estimatesR
            R(s,:,p) = Rrun;
        end
    end
end

end