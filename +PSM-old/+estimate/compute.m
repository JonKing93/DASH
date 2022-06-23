function[Ye, R] = compute(X, F, throwError)
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
% [...] = PSM.computeEstimates(X, F, throwError)
% Specify whether to throw an error when a PSM fails, or issue a warning.
%
% ----- Inputs -----
%
% X: A model ensemble. A numeric array with up to 3 
%    dimensions. (nState x nEns x nPrior)
%
% F: Cell vector of PSMs
%
% throwError: A scalar logical indicating whether to throw an error when a
%    PSM fails (true), or instead issue a warning (false -- Default)
%
% ----- Outputs -----
%
% Ye: Proxy estimates for the prior(s). (nSite x nEns x nPrior)
%
% R: Error-variances for the priors. (nSite x nEns x nPrior)

% Default and error check error throws
if ~exist('throwError','var') || isempty(throwError)
    throwError = false;
end
dash.assert.scalarType(throwError, 'throwError', 'logical', 'logical');
 
% Sizes
nSite = numel(F);
[nState, nEns, nPrior] = size(X);

% Preallocate
Ye = NaN(nSite, nEns, nPrior);
if nargout>1
    R = NaN(nSite, nEns, nPrior);
end

% Get the estimates for each PSM and the recorded rows
for s = 1:nSite
    psm = F{s};
    rows = psm.rows;
    
    % Propagate rows over ensemble members and priors
    [nRows, nCols, nDim3] = size(rows);
    if nCols==1
        rows = repmat(rows, [1 nEns, 1]);
    end
    if nDim3==1
        rows = repmat(rows, [1 1 nPrior]);
    end
    
    % Extract the data required to run the PSM
    siz = [nRows, nEns, nPrior];
    [~, c, p] = ind2sub(siz, (1:prod(siz))' );
    index = sub2ind([nState, nEns, nPrior], rows(:), c, p);
    Xpsm = reshape( X(index), siz );
    
    % Notify user if PSMs fail
    ranPSM = false(1, nPrior);
    psmFailed = false(1, nPrior);
    Rfailed = false(1, nPrior);
    
    % Run the PSM for each prior
    for p = 1:nPrior
        Xrun = Xpsm(:,:,p);
        
        % Run the PSM with R estimation
        if nargout>1 && psm.estimatesR
            try
                [Yrun, Rrun] = psm.runPSM(Xrun);
                ranPSM(p) = true;
                Rname = sprintf('R estimates for %s for prior %.f', psm.messageName(s), p);
                dash.assert.vectorTypeN(Rrun, 'numeric', nEns, Rname);
                assert(isrow(Rrun), sprintf('%s must be a row vector', Rname));
            catch ME
                Rfailed(p) = true;
                
                if throwError
                    rethrow(ME);
                end
            end
        end
        
        % Run the PSM without R estimation.
        if ~ranPSM(p)
            try
                Yrun = psm.runPSM(Xrun);
                ranPSM(p) = true;
            catch ME
                psmFailed(p) = true;
                Rfailed(p) = true;
                
                if throwError
                    rethrow(ME);
                end
            end
        end
        
        % Error check the Y output
        if ranPSM(p)
            try
                Yname = sprintf("Y estimates for %s for prior %.f", psm.messageName(s), p);
                dash.assert.vectorTypeN(Yrun, 'numeric', nEns, Yname);
                assert(isrow(Yrun), sprintf('%s must be a row vector', Yname));
            catch ME
                psmFailed(p) = true;
                Rfailed(p) = true;
                
                if throwError
                    rethrow(ME);
                end
            end
        end
        
        % Only record values if the PSM was successful
        if ~psmFailed(p)
            Ye(s,:,p) = Yrun;
            if nargout>1 && psm.estimatesR && ~Rfailed(p)
                R(s,:,p) = Rrun;
            end
        end
    end
    
    % Notify user of failed PSMs
    if any(psmFailed)
        whichPrior = '';
        if ~all(psmFailed)
            whichPrior = sprintf(' for prior(s) %s', dash.string.messageList(find(psmFailed)));
        end
        warning('%s failed to run%s', psm.messageName(s), whichPrior);
    end
    
    % Notify of failed R estimation
    Rfailed = Rfailed & ~psmFailed;
    if nargout>1 && psm.estimatesR && any(Rfailed)
        whichPrior = '';
        if ~all(Rfailed)
            whichPrior = sprintf(' for prior(s) %s', dash.string.messageList(find(Rfailed)));
        end
        warning('%s failed to estimate R values%s', psm.messageName(s), whichPrior);
    end
end

end